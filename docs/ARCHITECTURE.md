# MBTQ Deaf-First Platform Architecture

## Overview

The MBTQ Deaf-First Platform is a comprehensive microservices architecture designed with accessibility as a core principle. This document describes the system architecture, component relationships, and data flows.

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           MBTQ Universe Platform                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                        Client Applications                           │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐ │    │
│  │  │   Web    │  │  Mobile  │  │ Desktop  │  │ Third-Party Clients  │ │    │
│  │  │  (React) │  │  (React  │  │ (Electron│  │   (SDK Consumers)    │ │    │
│  │  │          │  │  Native) │  │    )     │  │                      │ │    │
│  │  └────┬─────┘  └────┬─────┘  └────┬─────┘  └──────────┬───────────┘ │    │
│  └───────┼─────────────┼─────────────┼───────────────────┼─────────────┘    │
│          │             │             │                   │                   │
│          └─────────────┴─────────────┴───────────────────┘                   │
│                                    │                                         │
│                                    ▼                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                         API Gateway Layer                            │    │
│  │  ┌─────────────────────────────────────────────────────────────┐    │    │
│  │  │  • Rate Limiting  • CORS  • Request Validation  • Logging   │    │    │
│  │  │  • JWT Validation via DeafAUTH  • PinkSync Preference Load  │    │    │
│  │  └─────────────────────────────────────────────────────────────┘    │    │
│  └──────────────────────────────────┬──────────────────────────────────┘    │
│                                     │                                        │
│                                     ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                      Core Services Layer                             │    │
│  │                                                                      │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────────┐  │    │
│  │  │  DeafAUTH   │◄──►│  PinkSync   │◄──►│     360Magicians        │  │    │
│  │  │  (Identity) │    │(Accessibility│    │     (AI Agents)         │  │    │
│  │  │             │    │   Engine)   │    │                         │  │    │
│  │  │ • Register  │    │ • Status    │    │ • Agent Management      │  │    │
│  │  │ • Login     │    │ • Preferences│   │ • Execution Engine      │  │    │
│  │  │ • Verify    │    │ • Features  │    │ • Tools & Memory        │  │    │
│  │  │ • Refresh   │    │ • Events    │    │ • Workflows             │  │    │
│  │  └──────┬──────┘    └──────┬──────┘    └───────────┬─────────────┘  │    │
│  │         │                  │                       │                 │    │
│  │         │    ┌─────────────┴─────────────┐        │                 │    │
│  │         │    │                           │        │                 │    │
│  │         ▼    ▼                           ▼        ▼                 │    │
│  │  ┌─────────────┐                  ┌─────────────────────────┐      │    │
│  │  │  Fibonrose  │                  │          DAO            │      │    │
│  │  │ (Blockchain)│                  │     (Governance)        │      │    │
│  │  │             │                  │                         │      │    │
│  │  │ • Verify    │                  │ • Proposals             │      │    │
│  │  │ • Trust     │                  │ • Voting                │      │    │
│  │  │   Score     │                  │ • Members               │      │    │
│  │  │ • Record    │                  │                         │      │    │
│  │  └─────────────┘                  └─────────────────────────┘      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                      Data & Storage Layer                            │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐ │    │
│  │  │PostgreSQL│  │  Redis   │  │  Vector  │  │    Blockchain        │ │    │
│  │  │ (Primary │  │ (Cache & │  │   DB     │  │    (Fibonrose)       │ │    │
│  │  │  Store)  │  │ Sessions)│  │ (RAG)    │  │                      │ │    │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Service Components

### 1. DeafAUTH (Identity Cortex)
**Base URL:** `https://api.mbtquniverse.com/auth`

DeafAUTH is the central authentication and identity management service designed with deaf-first principles.

#### Responsibilities:
- User registration and authentication
- JWT token issuance and validation
- Token refresh and session management
- Multi-factor authentication support

#### Endpoints:
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/register` | Register new user |
| POST | `/login` | Authenticate user |
| GET | `/verify` | Verify JWT token |
| POST | `/refresh` | Refresh token pair |

### 2. PinkSync (Accessibility Engine)
**Base URL:** `https://api.mbtquniverse.com/sync`

PinkSync is the real-time accessibility synchronization engine that acts as an **event listener** for authenticated DeafAUTH users.

