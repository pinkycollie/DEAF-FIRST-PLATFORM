# Fetch API Examples

This document provides browser-compatible Fetch API examples for all MBTQ Universe services. These examples work in modern browsers and can be used directly in web applications.

## Table of Contents

1. [DeafAUTH (Authentication)](#deafauth-authentication)
2. [PinkSync (Accessibility)](#pinksync-accessibility)
3. [Fibonrose (Blockchain)](#fibonrose-blockchain)
4. [360Magicians (AI Agents)](#360magicians-ai-agents)
5. [DAO (Governance)](#dao-governance)
6. [Complete Client Example](#complete-client-example)

---

## DeafAUTH (Authentication)

### Register New User

```javascript
async function registerUser(email, password) {
  const response = await fetch('https://api.mbtquniverse.com/auth/register', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      email: email,
      password: password
    })
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'Registration failed');
  }

  return await response.json();
}

// Usage
try {
  const user = await registerUser('user@example.com', 'SecurePass123!');
  console.log('User registered:', user);
} catch (error) {
  console.error('Registration error:', error.message);
}
```

### Login User

```javascript
async function loginUser(email, password) {
  const response = await fetch('https://api.mbtquniverse.com/auth/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      email: email,
      password: password
    })
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'Login failed');
  }

  const tokens = await response.json();
  
  // Store tokens securely
  localStorage.setItem('accessToken', tokens.accessToken);
  localStorage.setItem('refreshToken', tokens.refreshToken);
  
  return tokens;
}

// Usage
try {
  const tokens = await loginUser('user@example.com', 'SecurePass123!');
  console.log('Login successful, token expires in:', tokens.expiresIn, 'seconds');
} catch (error) {
  console.error('Login error:', error.message);
}
```

### Verify Token

```javascript
async function verifyToken() {
  const accessToken = localStorage.getItem('accessToken');
  
  const response = await fetch('https://api.mbtquniverse.com/auth/verify', {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  });

  if (!response.ok) {
    return { valid: false };
  }

  return await response.json();
}

// Usage
const verification = await verifyToken();
if (verification.valid) {
  console.log('Token is valid');
} else {
  console.log('Token is invalid or expired');
}
```

### Refresh Tokens

```javascript
async function refreshTokens() {
  const refreshToken = localStorage.getItem('refreshToken');
  
  const response = await fetch('https://api.mbtquniverse.com/auth/refresh', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      refreshToken: refreshToken
    })
  });

  if (!response.ok) {
    // Refresh failed, user needs to login again
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    throw new Error('Session expired, please login again');
  }

  const tokens = await response.json();
  
  // Update stored tokens
  localStorage.setItem('accessToken', tokens.accessToken);
  localStorage.setItem('refreshToken', tokens.refreshToken);
  
  return tokens;
}
```

---

## PinkSync (Accessibility)

### Check Sync Status

```javascript
async function getSyncStatus() {
  const accessToken = localStorage.getItem('accessToken');
  
  const response = await fetch('https://api.mbtquniverse.com/sync/status', {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  });

  if (!response.ok) {
    throw new Error('Failed to get sync status');
  }

  return await response.json();
}

// Usage
const status = await getSyncStatus();
console.log('PinkSync Online:', status.online);
console.log('Latency:', status.latencyMs, 'ms');
```

### Update Accessibility Preferences

```javascript
async function updatePreferences(preferences) {
  const accessToken = localStorage.getItem('accessToken');
  
  const response = await fetch('https://api.mbtquniverse.com/sync/preferences', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(preferences)
  });

  if (!response.ok) {
    throw new Error('Failed to update preferences');
  }

  return await response.json();
}

// Usage
const prefs = await updatePreferences({
  captions: true,
  aslMode: true,
  contrast: 'high',
  fontSize: 'large'
});
console.log('Preferences updated:', prefs);
```

### List Available Features

```javascript
async function getFeatures() {
  const accessToken = localStorage.getItem('accessToken');
  
  const response = await fetch('https://api.mbtquniverse.com/sync/features', {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  });

  if (!response.ok) {
    throw new Error('Failed to get features');
  }

  return await response.json();
}

// Usage
const features = await getFeatures();
features.forEach(feature => {
  console.log(`${feature.name}: ${feature.description}`);
});
```

---

## Fibonrose (Blockchain)

### Verify Transaction

```javascript
async function verifyTransaction(txId) {
  const accessToken = localStorage.getItem('accessToken');
  
  const response = await fetch('https://api.mbtquniverse.com/blockchain/verify', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ txId })
  });

  if (!response.ok) {
    throw new Error('Failed to verify transaction');
  }

  return await response.json();
}

// Usage
const verification = await verifyTransaction('0x123456789abcdef');
console.log('Transaction valid:', verification.valid);
```

### Get Trust Score

```javascript
async function getTrustScore() {
  const accessToken = localStorage.getItem('accessToken');
  
  const response = await fetch('https://api.mbtquniverse.com/blockchain/trust-score', {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  });

  if (!response.ok) {
    throw new Error('Failed to get trust score');
  }

  return await response.json();
}

// Usage
const score = await getTrustScore();
console.log('Trust Score:', score.score);
console.log('Last Updated:', score.lastUpdated);
```

### Record Transaction

```javascript
async function recordTransaction(transaction) {
  const accessToken = localStorage.getItem('accessToken');
  
  const response = await fetch('https://api.mbtquniverse.com/blockchain/record', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(transaction)
  });

  if (!response.ok) {
    throw new Error('Failed to record transaction');
  }

  return await response.json();
}

// Usage
const tx = await recordTransaction({
  txId: '0xnew_transaction_id',
  timestamp: new Date().toISOString(),
  payload: {
    type: 'verification',
    data: { verified: true }
  }
});
console.log('Transaction recorded:', tx);
```

---

## 360Magicians (AI Agents)

### Create Agent

```javascript
async function createAgent(name, model) {
  const accessToken = localStorage.getItem('accessToken');
  
  const response = await fetch('https://api.mbtquniverse.com/ai/agents', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ name, model })
  });

  if (!response.ok) {
    throw new Error('Failed to create agent');
  }

  return await response.json();
}

// Usage
const agent = await createAgent('My AI Assistant', 'gpt-4');
console.log('Agent created:', agent.id);
```

### List Agents

```javascript
async function listAgents() {
  const accessToken = localStorage.getItem('accessToken');
  
  const response = await fetch('https://api.mbtquniverse.com/ai/agents', {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  });

  if (!response.ok) {
    throw new Error('Failed to list agents');
  }

  return await response.json();
}

// Usage
const agents = await listAgents();
agents.forEach(agent => {
  console.log(`Agent: ${agent.name} (${agent.model})`);
});
```

### Execute Agent

```javascript
async function executeAgent(agentId, input) {
  const accessToken = localStorage.getItem('accessToken');
  
  const response = await fetch(`https://api.mbtquniverse.com/ai/agents/${agentId}/execute`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ input })
  });

  if (!response.ok) {
    throw new Error('Failed to execute agent');
  }

  return await response.json();
}

// Usage
const run = await executeAgent('agent_123', 'Analyze this document for accessibility issues');
console.log('Run ID:', run.id);
console.log('Status:', run.status);
console.log('Output:', run.output);
```

### Get Run Status

```javascript
async function getRunStatus(runId) {
  const accessToken = localStorage.getItem('accessToken');
  
  const response = await fetch(`https://api.mbtquniverse.com/ai/runs/${runId}`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  });

  if (!response.ok) {
    throw new Error('Failed to get run status');
  }

  return await response.json();
}

// Poll for completion
async function waitForCompletion(runId, maxAttempts = 30) {
  for (let i = 0; i < maxAttempts; i++) {
    const status = await getRunStatus(runId);
    
    if (status.status === 'completed') {
      return status;
    }
    
    if (status.status === 'failed') {
      throw new Error('Run failed');
    }
    
    // Wait 1 second before polling again
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
  
  throw new Error('Run timed out');
}
```

### List Available Tools

```javascript
async function listTools() {
  const accessToken = localStorage.getItem('accessToken');
  
  const response = await fetch('https://api.mbtquniverse.com/ai/tools', {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  });

  if (!response.ok) {
    throw new Error('Failed to list tools');
  }

  return await response.json();
}

// Usage
const tools = await listTools();
tools.forEach(tool => {
  console.log(`Tool: ${tool.name} - ${tool.description}`);
});
```

---

## DAO (Governance)

### List Proposals

```javascript
async function listProposals() {
  const accessToken = localStorage.getItem('accessToken');
  
  const response = await fetch('https://api.mbtquniverse.com/dao/proposals', {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  });

  if (!response.ok) {
    throw new Error('Failed to list proposals');
  }

  return await response.json();
}

// Usage
const proposals = await listProposals();
proposals.forEach(proposal => {
  console.log(`${proposal.title} (${proposal.status})`);
  console.log(`  ${proposal.description}`);
});
```

### Submit Vote

```javascript
async function submitVote(proposalId, vote) {
  const accessToken = localStorage.getItem('accessToken');
  
  const response = await fetch('https://api.mbtquniverse.com/dao/vote', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ proposalId, vote })
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'Failed to submit vote');
  }

  return await response.json();
}

