# DEAF-FIRST MCP Server Setup - Quick Start Guide

## What Has Been Created

This repository now contains a complete MCP (Model Context Protocol) server infrastructure for the DEAF-FIRST platform with 5 specialized services, a frontend, and a backend.

## Repository Structure

```
DEAF-FIRST-PLATFORM/
├── frontend/                    # React + Vite frontend
├── backend/                     # Express backend API
├── services/
│   ├── deafauth/               # Authentication service + MCP server
│   ├── pinksync/               # Real-time sync service + MCP server
│   ├── fibonrose/              # Optimization engine + MCP server
│   └── accessibility-nodes/    # Accessibility features + MCP server
├── ai/                         # AI services + MCP server
├── configs/deployment/         # Docker Compose configuration
├── package.json                # Root workspace configuration
├── mcp-config.json            # MCP servers configuration
├── README.md                   # Main documentation
├── MCP-SERVERS.md             # MCP server documentation
└── .env.example               # Environment variables template
```

## Quick Start

### 1. Install Dependencies
```bash
npm install
```

### 2. Set Up Environment
```bash
cp .env.example .env
# Edit .env with your configuration
```

### 3. Build All Services
```bash
npm run build
```

### 4. Run Development Environment
```bash
# Run all services
npm run dev

# Or run individual services
npm run dev:frontend
npm run dev:backend
npm run dev:deafauth
npm run dev:pinksync
npm run dev:fibonrose
npm run dev:a11y
```

## MCP Server Usage

### Running MCP Servers

Each service can be run as an MCP server:

```bash
# Build first
npm run build

# Run individual MCP servers
npm run mcp --workspace=services/deafauth
npm run mcp --workspace=services/pinksync
npm run mcp --workspace=services/fibonrose
npm run mcp --workspace=services/accessibility-nodes
npm run mcp --workspace=ai
```

### Testing MCP Servers

Use the included test script:

```bash
node test-mcp.mjs services/deafauth/dist/mcp-server.js
node test-mcp.mjs services/pinksync/dist/mcp-server.js
node test-mcp.mjs services/fibonrose/dist/mcp-server.js
node test-mcp.mjs services/accessibility-nodes/dist/mcp-server.js
node test-mcp.mjs ai/dist/mcp-server.js
```

### Claude Desktop Integration

Add to your Claude Desktop configuration:

**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "deafauth": {
      "command": "node",
      "args": ["/absolute/path/to/DEAF-FIRST-PLATFORM/services/deafauth/dist/mcp-server.js"]
    },
    "pinksync": {
      "command": "node",
      "args": ["/absolute/path/to/DEAF-FIRST-PLATFORM/services/pinksync/dist/mcp-server.js"]
    },
    "fibonrose": {
      "command": "node",
      "args": ["/absolute/path/to/DEAF-FIRST-PLATFORM/services/fibonrose/dist/mcp-server.js"]
    },
    "accessibility-nodes": {
      "command": "node",
      "args": ["/absolute/path/to/DEAF-FIRST-PLATFORM/services/accessibility-nodes/dist/mcp-server.js"]
    },
    "ai": {
      "command": "node",
      "args": ["/absolute/path/to/DEAF-FIRST-PLATFORM/ai/dist/mcp-server.js"]
    }
  }
}
```

## Available Services

### 1. DeafAUTH (Port 3002)
**Purpose**: Accessible authentication and user management

**MCP Tools**:
- `authenticate_user`: Login with username/password
- `create_user`: Create new user with accessibility preferences
- `get_user`: Retrieve user profile

**REST API**:
- `POST /api/auth/login`: User authentication
- `POST /api/auth/register`: User registration
- `GET /api/users/:userId`: Get user info

### 2. PinkSync (Port 3003)
**Purpose**: Real-time data synchronization

**MCP Tools**:
- `sync_data`: Synchronize data across channels
- `subscribe_channel`: Subscribe to sync channel
- `get_sync_status`: Get sync status

**REST API**:
- `POST /api/sync`: Sync data
- `GET /api/sync/status`: Get sync status
- WebSocket endpoint for real-time updates

### 3. FibonRose (Port 3004)
**Purpose**: Mathematical optimization engine

**MCP Tools**:
- `optimize_schedule`: Optimize task scheduling
- `calculate_fibonacci`: Calculate Fibonacci numbers (optimized O(n) algorithm)
- `golden_ratio_analysis`: Golden ratio calculations

**REST API**:
- `POST /api/optimize/schedule`: Schedule optimization
- `GET /api/fibonacci/:n`: Calculate Fibonacci
- `POST /api/golden-ratio`: Golden ratio analysis

### 4. Accessibility Nodes (Port 3005)
**Purpose**: Modular accessibility features

**MCP Tools**:
- `get_sign_language_interpretation`: Sign language for text (ASL/BSL/ISL)
- `apply_high_contrast`: Apply high contrast mode
- `simplify_text`: Text simplification
- `get_accessibility_recommendations`: Get WCAG recommendations

**REST API**:
- `POST /api/sign-language`: Get sign language interpretation
- `POST /api/high-contrast`: Apply high contrast
- `POST /api/simplify-text`: Simplify text
- `GET /api/recommendations/:contentType`: Get recommendations

### 5. AI Services (Port 3006)
**Purpose**: AI-powered workflows

**MCP Tools**:
- `process_text`: Summarize, translate, or simplify text
- `generate_content`: Generate accessible content
- `analyze_accessibility`: Analyze accessibility issues

**REST API**:
- `POST /api/process/text`: Process text with AI
- `POST /api/generate`: Generate content
- `POST /api/analyze/accessibility`: Analyze accessibility

### 6. Backend (Port 3000)
**Purpose**: Main backend API

**REST API**:
- `GET /health`: Health check
- `GET /api/status`: Service status

### 7. Frontend (Port 5173)
**Purpose**: React-based user interface

**Features**:
- Service overview dashboard
- Accessibility-first design
- Responsive layout

## Docker Deployment

```bash
# Build Docker images
npm run build:docker