#### Key Features:
- **Event-Driven Architecture:** Listens for user authentication events from DeafAUTH
- **Real-time Preference Sync:** Synchronizes accessibility preferences across all client devices
- **Feature Discovery:** Provides available accessibility features based on user context

#### Event Flow:
```
User Login (DeafAUTH) 
    │
    ▼
PinkSync Event Listener
    │
    ├─► Load User Preferences
    │
    ├─► Initialize Accessibility Features
    │       │
    │       ├─► Captions (on/off)
    │       ├─► ASL Mode (on/off)
    │       ├─► High Contrast
    │       └─► Font Size
    │
    └─► Broadcast to Connected Clients
```

#### Endpoints:
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/status` | Check sync status |
| POST | `/preferences` | Update accessibility preferences |
| GET | `/features` | List available features |

### 3. Fibonrose (Trust & Blockchain Layer)
**Base URL:** `https://api.mbtquniverse.com/blockchain`

Fibonrose provides blockchain-based trust verification and transaction recording.

#### Endpoints:
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/verify` | Verify blockchain transaction |
| GET | `/trust-score` | Get trust score |
| POST | `/record` | Record new transaction |

### 4. 360Magicians (AI Agent Platform)
**Base URL:** `https://api.mbtquniverse.com/ai`

The comprehensive AI agent platform with 62 endpoints covering agent lifecycle, execution, tools, memory, and workflows.

#### Key Components:
- **Agents:** Create, manage, and clone AI agents
- **Execution:** Run agents, manage tasks, track runs
- **Tools:** Register and manage available tools
- **Memory:** Persistent memory and context management
- **Workflows:** DAG-based workflow orchestration

### 5. DAO (Governance)
**Base URL:** `https://api.mbtquniverse.com/dao`

Decentralized governance for platform decisions.

#### Endpoints:
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/proposals` | List proposals |
| POST | `/vote` | Submit vote |
| GET | `/members` | List DAO members |

## Authentication Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Authentication Flow                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   Client                DeafAUTH               PinkSync                  │
│     │                      │                      │                      │
│     │  1. POST /login      │                      │                      │
│     │  ────────────────►   │                      │                      │
│     │                      │                      │                      │
│     │  2. JWT Tokens       │                      │                      │
│     │  ◄────────────────   │                      │                      │
│     │                      │                      │                      │
│     │  3. Store tokens     │                      │                      │
│     │  ───────────┐        │                      │                      │
│     │             │        │                      │                      │
│     │  ◄──────────┘        │                      │                      │
│     │                      │                      │                      │
│     │  4. GET /status (with JWT)                  │                      │
│     │  ──────────────────────────────────────────►│                      │
│     │                      │                      │                      │
│     │                      │  5. Validate JWT     │                      │
│     │                      │◄─────────────────────│                      │
│     │                      │                      │                      │
│     │                      │  6. User valid       │                      │
│     │                      │─────────────────────►│                      │
│     │                      │                      │                      │
│     │  7. Accessibility preferences + status      │                      │
│     │  ◄──────────────────────────────────────────│                      │
│     │                      │                      │                      │
└─────────────────────────────────────────────────────────────────────────┘
```

## PinkSync as Event Listener

PinkSync operates as an event listener that targets authenticated DeafAUTH users. Here's how it works:

### Event Types

```javascript
// PinkSync Event Types
const PINKSYNC_EVENTS = {
  // Authentication Events (from DeafAUTH)
  USER_AUTHENTICATED: 'deafauth:user:authenticated',
  USER_LOGGED_OUT: 'deafauth:user:logged_out',
  TOKEN_REFRESHED: 'deafauth:token:refreshed',
  
  // Preference Events
  PREFERENCES_UPDATED: 'pinksync:preferences:updated',
  PREFERENCES_SYNCED: 'pinksync:preferences:synced',
  
  // Feature Events
  FEATURE_ENABLED: 'pinksync:feature:enabled',
  FEATURE_DISABLED: 'pinksync:feature:disabled',
  
  // Accessibility Events
  CAPTIONS_TOGGLED: 'pinksync:accessibility:captions',
  ASL_MODE_TOGGLED: 'pinksync:accessibility:asl',
  CONTRAST_CHANGED: 'pinksync:accessibility:contrast',
  FONT_SIZE_CHANGED: 'pinksync:accessibility:fontSize'
};
```

### Event Listener Implementation

