# DEAF-FIRST Platform

[![CI/CD Pipeline](https://github.com/pinkycollie/DEAF-FIRST-PLATFORM/actions/workflows/ci.yml/badge.svg)](https://github.com/pinkycollie/DEAF-FIRST-PLATFORM/actions/workflows/ci.yml)
[![Security Scanning](https://github.com/pinkycollie/DEAF-FIRST-PLATFORM/actions/workflows/security.yml/badge.svg)](https://github.com/pinkycollie/DEAF-FIRST-PLATFORM/actions/workflows/security.yml)
[![Deploy to GitHub Pages](https://github.com/pinkycollie/DEAF-FIRST-PLATFORM/actions/workflows/deploy.yml/badge.svg)](https://github.com/pinkycollie/DEAF-FIRST-PLATFORM/actions/workflows/deploy.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node Version](https://img.shields.io/badge/node-%3E%3D20.0.0-brightgreen)](https://nodejs.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.7-blue)](https://www.typescriptlang.org/)
[![Accessibility](https://img.shields.io/badge/WCAG-2.1%20AAA-green)](https://www.w3.org/WAI/WCAG21/quickref/)

A deaf-first SaaS ecosystem with AI-powered workflows and comprehensive accessibility features.

🌐 **[View Live Demo on GitHub Pages](https://pinkycollie.github.io/DEAF-FIRST-PLATFORM/)**

## Overview

The DEAF-FIRST Platform is a monorepo containing multiple services designed with accessibility as the primary focus. It includes authentication, real-time synchronization, AI workflows, and specialized accessibility nodes.

The platform features a modern, cutting-edge showcase interface that demonstrates all services and capabilities. See [GITHUB-PAGES-SETUP.md](./GITHUB-PAGES-SETUP.md) for deployment details.

### 🎯 Key Features

- **♿ Accessibility First**: WCAG 2.1 AAA compliant design throughout
- **🔐 Secure Authentication**: JWT-based auth with DeafAUTH service
- **🔄 Real-time Sync**: WebSocket-based synchronization with PinkSync
- **📊 AI-Powered**: OpenAI integration for intelligent workflows
- **🏗️ Microservices Architecture**: Independent, scalable services
- **🚀 CI/CD Pipeline**: Automated testing, security scans, and deployment
- **🐳 Docker Ready**: Full containerization support
- **☁️ Infrastructure as Code**: Terraform templates included
- **🤖 Autonomous Evolution**: RAG-based system powered by Vertex AI on GCP
- **🛡️ Deployment Gates**: Infrastructure completion checks prevent premature deployment

### 📚 Documentation

- **[Architecture](./ARCHITECTURE.md)** - Detailed system architecture and design
- **[Infrastructure Completion](./INFRASTRUCTURE-COMPLETION.md)** - Infrastructure readiness requirements
- **[Contributing Guide](./CONTRIBUTING.md)** - How to contribute to this project
- **[Quick Start](./QUICKSTART.md)** - Get up and running quickly
- **[GitHub Pages Setup](./GITHUB-PAGES-SETUP.md)** - Deploy the showcase site
- **[Webhook API](./WEBHOOK-API.md)** - Webhook system documentation
- **[MCP Servers](./MCP-SERVERS.md)** - Model Context Protocol integration
- **[Security](./SECURITY.md)** - Security policies and reporting

## Architecture

This is a monorepo managed with npm workspaces containing:

- **frontend**: React-based accessible user interface
- **backend**: Express API server
- **services/deafauth**: DeafAUTH authentication service with MCP server support (`/auth`)
- **services/pinksync**: Real-time synchronization service (`/sync`)
- **services/fibonrose**: Mathematical optimization engine (`/trust`)
- **services/accessibility-nodes**: Modular accessibility features
- **ai**: AI services for deaf-first workflows

### Core Official Services

The platform requires three official core services to be fully configured before deployment:

1. **DeafAUTH** (`/auth`) - Authentication and user management
2. **PinkSync** (`/sync`) - Real-time synchronization
3. **FibonRose** (`/trust`) - Trust scoring and optimization engine

**⚠️ Important**: No code will be pushed to production until the full infrastructure is completed and configured. See [Infrastructure Completion](./INFRASTRUCTURE-COMPLETION.md) for details.

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

# GCP Configuration (for Vertex AI and autonomous features)
GCP_PROJECT_ID=your-project-id
GCP_REGION=us-central1
VERTEX_AI_ENABLED=true
```

## Autonomous Platform Evolution

The DEAF-FIRST Platform is designed to evolve autonomously based on feedback from the deaf community:

### RAG (Retrieval-Augmented Generation) System

The platform uses Vertex AI on GCP to process community feedback and proposals:

- **Vector Store**: Vertex AI Matching Engine for semantic search
- **Embedding Model**: textembedding-gecko for context understanding
- **Generation Model**: Gemini Pro for proposal generation
- **Community Integration**: Automatic processing of feedback and suggestions

### Evolution Workflow

1. **Collect Feedback**: Continuous collection from deaf community
2. **Process with RAG**: Vertex AI analyzes feedback with historical context
3. **Generate Proposals**: AI creates improvement proposals
4. **Community Review**: Proposals are reviewed by the community
5. **Automatic Implementation**: Approved changes are implemented autonomously

### Distributed System

The platform operates as a distributed system:
- **Microservices**: DeafAUTH, PinkSync, FibonRose
- **Orchestration**: Kubernetes on GKE
- **Messaging**: Cloud Pub/Sub for event-driven communication
- **AI Integration**: Vertex AI for intelligent decision-making

For more details, see [Infrastructure Completion](./INFRASTRUCTURE-COMPLETION.md).

## Contributing

We welcome contributions! Please read our [CONTRIBUTING.md](./CONTRIBUTING.md) guide before submitting PRs.

### Quick Contribution Steps

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following our [code standards](./CONTRIBUTING.md#code-standards)
4. Run tests and linting (`npm run lint && npm run test`)
5. Commit your changes (`git commit -m 'feat: add amazing feature'`)
6. Push to your branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Guidelines

- Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification
- Maintain WCAG 2.1 AAA accessibility compliance
- Write tests for new features
- Update documentation as needed
- Ensure all CI checks pass

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