// Usage - vote can be 'yes', 'no', or 'abstain'
await submitVote('prop_123', 'yes');
console.log('Vote submitted successfully');
```

### List Members

```javascript
async function listMembers() {
  const accessToken = localStorage.getItem('accessToken');
  
  const response = await fetch('https://api.mbtquniverse.com/dao/members', {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  });

  if (!response.ok) {
    throw new Error('Failed to list members');
  }

  return await response.json();
}

// Usage
const members = await listMembers();
console.log(`Total DAO members: ${members.length}`);
```

---

## Complete Client Example

Here's a complete example of an MBTQ API client using the Fetch API:

```javascript
/**
 * MBTQ Universe API Client
 * Complete browser-compatible client using Fetch API
 */
class MBTQClient {
  constructor(baseUrl = 'https://api.mbtquniverse.com') {
    this.baseUrl = baseUrl;
    this.accessToken = localStorage.getItem('accessToken');
    this.refreshToken = localStorage.getItem('refreshToken');
  }

  // Helper method for making authenticated requests
  async request(endpoint, options = {}) {
    const url = `${this.baseUrl}${endpoint}`;
    const headers = {
      'Content-Type': 'application/json',
      ...options.headers
    };

    if (this.accessToken) {
      headers['Authorization'] = `Bearer ${this.accessToken}`;
    }

    const response = await fetch(url, {
      ...options,
      headers
    });

    // Handle token expiration
    if (response.status === 401 && this.refreshToken) {
      await this.refreshTokens();
      // Retry the request with new token
      headers['Authorization'] = `Bearer ${this.accessToken}`;
      return fetch(url, { ...options, headers });
    }

    return response;
  }

