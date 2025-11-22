# MCP Server Documentation

## Overview

The DEAF-FIRST Platform includes five Model Context Protocol (MCP) servers that provide programmatic access to various services through a standardized interface.

## Available MCP Servers

### 1. DeafAUTH MCP Server
**Service**: Authentication and User Management  
**Location**: `services/deafauth/dist/mcp-server.js`

#### Tools

- **authenticate_user**: Authenticate a user with username and password
  - Input: `username` (string), `password` (string)
  - Output: Authentication token and user info

- **create_user**: Create a new user account with accessibility preferences
  - Input: `username` (string), `password` (string), `email` (string), `accessibilityPreferences` (object)
  - Output: User ID and profile

- **get_user**: Get user information by user ID
  - Input: `userId` (string)
  - Output: User profile with accessibility preferences

#### Usage Example
```bash
# Build and run
npm run build --workspace=services/deafauth
node services/deafauth/dist/mcp-server.js
```

---

### 2. PinkSync MCP Server
**Service**: Real-time Data Synchronization  
**Location**: `services/pinksync/dist/mcp-server.js`

#### Tools

- **sync_data**: Synchronize data across connected clients
  - Input: `channel` (string), `data` (object)
  - Output: Sync confirmation with timestamp

- **subscribe_channel**: Subscribe to a synchronization channel
  - Input: `channel` (string)
  - Output: Subscription ID

- **get_sync_status**: Get current synchronization status
  - Input: None
  - Output: Connection status and metrics

#### Usage Example
```bash
npm run build --workspace=services/pinksync
node services/pinksync/dist/mcp-server.js
```

---

### 3. FibonRose MCP Server
**Service**: Mathematical Optimization Engine  
**Location**: `services/fibonrose/dist/mcp-server.js`

#### Tools

- **optimize_schedule**: Optimize task scheduling using Fibonacci-based algorithms
  - Input: `tasks` (array of {id, duration, priority})
  - Output: Optimized schedule with efficiency score

- **calculate_fibonacci**: Calculate Fibonacci number for a given position
  - Input: `n` (number)
  - Output: Fibonacci value at position n

- **golden_ratio_analysis**: Perform golden ratio analysis for optimization
  - Input: `value` (number)
  - Output: Golden ratio calculations

#### Usage Example
```bash
npm run build --workspace=services/fibonrose
node services/fibonrose/dist/mcp-server.js
```

---

### 4. Accessibility Nodes MCP Server
**Service**: Modular Accessibility Features  
**Location**: `services/accessibility-nodes/dist/mcp-server.js`

#### Tools

- **get_sign_language_interpretation**: Get sign language interpretation for text
  - Input: `text` (string), `language` (ASL/BSL/ISL)
  - Output: Video URL and gesture sequence

- **apply_high_contrast**: Apply high contrast accessibility to content
  - Input: `content` (string), `level` (low/medium/high)
  - Output: Enhanced content with color scheme

- **simplify_text**: Simplify complex text for better accessibility
  - Input: `text` (string), `level` (1-5)
  - Output: Simplified text with readability score

- **get_accessibility_recommendations**: Get accessibility recommendations
  - Input: `contentType` (web/document/video)
  - Output: Recommendations and WCAG level

#### Usage Example
```bash
npm run build --workspace=services/accessibility-nodes
node services/accessibility-nodes/dist/mcp-server.js
```

---

### 5. AI MCP Server
**Service**: AI-Powered Workflows  
**Location**: `ai/dist/mcp-server.js`

#### Tools

- **process_text**: Process text using AI (summarize, translate, or simplify)
  - Input: `text` (string), `operation` (summarize/translate/simplify)
  - Output: Processed text with confidence score

- **generate_content**: Generate accessible content using AI
  - Input: `prompt` (string), `type` (text/image/video)
  - Output: Generated content URL

- **analyze_accessibility**: Analyze content for accessibility issues
  - Input: `content` (string), `contentType` (string)
  - Output: Accessibility analysis with recommendations

#### Usage Example
```bash
npm run build --workspace=ai
node ai/dist/mcp-server.js
```

---

## Configuration

### MCP Configuration File

The `mcp-config.json` file provides configuration for all MCP servers:

```json
{
  "mcpServers": {
    "deafauth": {
      "command": "node",
      "args": ["services/deafauth/dist/mcp-server.js"],
      "description": "DeafAUTH - Accessible authentication service"
    },
    // ... other servers
  }
}
```

