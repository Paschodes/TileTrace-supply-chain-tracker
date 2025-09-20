;; TileTrace Supply Chain Tracker
;; Track ceramic tiles from raw materials to final installation

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u300))
(define-constant err-not-found (err u301))
(define-constant err-unauthorized (err u302))
(define-constant err-invalid-stage (err u303))
(define-constant err-already-exists (err u304))

(define-map supply-chain-records
  { batch-id: (string-ascii 20) }
  {
    manufacturer: principal,
    raw-material-source: (string-ascii 100),
    production-date: uint,
    quality-grade: (string-ascii 10),
    current-stage: (string-ascii 20),
    current-location: (string-ascii 100),
    final-destination: (optional (string-ascii 100)),
    created-by: principal
  }
)

(define-map stage-transitions
  { batch-id: (string-ascii 20), stage: (string-ascii 20) }
  {
    timestamp: uint,
    location: (string-ascii 100),
    handler: principal,
    notes: (string-ascii 200)
  }
)

(define-map authorized-handlers
  { handler: principal }
  { authorized: bool, role: (string-ascii 20) }
)

;; Initialize supply chain record
(define-public (create-batch-record
  (batch-id (string-ascii 20))
  (raw-material-source (string-ascii 100))
  (quality-grade (string-ascii 10)))
  (begin
    (asserts! (is-none (map-get? supply-chain-records { batch-id: batch-id })) err-already-exists)
    (asserts! (default-to false (get authorized (map-get? authorized-handlers { handler: tx-sender }))) err-unauthorized)
    (map-set supply-chain-records
      { batch-id: batch-id }
      {
        manufacturer: tx-sender,
        raw-material-source: raw-material-source,
        production-date: stacks-block-height,
        quality-grade: quality-grade,
        current-stage: "production",
        current-location: "factory",
        final-destination: none,
        created-by: tx-sender
      }
    )
    (map-set stage-transitions
      { batch-id: batch-id, stage: "production" }
      {
        timestamp: stacks-block-height,
        location: "factory",
        handler: tx-sender,
        notes: "Batch created and production initiated"
      }
    )
    (ok true)))

;; Update stage in supply chain
(define-public (update-stage
  (batch-id (string-ascii 20))
  (new-stage (string-ascii 20))
  (location (string-ascii 100))
  (notes (string-ascii 200)))
  (let ((record (unwrap! (map-get? supply-chain-records { batch-id: batch-id }) err-not-found)))
    (asserts! (default-to false (get authorized (map-get? authorized-handlers { handler: tx-sender }))) err-unauthorized)
    (map-set supply-chain-records
      { batch-id: batch-id }
      (merge record { current-stage: new-stage, current-location: location })
    )
    (map-set stage-transitions
      { batch-id: batch-id, stage: new-stage }
      {
        timestamp: stacks-block-height,
        location: location,
        handler: tx-sender,
        notes: notes
      }
    )
    (ok true)))

;; Set final destination
(define-public (set-final-destination
  (batch-id (string-ascii 20))
  (destination (string-ascii 100)))
  (let ((record (unwrap! (map-get? supply-chain-records { batch-id: batch-id }) err-not-found)))
    (asserts! (is-eq tx-sender (get manufacturer record)) err-unauthorized)
    (map-set supply-chain-records
      { batch-id: batch-id }
      (merge record { final-destination: (some destination) })
    )
    (ok true)))

;; Authorize supply chain handler
(define-public (authorize-handler 
  (handler principal)
  (role (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set authorized-handlers
      { handler: handler }
      { authorized: true, role: role }
    )
    (ok true)))

;; Get supply chain record
(define-read-only (get-batch-record (batch-id (string-ascii 20)))
  (map-get? supply-chain-records { batch-id: batch-id }))

;; Get stage transition details
(define-read-only (get-stage-transition 
  (batch-id (string-ascii 20))
  (stage (string-ascii 20)))
  (map-get? stage-transitions { batch-id: batch-id, stage: stage }))

;; Check if handler is authorized
(define-read-only (is-handler-authorized (handler principal))
  (default-to false (get authorized (map-get? authorized-handlers { handler: handler }))))

;; Get handler role
(define-read-only (get-handler-role (handler principal))
  (get role (map-get? authorized-handlers { handler: handler })))

;; Track batch current status
(define-read-only (get-batch-status (batch-id (string-ascii 20)))
  (match (map-get? supply-chain-records { batch-id: batch-id })
    record (ok {
      stage: (get current-stage record),
      location: (get current-location record),
      manufacturer: (get manufacturer record)
    })
    err-not-found))