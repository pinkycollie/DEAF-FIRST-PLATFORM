# DEAF-FIRST Platform

A deaf-first SaaS ecosystem with AI-powered workflows and comprehensive accessibility features.

🌐 **[View Live Demo on GitHub Pages](https://pinkycollie.github.io/DEAF-FIRST-PLATFORM/)**

## Overview

The DEAF-FIRST Platform is a monorepo containing multiple services designed with accessibility as the primary focus. It includes authentication, real-time synchronization, AI workflows, and specialized accessibility nodes.

The platform features a modern, cutting-edge showcase interface that demonstrates all services and capabilities. See [GITHUB-PAGES-SETUP.md](./GITHUB-PAGES-SETUP.md) for deployment details.

## Architecture

This is a monorepo managed with npm workspaces containing:

- **frontend**: React-based accessible user interface
- **backend**: Express API server
- **services/deafauth**: DeafAUTH authentication service with MCP server support
- **services/pinksync**: Real-time synchronization service
- **services/fibonrose**: Mathematical optimization engine
- **services/accessibility-nodes**: Modular accessibility features
- **ai**: AI services for deaf-first workflows

## Prerequisites

- Node.js >= 20.0.0
- npm >= 10.0.0
- PostgreSQL (for backend and deafauth)
- Redis (for pinksync)

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/pinkycollie/Deaf-First-Platform.git
cd Deaf-First-Platform
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Run all services in development mode:
```bash
npm run dev
```

## Development Scripts

### Run all services
```bash
npm run dev
```

### Run individual services
```bash
npm run dev:frontend    # Frontend only
npm run dev:backend     # Backend only
npm run dev:deafauth    # DeafAUTH only
npm run dev:pinksync    # PinkSync only
npm run dev:fibonrose   # FibonRose only
npm run dev:a11y        # Accessibility nodes only
```

### Build
```bash
npm run build           # Build all workspaces
```

### Testing
```bash
npm run test            # Run all tests
npm run test:e2e        # Run end-to-end tests
```

### Code Quality
```bash
npm run lint            # Lint all workspaces
npm run format          # Format code with Prettier
npm run type-check      # TypeScript type checking
```

### Database
```bash
npm run db:setup        # Setup databases
npm run db:migrate      # Run migrations
npm run db:seed         # Seed databases
```

### Docker
```bash
npm run docker:up       # Start all services with Docker
npm run docker:down     # Stop Docker services
npm run docker:logs     # View Docker logs
npm run build:docker    # Build Docker images
```

## Webhook System

The platform includes a comprehensive webhook system for real-time event notifications:

```bash
# Start backend with webhook support
npm run dev:backend

# Access webhook API at http://localhost:3000/api/webhooks
```

**Features:**
- Register and manage webhooks via REST API
- Receive webhooks from external services (Xano, Stripe, etc.)
- HMAC-SHA256 signature verification
- 12 predefined event types (user, auth, document, accessibility, sync, AI)
- Webhook delivery tracking and history
- Test endpoints for development

**Documentation:**
- [Quick Start Guide](./QUICKSTART-WEBHOOKS.md) - Get started in minutes
- [API Reference](./WEBHOOK-API.md) - Complete API documentation
- [Migration Guide](./WEBHOOK-MIGRATION-GUIDE.md) - Migrate from Xano

## MCP Server Support

The platform includes Model Context Protocol (MCP) server support in several services:

- **DeafAUTH**: Authentication and user management
- **PinkSync**: Real-time data synchronization
- **FibonRose**: Mathematical optimization
- **Accessibility Nodes**: Accessibility features API
- **AI Services**: AI-powered workflows

To run MCP servers individually:
```bash
npm run mcp --workspace=services/deafauth
npm run mcp --workspace=services/pinksync
npm run mcp --workspace=services/fibonrose
npm run mcp --workspace=services/accessibility-nodes
npm run mcp --workspace=ai
```

## Workspaces

Each workspace is independently versioned and can be developed, tested, and deployed separately.

### Frontend (@deaf-first/frontend)
- React 18 with TypeScript
- Vite for fast development
- Accessible UI components
- Sign language support

### Backend (@deaf-first/backend)
- Express.js REST API
- PostgreSQL database
- JWT authentication
- RESTful endpoints

### DeafAUTH (@deaf-first/deafauth)
- Specialized authentication service
- Accessible authentication flows
- MCP server for auth operations
- User preference management

### PinkSync (@deaf-first/pinksync)
- Real-time WebSocket synchronization
- Redis-based pub/sub
- MCP server for sync operations
- Event-driven architecture

### FibonRose (@deaf-first/fibonrose)
- Mathematical optimization algorithms
- Fibonacci-based scheduling
- MCP server for optimization queries
- Performance analytics

### Accessibility Nodes (@deaf-first/accessibility-nodes)
- Modular accessibility features
- Sign language interpretation
- Visual accessibility enhancements
- MCP server for accessibility APIs

### AI Services (@deaf-first/ai)
- AI-powered workflows
- Natural language processing
- Sign language generation
- MCP server for AI operations

## Environment Variables

Create a `.env` file in the root directory:

```env
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/deafirst
DEAFAUTH_DATABASE_URL=postgresql://user:password@localhost:5432/deafauth

# Redis
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRY=7d

# Frontend
VITE_API_URL=http://localhost:3000
VITE_WS_URL=ws://localhost:3001

# Services
DEAFAUTH_PORT=3002
PINKSYNC_PORT=3003
FIBONROSE_PORT=3004
A11Y_PORT=3005
AI_PORT=3006

# AI Services
OPENAI_API_KEY=your-openai-key

# Webhook Configuration
WEBHOOK_SECRET=your-webhook-secret-key-here
XANO_WEBHOOK_SECRET=your-xano-webhook-secret
```

## Contributing

We welcome contributions! Please read our contributing guidelines before submitting PRs.

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Author

360 Magicians

## Keywords

- Deaf-first design
- Accessibility
- SaaS ecosystem
- AI workflows
- MCP server
- Real-time synchronization
- Sign language support
