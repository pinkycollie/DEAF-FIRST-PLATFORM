# SDK Generation Guide

This guide explains how to generate client SDKs from the MBTQ Universe OpenAPI specifications.

## Overview

The MBTQ Universe platform provides automated SDK generation for multiple programming languages using the OpenAPI Generator. Currently supported languages:

- **TypeScript** (with Axios)
- **Python**

## Prerequisites

```bash
npm install
```

## Quick Start

### Generate All SDKs

```bash
npm run generate:sdk
```

This generates both TypeScript and Python SDKs for all services.

### Generate TypeScript SDK Only

```bash
npm run generate:sdk:typescript
```

Output: `sdks/typescript/`

### Generate Python SDK Only

```bash
npm run generate:sdk:python
```

Output: `sdks/python/`

## SDK Structure

Generated SDKs will be organized by service:

```
sdks/
├── typescript/
│   ├── deafauth/
│   ├── pinksync/
│   ├── fibonrose/
│   ├── magicians/
│   └── dao/
└── python/
    ├── deafauth/
    ├── pinksync/
    ├── fibonrose/
    ├── magicians/
    └── dao/
```

## Using Generated SDKs

### TypeScript/JavaScript

```typescript
// Import the generated SDK
import { DeafAuthApi, Configuration } from './sdks/typescript/deafauth';

// Configure the API client
const config = new Configuration({
  basePath: 'https://api.mbtquniverse.com/auth',
  accessToken: 'your_access_token'
});

const api = new DeafAuthApi(config);

// Use the API
async function login() {
  try {
    const response = await api.login({
      email: 'user@example.com',
      password: 'secure_password'
    });
    console.log('Login successful:', response.data);
  } catch (error) {
    console.error('Login failed:', error);
  }
}
```

### Python

```python
# Import the generated SDK
from mbtq_sdk.deafauth import DeafAuthApi, Configuration

# Configure the API client
config = Configuration(
    host='https://api.mbtquniverse.com/auth',
    access_token='your_access_token'
)

api = DeafAuthApi(config)

# Use the API
try:
    response = api.login({
        'email': 'user@example.com',
        'password': 'secure_password'
    })
    print('Login successful:', response)
except Exception as error:
    print('Login failed:', error)
```

## Service-Specific Examples

### DeafAUTH (Identity Cortex)

```typescript
// Register a new user
const user = await deafAuthApi.register({
  email: 'newuser@example.com',
  password: 'SecurePass123!'
});

// Login and get tokens
const tokens = await deafAuthApi.login({
  email: 'user@example.com',
  password: 'SecurePass123!'
});

// Verify token
const verification = await deafAuthApi.verify();

// Refresh tokens
const newTokens = await deafAuthApi.refresh({
  refreshToken: tokens.refreshToken
});
```

### PinkSync (Accessibility Engine)

```typescript
// Check sync status
const status = await pinkSyncApi.getStatus();

// Update preferences
const prefs = await pinkSyncApi.updatePreferences({
  captions: true,
  aslMode: true,
  contrast: 'high',
  fontSize: 'large'
});

// List features
const features = await pinkSyncApi.getFeatures();
```

### 360Magicians (AI Agent Platform)

```typescript
// Create an agent
const agent = await magiciansApi.createAgent({
  name: 'My AI Agent',
  model: 'gpt-4'
});

// Execute agent
const run = await magiciansApi.executeAgent(agent.id, {
  input: 'Analyze this document...'
});

// Get run status
const status = await magiciansApi.getRunStatus(run.id);

// List available tools
const tools = await magiciansApi.listTools();
```

### Fibonrose (Trust & Blockchain)

```typescript
// Verify transaction
const verification = await fibonroseApi.verifyTransaction({
  txId: '0x123456789abcdef'
});

// Get trust score
const score = await fibonroseApi.getTrustScore();

// Record transaction
const tx = await fibonroseApi.recordTransaction({
  txId: '0xnew_transaction',
  timestamp: new Date().toISOString(),
  payload: { type: 'verification', data: {} }
});
```

### DAO (Governance)

```typescript
// List proposals
const proposals = await daoApi.listProposals();

// Submit vote
await daoApi.submitVote({
  proposalId: 'prop_123',
  vote: 'yes'
});

// List members
const members = await daoApi.listMembers();
```

## Customization

### Modifying SDK Configuration

Edit `scripts/generate-sdk.js` to customize SDK generation:

```javascript
const SDK_CONFIGS = {
  typescript: {
    generator: 'typescript-axios',
    outputDir: 'typescript',
    additionalProps: {
      npmName: '@mbtq/sdk',
      npmVersion: '1.0.0',
      supportsES6: true,
      withSeparateModelsAndApi: true
    }
  },
  python: {
    generator: 'python',
    outputDir: 'python',
    additionalProps: {
      packageName: 'mbtq_sdk',
      projectName: 'mbtq-sdk',
      packageVersion: '1.0.0'
    }
  }
};
```

### Adding New Language Support

1. Add configuration to `SDK_CONFIGS` in `scripts/generate-sdk.js`
2. Run the generator with the new language name
3. Update this documentation

## Available Generators

OpenAPI Generator supports many languages:

- Java
- Go
- Ruby
- PHP
- Swift
- Kotlin
- C#
- Rust
- And many more...

See [OpenAPI Generator Docs](https://openapi-generator.tech/docs/generators/) for full list.

## Validation Before Generation

Always validate OpenAPI specs before generating SDKs:

```bash
npm run validate:openapi
```

This ensures the specs are valid and will generate correct SDKs.

## Troubleshooting

### "Command not found" error

Ensure dependencies are installed:
```bash
npm install
```

### SDK generation fails

1. Validate the OpenAPI spec first:
   ```bash
   npm run validate:openapi
   ```

2. Check the spec file exists:
   ```bash
   ls services/*/openapi/openapi.yaml
   ```

3. Ensure you have sufficient permissions to create directories

### Generated code has errors

1. Check the OpenAPI spec for correctness
2. Ensure all required fields are present
3. Verify response schemas are complete

## CI/CD Integration

Add SDK generation to your CI/CD pipeline:

```yaml
# GitHub Actions example
- name: Install dependencies
  run: npm install

- name: Validate OpenAPI specs
  run: npm run validate:openapi

- name: Generate SDKs
  run: npm run generate:sdk

- name: Upload SDKs
  uses: actions/upload-artifact@v3
  with:
    name: sdks
    path: sdks/
```

## Publishing SDKs

### TypeScript to npm

```bash
cd sdks/typescript/deafauth
npm publish
```

### Python to PyPI

```bash
cd sdks/python/deafauth
python setup.py sdist bdist_wheel
twine upload dist/*
```

## Support

For issues or questions:
- Check the OpenAPI specifications in `services/*/openapi/`
- Review the generation script in `scripts/generate-sdk.js`
- Consult [OpenAPI Generator documentation](https://openapi-generator.tech/)
