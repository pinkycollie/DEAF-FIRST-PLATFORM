# Testing Documentation

This directory contains automated tests for the MBTQ Universe deaf-first platform APIs.

## Test Structure

```
tests/
├── deafauth/           # DeafAUTH (Identity Cortex) tests
├── pinksync/           # PinkSync (Accessibility Engine) tests
├── fibonrose/          # Fibonrose (Trust & Blockchain) tests
├── magicians/          # 360Magicians (AI Agents) tests
├── dao/                # DAO (Governance) tests
└── openapi.test.js     # OpenAPI specification validation tests
```

## Running Tests

### Install Dependencies

```bash
npm install
```

### Run All Tests

```bash
npm test
```

### Run Tests with Coverage

```bash
npm run test:coverage
```

### Run Tests in Watch Mode

```bash
npm run test:watch
```

### Run Specific Service Tests

```bash
# DeafAUTH tests
npm test -- tests/deafauth

# PinkSync tests
npm test -- tests/pinksync

# 360Magicians tests
npm test -- tests/magicians

# Fibonrose tests
npm test -- tests/fibonrose

# DAO tests
npm test -- tests/dao

# OpenAPI validation tests
npm test -- tests/openapi.test.js
```

## Test Coverage

The test suite covers:

### DeafAUTH (Identity Cortex)
- ✅ User registration
- ✅ User login
- ✅ Token verification
- ✅ Token refresh
- ✅ Error handling for invalid credentials
- ✅ Validation of email format

### PinkSync (Accessibility Engine)
- ✅ Sync status checking
- ✅ Accessibility preferences updates
- ✅ Feature listing
- ✅ Authentication requirements
- ✅ Preference validation

### Fibonrose (Trust & Blockchain)
- ✅ Transaction verification
- ✅ Trust score retrieval
- ✅ Transaction recording
- ✅ Transaction format validation
- ✅ Invalid transaction handling

### 360Magicians (AI Agent Platform)
- ✅ Agent creation
- ✅ Agent listing and retrieval
- ✅ Agent deletion
- ✅ Agent execution
- ✅ Run status tracking
- ✅ Tool management
- ✅ Memory operations
- ✅ Health checks

### DAO (Governance)
- ✅ Proposal listing
- ✅ Vote submission
- ✅ Member listing
- ✅ Vote validation
- ✅ Duplicate vote prevention
- ✅ Status filtering

### OpenAPI Specifications
- ✅ Valid OpenAPI 3.1.0 version
- ✅ Required info fields
- ✅ Server definitions
- ✅ Security schemes
- ✅ Path definitions
- ✅ Response descriptions
- ✅ Cross-service consistency

## Test Framework

- **Jest**: Testing framework
- **Axios**: HTTP client (mocked for unit tests)

## Writing New Tests

Follow the existing test patterns:

```javascript
describe('Service Name API', () => {
  const baseURL = 'https://api.mbtquniverse.com/service';
  const authToken = 'Bearer valid_token';

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('GET /endpoint', () => {
    it('should perform expected action', async () => {
      // Mock response
      const mockResponse = {
        data: { /* expected data */ }
      };

      axios.get.mockResolvedValue(mockResponse);

      // Make request
      const response = await axios.get(`${baseURL}/endpoint`, {
        headers: { Authorization: authToken }
      });

      // Assertions
      expect(response.data).toHaveProperty('expectedField');
    });
  });
});
```

## Continuous Integration

These tests are designed to run in CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run tests
  run: npm test

- name: Generate coverage
  run: npm run test:coverage
```

## Best Practices

1. **Mock External Dependencies**: All HTTP requests are mocked
2. **Test Error Scenarios**: Include negative test cases
3. **Clear Assertions**: Use descriptive expect statements
4. **Cleanup**: Use `beforeEach` to reset mocks
5. **Descriptive Names**: Use clear test descriptions

## Integration with OpenAPI

The tests are designed to match the OpenAPI specifications in `services/*/openapi/openapi.yaml`. When the specs change, update the corresponding tests.

## Validation Scripts

### Validate OpenAPI Specs

```bash
npm run validate:openapi
```

This validates all OpenAPI specifications for:
- Correct OpenAPI version
- Required fields
- Valid schemas
- Proper formatting

## SDK Generation

Generate SDKs from OpenAPI specs:

```bash
# Generate TypeScript SDK
npm run generate:sdk:typescript

# Generate Python SDK
npm run generate:sdk:python

# Generate all SDKs
npm run generate:sdk
```

Generated SDKs will be in the `sdks/` directory.