  // DeafAUTH Methods
  async register(email, password) {
    const response = await this.request('/auth/register', {
      method: 'POST',
      body: JSON.stringify({ email, password })
    });
    return response.json();
  }

  async login(email, password) {
    const response = await this.request('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password })
    });
    
    if (response.ok) {
      const tokens = await response.json();
      this.accessToken = tokens.accessToken;
      this.refreshToken = tokens.refreshToken;
      localStorage.setItem('accessToken', tokens.accessToken);
      localStorage.setItem('refreshToken', tokens.refreshToken);
      return tokens;
    }
    
    throw new Error('Login failed');
  }

  async refreshTokens() {
    const response = await fetch(`${this.baseUrl}/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken: this.refreshToken })
    });

    if (response.ok) {
      const tokens = await response.json();
      this.accessToken = tokens.accessToken;
      this.refreshToken = tokens.refreshToken;
      localStorage.setItem('accessToken', tokens.accessToken);
      localStorage.setItem('refreshToken', tokens.refreshToken);
      return tokens;
    }

    // Clear tokens and throw
    this.logout();
    throw new Error('Session expired');
  }

  logout() {
    this.accessToken = null;
    this.refreshToken = null;
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
  }

  // PinkSync Methods
  async getSyncStatus() {
    const response = await this.request('/sync/status');
    return response.json();
  }

  async updatePreferences(preferences) {
    const response = await this.request('/sync/preferences', {
      method: 'POST',
      body: JSON.stringify(preferences)
    });
    return response.json();
  }

  async getFeatures() {
    const response = await this.request('/sync/features');
    return response.json();
  }

  // Fibonrose Methods
  async verifyTransaction(txId) {
    const response = await this.request('/blockchain/verify', {
      method: 'POST',
      body: JSON.stringify({ txId })
    });
    return response.json();
  }

  async getTrustScore() {
    const response = await this.request('/blockchain/trust-score');
    return response.json();
  }

  // 360Magicians Methods
  async createAgent(name, model) {
    const response = await this.request('/ai/agents', {
      method: 'POST',
      body: JSON.stringify({ name, model })
    });
    return response.json();
  }

  async listAgents() {
    const response = await this.request('/ai/agents');
    return response.json();
  }

  async executeAgent(agentId, input) {
    const response = await this.request(`/ai/agents/${agentId}/execute`, {
      method: 'POST',
      body: JSON.stringify({ input })
    });
    return response.json();
  }

  // DAO Methods
  async listProposals() {
    const response = await this.request('/dao/proposals');
    return response.json();
  }

  async submitVote(proposalId, vote) {
    const response = await this.request('/dao/vote', {
      method: 'POST',
      body: JSON.stringify({ proposalId, vote })
    });
    return response.json();
  }
}

// Usage
const client = new MBTQClient();

// Login and use the API
async function main() {
  try {
    // Login
    await client.login('user@example.com', 'password');
    
    // Get accessibility preferences
    const status = await client.getSyncStatus();
    console.log('Sync status:', status);
    
    // Update preferences
    await client.updatePreferences({
      captions: true,
      aslMode: true
    });
    
    // Create an AI agent
    const agent = await client.createAgent('Accessibility Checker', 'gpt-4');
    console.log('Created agent:', agent);
    
    // Execute the agent
    const result = await client.executeAgent(agent.id, 'Check this page for accessibility');
    console.log('Agent result:', result);
    
  } catch (error) {
    console.error('Error:', error.message);
  }
}

main();
```

---

## Error Handling

All Fetch API examples should include proper error handling:

```javascript
async function safeApiCall(apiFunction) {
  try {
    return await apiFunction();
  } catch (error) {
    if (error.name === 'TypeError') {
      // Network error
      console.error('Network error - please check your connection');
    } else {
      console.error('API error:', error.message);
    }
    throw error;
  }
}

// Usage
const result = await safeApiCall(() => client.getSyncStatus());
```

---

## CORS Considerations

When making requests from a browser, ensure your domain is allowed by the API's CORS policy. Contact the API administrator if you receive CORS errors.

```javascript
// If you need to handle CORS errors
fetch(url, {
  method: 'POST',
  mode: 'cors', // Explicitly set CORS mode
  credentials: 'include', // Include cookies if needed
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(data)
});
```

---

For more information, see:
- [SDK Documentation](../SDK.md)
- [Architecture Documentation](./ARCHITECTURE.md)
- [OpenAPI Specifications](../services/)
