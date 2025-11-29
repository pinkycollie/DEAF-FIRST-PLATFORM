# MBTQ Deaf-First Platform

A comprehensive platform built with deaf-first principles, providing accessible financial services, AI-powered assistance, and decentralized governance.

## 📚 MBTQ Universe Components

This repository contains OpenAPI specifications for all five core services of the MBTQ Universe:

### 1. **DeafAUTH - Identity Cortex**
Secure authentication system designed with deaf-first principles.

- **Location**: `services/deafauth/`
- **Base URL**: `https://api.mbtquniverse.com/auth`
- **Documentation**: [DeafAUTH README](services/deafauth/README.md)
- **OpenAPI Spec**: [openapi.yaml](services/deafauth/openapi/openapi.yaml)

### 2. **PinkSync - Accessibility Engine**
Real-time accessibility features and synchronization.

- **Location**: `services/pinksync/`
- **Base URL**: `https://api.mbtquniverse.com/sync`
- **Documentation**: [PinkSync README](services/pinksync/README.md)
- **OpenAPI Spec**: [openapi.yaml](services/pinksync/openapi/openapi.yaml)

### 3. **Fibonrose - Trust & Blockchain**
Decentralized trust and verification layer.

- **Location**: `services/fibonrose/`
- **Base URL**: `https://api.mbtquniverse.com/blockchain`
- **Documentation**: [Fibonrose README](services/fibonrose/README.md)
- **OpenAPI Spec**: [openapi.yaml](services/fibonrose/openapi/openapi.yaml)

### 4. **360Magicians - AI Agents**
Intelligent automation and assistance agents.

- **Location**: `services/magicians/`
- **Base URL**: `https://api.mbtquniverse.com/ai`
- **Documentation**: [360Magicians README](services/magicians/README.md)
- **OpenAPI Spec**: [openapi.yaml](services/magicians/openapi/openapi.yaml)

### 5. **MBTQ DAO - Governance**
Decentralized governance and community management.

- **Location**: `services/dao/`
- **Base URL**: `https://api.mbtquniverse.com/dao`
- **Documentation**: [DAO README](services/dao/README.md)
- **OpenAPI Spec**: [openapi.yaml](services/dao/openapi/openapi.yaml)

## 🚀 Features

✔ All endpoints documented with OpenAPI 3.1  
✔ Standardized responses across all services  
✔ Shared DeafAUTH security scheme  
✔ Tags, components, pagination, error schemas  
✔ Cloudflare-friendly JSON-only style  
✔ **Automated API testing with Jest**  
✔ **SDK generation (TypeScript + Python)**  
✔ **Interactive HTML documentation**  
✔ **Fetch API examples for browsers**  
✔ **Architecture documentation**  
✔ Production-ready specifications  

## 📖 Documentation

### Quick Links

- **[Architecture Documentation](docs/ARCHITECTURE.md)** - System architecture, service relationships, and data flows
- **[Fetch API Examples](docs/FETCH-API-EXAMPLES.md)** - Browser-compatible API examples
- **[SDK Guide](SDK.md)** - TypeScript & Python SDK generation
- **[Interactive HTML Docs](docs/html/index.html)** - Interactive API documentation (run `npm run docs:serve` to view)
- **[Quick Start Guide](QUICKSTART.md)** - Get up and running quickly

### Generate HTML Documentation

```bash
npm run generate:docs     # Generate interactive HTML docs
npm run docs:serve        # Serve docs at http://localhost:3000
```

## 🔐 Authentication

All MBTQ Universe services use DeafAUTH for authentication. Include the Bearer token in the Authorization header:

```bash
Authorization: Bearer <your_token>
```

### Getting Started with Authentication

1. Register a new user:
```bash
curl -X POST https://api.mbtquniverse.com/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "secure_password"}'
```

2. Login to get tokens:
```bash
curl -X POST https://api.mbtquniverse.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "secure_password"}'
```

3. Use the access token for API calls:
```bash
curl -X GET https://api.mbtquniverse.com/sync/status \
  -H "Authorization: Bearer <your_access_token>"
```

## 📦 API Endpoints Overview

**Note:** The endpoints below show full paths including the service prefix (e.g., `/auth/`, `/sync/`). In the OpenAPI specifications, these are defined as relative paths (e.g., `/register`, `/status`) with the base URL specified in the `servers` section.

### DeafAUTH Endpoints

- `POST /auth/register` - User registration
- `POST /auth/login` - User authentication
- `GET /auth/verify` - Token verification
- `POST /auth/refresh` - Token refresh

### PinkSync Endpoints

- `GET /sync/status` - Check synchronization status
- `POST /sync/preferences` - Update accessibility preferences
- `GET /sync/features` - List available accessibility features

### Fibonrose Endpoints

- `POST /blockchain/verify` - Verify blockchain transaction
- `GET /blockchain/trust-score` - Get trust score
- `POST /blockchain/record` - Record new transaction

### 360Magicians Endpoints

Comprehensive AI agent platform with 60+ endpoints including:

- Agent management (CRUD operations)
- Task execution and workflow orchestration
- Memory and context management
- File ingestion and RAG search
- Tool registration and management
- Scheduling and webhooks
- Analytics and cost tracking

See [360Magicians README](services/magicians/README.md) for complete endpoint list.

### DAO Endpoints

