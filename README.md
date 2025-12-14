# DEAF-FIRST Platform

[![CI](https://github.com/pinkycollie/DEAF-FIRST-PLATFORM/actions/workflows/ci.yml/badge.svg)](https://github.com/pinkycollie/DEAF-FIRST-PLATFORM/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node Version](https://img.shields.io/badge/node-%3E%3D20.0.0-brightgreen)](https://nodejs.org/)
[![NPM Version](https://img.shields.io/badge/npm-%3E%3D10.0.0-brightgreen)](https://www.npmjs.com/)

A deaf-first SaaS ecosystem with AI-powered workflows, comprehensive accessibility features, and a powerful generator for creating production-ready SaaS applications.

## 🚀 Overview

The DEAF-FIRST Platform is a comprehensive SaaS ecosystem designed with accessibility as the primary focus. It includes:

- **SaaS Generator**: Create production-ready SaaS applications with pre-configured integrations
- **Deaf UI Components**: Accessible React component library
- **Multiple Templates**: Basic, Advanced, and Enterprise templates
- **Integrated Services**: DeafAUTH, PinkSync, FibonRose, and AI Services
- **MCP Server Support**: Model Context Protocol servers for all services

## 📦 Packages

### Generator (`@deaf-first/generator`)
CLI tool for creating new SaaS applications with built-in integrations.

```bash
# Create a new project
npm run create -- create my-app --template advanced

# List available templates
npm run create -- templates

# Show platform info
npm run create -- info
```

### Deaf UI (`@deaf-first/deaf-ui`)
Accessible React component library with:
- Button, Input, Card, Modal, Alert components
- AccessibilityProvider for preference management
- AccessibilityToolbar for user-controlled accessibility settings
- Built-in WCAG 2.1 AA compliance

### Core (`@deaf-first/core`)
Service integration clients for:
- DeafAuthClient - Authentication service integration
- PinkSyncClient - Real-time synchronization
- FibonRoseClient - Mathematical optimization

## 🏗️ Architecture

This is a monorepo managed with npm workspaces:

```
DEAF-FIRST-PLATFORM/
├── frontend/                    # React frontend application
├── backend/                     # Express API server
├── services/
│   ├── deafauth/               # Authentication service + MCP server
│   ├── pinksync/               # Real-time sync service + MCP server
│   ├── fibonrose/              # Optimization engine + MCP server
│   └── accessibility-nodes/    # Accessibility features + MCP server
├── ai/                         # AI services + MCP server
├── packages/
│   ├── generator/              # SaaS application generator
│   ├── deaf-ui/                # Accessible UI component library
│   └── core/                   # Core utilities and service clients
└── configs/                    # Deployment configurations
```

## 🎨 Templates

### Basic Template
Simple SaaS starter with essential features:
- React frontend with Vite
- Express backend API
- DeafAUTH integration
- Deaf UI components
- Basic routing and authentication

### Advanced Template
Full-featured SaaS with all integrations:
- Everything in Basic
- PinkSync real-time sync
- FibonRose optimization
- WebSocket support
- Multi-page application

### Enterprise Template
Enterprise-grade SaaS:
- Everything in Advanced
- AI Services integration
- Multi-tenancy support
- Role-based access control
- Audit logging

## 🚀 Quick Start

### Create a New SaaS Application

```bash
# Install the generator globally
npm install -g @deaf-first/generator

# Create a new project
deaf-first-create create my-saas-app --template advanced

# Navigate to project
cd my-saas-app

# Install dependencies
npm install

# Start development
npm run dev
```

### Use the Platform Directly

```bash
# Clone the repository
git clone https://github.com/pinkycollie/Deaf-First-Platform.git
cd Deaf-First-Platform

# Install dependencies
npm install

# Build all packages
npm run build

# Run all services in development mode
npm run dev
```

## Prerequisites

- Node.js >= 20.0.0
- npm >= 10.0.0
- PostgreSQL (for backend and deafauth) - optional for development
- Redis (for pinksync) - optional for development

## 💻 Development Scripts

### Project Generator
```bash
npm run create -- create <project-name> [options]
npm run create -- templates              # List available templates
npm run create -- info                   # Show platform information
```

A deaf-first SaaS ecosystem with AI-powered workflows and comprehensive accessibility features.

## Overview

The DEAF-FIRST Platform is a monorepo containing multiple services designed with accessibility as the primary focus. It includes authentication, real-time synchronization, AI workflows, and specialized accessibility nodes.

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

Pinky Collie

## Keywords

- Deaf-first design
- Accessibility
- SaaS ecosystem
- AI workflows
- MCP server
- Real-time synchronization
- Sign language support