```javascript
// Client-side PinkSync integration
class PinkSyncClient {
  constructor(deafAuthToken) {
    this.token = deafAuthToken;
    this.eventSource = null;
    this.listeners = new Map();
  }
  
  // Connect to PinkSync event stream
  connect() {
    this.eventSource = new EventSource(
      `https://api.mbtquniverse.com/sync/events?token=${this.token}`
    );
    
    this.eventSource.onmessage = (event) => {
      const data = JSON.parse(event.data);
      this.emit(data.type, data.payload);
    };
    
    this.eventSource.onerror = (error) => {
      console.error('PinkSync connection error:', error);
      this.reconnect();
    };
  }
  
  // Listen for specific events
  on(eventType, callback) {
    if (!this.listeners.has(eventType)) {
      this.listeners.set(eventType, []);
    }
    this.listeners.get(eventType).push(callback);
  }
  
  // Emit events to listeners
  emit(eventType, payload) {
    const callbacks = this.listeners.get(eventType) || [];
    callbacks.forEach(cb => cb(payload));
  }
}

// Usage
const pinkSync = new PinkSyncClient(accessToken);
pinkSync.connect();

pinkSync.on('pinksync:preferences:updated', (preferences) => {
  applyAccessibilitySettings(preferences);
});
```

## Integration with PinkFlow

PinkFlow serves as the workflow orchestration layer that coordinates between services. Here's how it integrates:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         PinkFlow Integration                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌─────────────────┐                                                    │
│   │    PinkFlow     │◄────────────────────────────────────────────────┐  │
│   │  (Orchestrator) │                                                 │  │
│   └────────┬────────┘                                                 │  │
│            │                                                          │  │
│            ▼                                                          │  │
│   ┌────────────────────────────────────────────────────────────────┐  │  │
│   │                    Workflow Pipeline                            │  │  │
│   │                                                                 │  │  │
│   │  ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐        │  │  │
│   │  │ Auth    │──►│ Sync    │──►│ Process │──►│ Record  │        │  │  │
│   │  │(DeafAUTH│   │(PinkSync│   │(360Magic│   │(Fibonros│        │  │  │
│   │  │   )     │   │   )     │   │  ians)  │   │   e)    │        │  │  │
│   │  └─────────┘   └─────────┘   └─────────┘   └─────────┘        │  │  │
│   │       │             │             │             │              │  │  │
│   │       ▼             ▼             ▼             ▼              │  │  │
│   │  ┌─────────────────────────────────────────────────────────┐  │  │  │
│   │  │              Event Bus (Real-time Updates)               │──┼──┘  │
│   │  └─────────────────────────────────────────────────────────┘  │     │
│   │                                                                │     │
│   └────────────────────────────────────────────────────────────────┘     │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Security Considerations

### JWT Token Flow
- All services validate JWT tokens via DeafAUTH
- Tokens include user preferences for personalized accessibility
- Refresh tokens have extended validity for uninterrupted sessions

### API Security
- All endpoints require Bearer token authentication
- Rate limiting protects against abuse
- CORS configured for allowed origins only

## Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    Cloudflare Workers Deployment                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                    Cloudflare Edge Network                       │   │
│   │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │   │
│   │  │ Worker:  │  │ Worker:  │  │ Worker:  │  │ Worker:  │        │   │
│   │  │ DeafAUTH │  │ PinkSync │  │ Fibonrose│  │ 360Magic │        │   │
│   │  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │   │
│   │       │             │             │             │               │   │
│   │       └─────────────┴─────────────┴─────────────┘               │   │
│   │                           │                                      │   │
│   │                    ┌──────┴──────┐                              │   │
│   │                    │  Worker:    │                              │   │
│   │                    │    DAO      │                              │   │
│   │                    └─────────────┘                              │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│   Connected to:                                                          │
│   - Cloudflare D1 (SQLite) for data                                     │
│   - Cloudflare KV for caching                                           │
│   - Durable Objects for real-time sync                                  │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Next Steps

1. **SDK Integration:** Use generated SDKs for client applications
2. **Documentation:** Visit `/docs` for interactive API documentation
3. **Testing:** Run `npm test` to validate all endpoints
4. **Deployment:** Deploy to Cloudflare Workers using provided scripts

---

For more details, see:
- [SDK Documentation](../SDK.md)
- [API Testing Guide](../tests/README.md)
- [Quick Start Guide](../QUICKSTART.md)
