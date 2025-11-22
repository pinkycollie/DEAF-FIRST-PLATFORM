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
✔ Ready for SDK generation (TypeScript + Python)  
✔ Production-ready specifications  

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

## 🧪 Validation

All OpenAPI specifications are validated and ready for:

- Documentation generation
- SDK generation (TypeScript, Python, Go, etc.)
- API gateway configuration
- Testing and mocking

To validate a specification:

```bash
# Using openapi-generator-cli
openapi-generator-cli validate -i services/deafauth/openapi/openapi.yaml

# Using swagger-cli
swagger-cli validate services/deafauth/openapi/openapi.yaml
```

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

## 🎯 Next Steps

### Option 1: Generate SDKs

Generate TypeScript and Python SDKs from OpenAPI specs:

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