- `GET /dao/proposals` - List governance proposals
- `POST /dao/vote` - Submit vote
- `GET /dao/members` - List DAO members

## 🔧 Environment Configuration

Copy `.env.example` to `.env` and configure your environment variables:

```bash
cp .env.example .env
```

See [.env.example](.env.example) for all required configuration options.

## 🌐 Integration Notes

### Google API & AI SDKs

**Google Cloud Integration:**

- Google Cloud Vision API for visual accessibility features
- Google Speech-to-Text for real-time captioning
- Google Translate API for multi-language support
- PinkSync API acts as an API broker network for partners' APIs that enhance deaf accessibility

**AI SDK Integration:**

The platform uses multiple AI models for comprehensive coverage:

- **OpenAI**: GPT-4, GPT-4 Turbo for natural language processing
- **Anthropic**: Claude 3 for advanced reasoning
- **Google**: Gemini Pro for multimodal tasks
- **TensorFlow.js**: Client-side AI processing
- **Hugging Face Transformers**: Specialized accessibility models

## 🔄 Integration with Other Repositories

This platform integrates with several related repositories:

- [pinkycollie/pinksync](https://github.com/pinkycollie/pinksync) - Fastify-based accessibility engine
- [pinkycollie/deafauth-ecosystem](https://github.com/pinkycollie/deafauth-ecosystem) - Authentication ecosystem
- [pinkycollie/fibonrose](https://github.com/pinkycollie/fibonrose) - Blockchain trust layer
- [pinkycollie/pinkflow](https://github.com/pinkycollie/pinkflow) - Hub pipeline integrator

## 🧪 Testing & Validation

### Automated API Testing

Run comprehensive API tests for all services:

```bash
# Install dependencies
npm install

# Run all tests
npm test

# Run tests with coverage
npm run test:coverage

# Run specific service tests
npm test -- tests/deafauth
npm test -- tests/pinksync
npm test -- tests/magicians
```

See [tests/README.md](tests/README.md) for detailed testing documentation.

### OpenAPI Validation

Validate all OpenAPI specifications:

```bash
# Validate specs
npm run validate:openapi
```

All specifications are validated and ready for:

- Documentation generation
- SDK generation (TypeScript, Python, Go, etc.)
- API gateway configuration
- Testing and mocking

### SDK Generation

Generate client SDKs from OpenAPI specifications:

```bash
# Generate TypeScript SDK
npm run generate:sdk:typescript

# Generate Python SDK
npm run generate:sdk:python

# Generate all SDKs
npm run generate:sdk
```

Generated SDKs will be in the `sdks/` directory. See [SDK.md](SDK.md) for detailed documentation and usage examples.

## 📚 Middleware Examples

### DeafAUTH Middleware (Node.js/Express)

```javascript
const deafAuthMiddleware = async (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  try {
    const decoded = await verifyDeafAuthToken(token);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(403).json({ error: 'Invalid token' });
  }
};

module.exports = deafAuthMiddleware;
```

### PinkSync Middleware (Node.js/Express)

```javascript
const pinkSyncMiddleware = async (req, res, next) => {
  const userId = req.user?.id;
  
  if (userId) {
    const preferences = await getPinkSyncPreferences(userId);
    req.accessibilityPrefs = preferences;
  }
  
  next();
};

module.exports = pinkSyncMiddleware;
```

## 🎯 Quick Start for Developers

### 1. Clone and Install

```bash
# Clone the repository
git clone https://github.com/pinkycollie/DEAF-FIRST-PLATFORM.git
cd DEAF-FIRST-PLATFORM

# Install dependencies
npm install
```

### 2. Validate OpenAPI Specifications

```bash
npm run validate:openapi
```

### 3. Run Tests

```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage
```

### 4. Generate SDKs

```bash
# Generate TypeScript SDK
npm run generate:sdk:typescript

# Generate Python SDK
npm run generate:sdk:python
```

### 5. Use Generated SDKs

See [SDK.md](SDK.md) for usage examples with TypeScript and Python.

## 🎯 Next Steps

### Generate Documentation

Generate interactive API documentation:

```bash
# TypeScript SDK
openapi-generator-cli generate \
  -i services/deafauth/openapi/openapi.yaml \
  -g typescript-axios \
  -o sdks/typescript/deafauth

# Python SDK
openapi-generator-cli generate \
  -i services/deafauth/openapi/openapi.yaml \
  -g python \
  -o sdks/python/deafauth
```

### Option 2: Deploy with Cloudflare Workers

Each service can be deployed as a Cloudflare Worker for edge computing benefits.

### Option 3: Generate API Documentation

Use Redoc, Swagger UI, or other documentation tools to generate interactive API documentation.

### Option 4: Set Up CI/CD

Implement automated testing, validation, and deployment for all services.

## 📖 Additional Documentation

- [Complete Infrastructure Overview](infrastructure.md)
- Individual service README files in each service directory
- OpenAPI specifications in `services/*/openapi/openapi.yaml`

## 🤝 Contributing

Contributions are welcome! Please ensure all changes maintain accessibility standards and deaf-first principles.

## 📄 License

See LICENSE file for details.

## 🌟 Acknowledgments

Built with deaf-first principles and a commitment to accessibility for all.
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

360 Magicians

## Keywords

- Deaf-first design
- Accessibility
- SaaS ecosystem
- AI workflows
- MCP server
- Real-time synchronization
- Sign language support