# Start all services
npm run docker:up

# View logs
npm run docker:logs

# Stop all services
npm run docker:down
```

## Development Commands

```bash
# Development
npm run dev                  # Run all services
npm run dev:frontend         # Frontend only
npm run dev:backend          # Backend only
npm run dev:deafauth         # DeafAUTH only
npm run dev:pinksync         # PinkSync only
npm run dev:fibonrose        # FibonRose only
npm run dev:a11y             # Accessibility nodes only

# Building
npm run build                # Build all workspaces

# Testing
npm run test                 # Run all tests
npm run test:e2e             # End-to-end tests

# Code Quality
npm run lint                 # Lint code
npm run format               # Format with Prettier
npm run type-check           # TypeScript type checking

# Database
npm run db:setup             # Setup databases
npm run db:migrate           # Run migrations
npm run db:seed              # Seed data

# Cleanup
npm run clean                # Clean all artifacts
```

## Environment Variables

Key environment variables (see `.env.example` for complete list):

```env
# Databases
DATABASE_URL=postgresql://user:password@localhost:5432/deafirst
DEAFAUTH_DATABASE_URL=postgresql://user:password@localhost:5432/deafauth

# Redis
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRY=7d

# Service Ports
BACKEND_PORT=3000
DEAFAUTH_PORT=3002
PINKSYNC_PORT=3003
FIBONROSE_PORT=3004
A11Y_PORT=3005
AI_PORT=3006

# AI Services
OPENAI_API_KEY=your-api-key
```

## Key Features

✅ **Complete Monorepo**: npm workspaces with all services
✅ **MCP Protocol**: 5 MCP servers for programmatic access
✅ **TypeScript**: Full type safety across all services
✅ **REST APIs**: HTTP endpoints for all services
✅ **WebSocket**: Real-time communication (PinkSync)
✅ **Docker Ready**: Complete Docker Compose setup
✅ **Accessibility First**: All services designed with accessibility in mind
✅ **Documentation**: Comprehensive docs for all components
✅ **Testing**: Test infrastructure included
✅ **Production Ready**: Linting, type-checking, building all working

## Architecture Highlights

1. **Deaf-First Design**: All services prioritize accessibility
2. **MCP Integration**: Programmatic access via Model Context Protocol
3. **Microservices**: Independent, scalable services
4. **Type Safety**: TypeScript with strict mode everywhere
5. **Input Validation**: Zod schemas for all inputs
6. **Performance**: Optimized algorithms (e.g., O(n) Fibonacci)
7. **Real-time**: WebSocket support for live updates
8. **AI-Powered**: Integration-ready for AI services

## Next Steps

1. **Configure Environment**: Update `.env` with your settings
2. **Start Database**: Run PostgreSQL and Redis (or use Docker)
3. **Install Dependencies**: Run `npm install`
4. **Build Services**: Run `npm run build`
5. **Start Development**: Run `npm run dev`
6. **Test MCP Servers**: Use test script or integrate with Claude

## Documentation

- `README.md`: Main project documentation
- `MCP-SERVERS.md`: Detailed MCP server documentation
- `infrastructure.md`: Architecture overview
- `.env.example`: Environment configuration template

## Support

For issues or questions:
- Review the documentation files
- Check service logs
- Open an issue on GitHub

## License

MIT License - See LICENSE file

---

**Built by 360 Magicians**  
**DEAF-FIRST Platform v2.0.0**
