# Fibonrose - Trust & Blockchain Layer

Decentralized trust and verification layer for the MBTQ Universe.

## Overview

Fibonrose provides blockchain-based trust, verification, and decentralized identity management for the MBTQ Universe platform.

## API Endpoints

**Base URL:** `https://api.mbtquniverse.com/blockchain`

**Note:** The endpoints below show full paths for clarity. In the OpenAPI specification, these are defined as relative paths (e.g., `/verify`) with the base URL specified in the `servers` section.

### Blockchain Operations

- `POST /blockchain/verify` - Verify blockchain transaction
- `GET /blockchain/trust-score` - Get trust score
- `POST /blockchain/record` - Record new transaction

## Features

- Blockchain transaction verification
- Trust score calculation and management
- Decentralized identity verification
- Immutable record keeping
- Smart contract integration

## Environment Variables

```bash
# Fibonrose Configuration
FIBONROSE_BLOCKCHAIN_NODE=https://trust.mbtq.dev
FIBONROSE_CONTRACT_ADDRESS=0x...
FIBONROSE_NETWORK=mainnet
FIBONROSE_GAS_LIMIT=300000
FIBONROSE_PRIVATE_KEY=your_private_key
```

## Transaction Schema

```json
{
  "txId": "0x123456789abcdef",
  "timestamp": "2024-01-01T00:00:00Z",
  "payload": {
    "type": "verification",
    "data": {}
  }
}
```

## Trust Score

The trust score is calculated based on:

- Transaction history
- Verification completions
- Community reputation
- Time on platform

## OpenAPI Specification

See [openapi/openapi.yaml](openapi/openapi.yaml) for the complete API specification.

## Security

- All transactions are cryptographically signed
- Private keys are stored in secure hardware modules
- Multi-signature support for critical operations
- Audit trail for all blockchain interactions
