# TileTrace Supply Chain Tracker

A blockchain-based supply chain tracking system for ceramic tiles from raw materials to final installation.

## Overview

TileTrace provides end-to-end traceability for ceramic tile batches, enabling manufacturers, distributors, and customers to track products through every stage of the supply chain with immutable records.

## Features

- **Batch Tracking**: Complete lifecycle tracking from production to installation
- **Stage Management**: Multi-stage supply chain with transition records
- **Authorization System**: Role-based access control for supply chain handlers
- **Location Tracking**: Real-time location updates throughout the supply chain
- **Quality Grading**: Quality grade assignment and tracking
- **Destination Management**: Final destination tracking and updates

## Supply Chain Stages

1. **Production**: Initial tile manufacturing
2. **Quality Control**: Quality inspection and grading
3. **Warehousing**: Storage and inventory management
4. **Distribution**: Shipping and logistics
5. **Retail**: Retail store or dealer inventory
6. **Installation**: Final customer installation

## Contract Functions

### Public Functions

- `create-batch-record`: Initialize a new batch with production details
- `update-stage`: Update batch stage and location in supply chain
- `set-final-destination`: Set the final destination for a batch
- `authorize-handler`: Authorize principals to handle supply chain updates

### Read-Only Functions

- `get-batch-record`: Retrieve complete batch information
- `get-stage-transition`: Get specific stage transition details
- `is-handler-authorized`: Check handler authorization status
- `get-handler-role`: Get handler's assigned role
- `get-batch-status`: Get current batch status and location

## Usage

```bash
# Create a new batch
(contract-call? .tile-supply-chain create-batch-record "BATCH001" "Premium Clay Mine, Italy" "A+")

# Update stage
(contract-call? .tile-supply-chain update-stage "BATCH001" "warehousing" "Distribution Center NY" "Quality control passed")

# Set destination
(contract-call? .tile-supply-chain set-final-destination "BATCH001" "Home Depot Store #1234")
```
