# DEAF-FIRST Platform

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
- **services/asl-biometrics**: ASL-based biometric verification for telehealth
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
npm run dev:frontend        # Frontend only
npm run dev:backend         # Backend only
npm run dev:deafauth        # DeafAUTH only
npm run dev:pinksync        # PinkSync only
npm run dev:fibonrose       # FibonRose only
npm run dev:a11y            # Accessibility nodes only
npm run dev:asl-biometrics  # ASL Biometrics service
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

### ASL Biometrics (@deaf-first/asl-biometrics)
- ASL-based biometric identity verification
- Hand motion detection and analysis
- Telehealth verification workflows
- Cost-optimized with browser-based detection (MediaPipe)
- HIPAA-aware data handling
- Free tier deployment ready (Vercel, Supabase, Railway)

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
ASL_BIOMETRICS_PORT=3007

# AI Services
OPENAI_API_KEY=your-openai-key

# ASL Biometrics (optional - for Supabase backend)
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-anon-key
BIOMETRIC_ENCRYPTION_KEY=your-encryption-key
```

## Free Tier Deployment

The platform is designed for cost-optimized deployment using free tier services:

### Recommended Stack
- **Frontend**: Vercel Free Tier
- **Backend Services**: Railway Free Tier
- **Database**: Supabase Free Tier (500MB)
- **Monitoring**: Uptime Robot Free Tier

### Deployment Configurations
See `configs/deployment/free-tier/` for:
- `vercel.json` - Vercel deployment configuration
- `railway.toml` - Railway deployment configuration  
- `supabase-setup.md` - Supabase database schema and setup
- `uptime-robot-setup.md` - Monitoring configuration

## Legal Compliance

Privacy policy and data protection templates are provided in the `legal/` directory:
- `PRIVACY_POLICY_TEMPLATE.md` - Customizable privacy policy
- `BIOMETRIC_DATA_PROTECTION_AGREEMENT.md` - Biometric data handling agreement

These templates are designed for HIPAA, GDPR, and biometric data protection compliance.

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
- ASL biometrics
- Telehealth verification
