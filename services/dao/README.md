# MBTQ DAO - Governance

Decentralized governance and community management for the MBTQ Universe.

## Overview

The MBTQ DAO provides decentralized governance for the MBTQ Universe platform, enabling community-driven decision-making and transparent proposal management.

## API Endpoints

**Base URL:** `https://api.mbtq.dev

**Note:** The endpoints below show full paths for clarity. In the OpenAPI specification, these are defined as relative paths (e.g., `/proposals`) with the base URL specified in the `servers` section.

### Governance

- `GET /dao/proposals` - List governance proposals
- `POST /dao/vote` - Submit vote
- `GET /dao/members` - List DAO members

## Features

- Decentralized proposal creation and voting
- Transparent governance process
- Community member management
- On-chain voting records
- Multi-signature support for critical decisions

## Environment Variables

```bash
# DAO Configuration
DAO_GOVERNANCE_ADDRESS=0x...
DAO_VOTING_PERIOD=604800
DAO_QUORUM_PERCENTAGE=51
DAO_PROPOSAL_THRESHOLD=1000
DAO_NETWORK=mainnet
```

## Proposal Schema

```json
{
  "id": "prop-001",
  "title": "Improve Accessibility Features",
  "description": "Proposal to enhance ASL support across all services",
  "status": "active"
}
```

## Voting Process

1. Proposal creation (requires threshold of tokens)
2. Community review period
3. Voting period (default 7 days)
4. Quorum check
5. Execution if approved

## Governance Parameters

- **Voting Period**: 7 days (configurable)
- **Quorum**: 51% of total votes
- **Proposal Threshold**: 1000 tokens
- **Execution Delay**: 2 days after approval

## OpenAPI Specification

See [openapi/openapi.yaml](openapi/openapi.yaml) for the complete API specification.

## Integration with Fibonrose

The DAO uses Fibonrose for blockchain recording of all votes and proposals, ensuring transparency and immutability.