### Environment Variables

Each MCP server may require specific environment variables:

**DeafAUTH**:
- `DEAFAUTH_DATABASE_URL`: PostgreSQL connection string

**PinkSync**:
- `REDIS_URL`: Redis connection string

**AI Services**:
- `OPENAI_API_KEY`: OpenAI API key for AI operations

## Running MCP Servers

### Build All Services
```bash
npm run build
```

### Run Individual MCP Server
```bash
# DeafAUTH
npm run mcp --workspace=services/deafauth

# PinkSync
npm run mcp --workspace=services/pinksync

# FibonRose
npm run mcp --workspace=services/fibonrose

# Accessibility Nodes
npm run mcp --workspace=services/accessibility-nodes

# AI Services
npm run mcp --workspace=ai
```

### Run with MCP Client

MCP servers communicate via stdio. To use them with an MCP client:

```javascript
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';

const transport = new StdioClientTransport({
  command: 'node',
  args: ['services/deafauth/dist/mcp-server.js']
});

const client = new Client({
  name: 'my-client',
  version: '1.0.0',
}, {
  capabilities: {}
});

await client.connect(transport);

// List available tools
const tools = await client.listTools();

// Call a tool
const result = await client.callTool({
  name: 'authenticate_user',
  arguments: {
    username: 'user@example.com',
    password: 'password123'
  }
});
```

## Integration with Claude Desktop

To use these MCP servers with Claude Desktop, add the following to your Claude configuration:

**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`  
**Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "deafauth": {
      "command": "node",
      "args": ["/path/to/DEAF-FIRST-PLATFORM/services/deafauth/dist/mcp-server.js"]
    },
    "pinksync": {
      "command": "node",
      "args": ["/path/to/DEAF-FIRST-PLATFORM/services/pinksync/dist/mcp-server.js"]
    },
    "fibonrose": {
      "command": "node",
      "args": ["/path/to/DEAF-FIRST-PLATFORM/services/fibonrose/dist/mcp-server.js"]
    },
    "accessibility-nodes": {
      "command": "node",
      "args": ["/path/to/DEAF-FIRST-PLATFORM/services/accessibility-nodes/dist/mcp-server.js"]
    },
    "ai": {
      "command": "node",
      "args": ["/path/to/DEAF-FIRST-PLATFORM/ai/dist/mcp-server.js"]
    }
  }
}
```

## Development

### Adding a New Tool

To add a new tool to an MCP server:

1. Define the tool schema in the tools array
2. Implement the tool handler in the CallToolRequestSchema handler
3. Add input validation using Zod
4. Return properly formatted responses

Example:
```typescript
const tools: Tool[] = [
  {
    name: 'my_new_tool',
    description: 'Description of what this tool does',
    inputSchema: {
      type: 'object',
      properties: {
        param1: { type: 'string', description: 'Parameter description' }
      },
      required: ['param1']
    }
  }
];

// In the handler
case 'my_new_tool': {
  const { param1 } = MyToolSchema.parse(args);
  // Tool implementation
  return {
    content: [
      {
        type: 'text',
        text: JSON.stringify({ result: 'success' })
      }
    ]
  };
}
```

### Testing MCP Servers

Test MCP servers by running them and sending test inputs:

```bash
# Build the server
npm run build --workspace=services/deafauth

# Run in test mode (manual testing via stdio)
echo '{"method":"tools/list","id":1}' | node services/deafauth/dist/mcp-server.js
```

## Troubleshooting

### Server won't start
- Ensure all dependencies are installed: `npm install`
- Build the project: `npm run build`
- Check environment variables are set correctly

### Tool not found
- Verify the tool name matches exactly
- Check that the server has been built recently
- Review the server logs for errors

### Connection issues
- Ensure the server is running
- Check that the client is using the correct transport
- Verify file paths in configuration

## Architecture

Each MCP server:
1. Uses the `@modelcontextprotocol/sdk` for standardized communication
2. Implements stdio transport for IPC
3. Validates inputs using Zod schemas
4. Returns structured JSON responses
5. Handles errors gracefully

## Security Considerations

- Never expose sensitive credentials in MCP configuration
- Use environment variables for secrets
- Validate all inputs before processing
- Implement rate limiting for production use
- Log all MCP operations for audit trails

## Support

For issues or questions:
- Check the main README.md
- Review the infrastructure.md for architecture details
- Open an issue on GitHub

## License

MIT License - See LICENSE file for details
