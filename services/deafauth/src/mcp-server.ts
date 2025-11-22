#!/usr/bin/env node
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  Tool,
} from '@modelcontextprotocol/sdk/types.js';
import { z } from 'zod';

// Tool schemas
const AuthenticateUserSchema = z.object({
  username: z.string(),
  password: z.string(),
});

const CreateUserSchema = z.object({
  username: z.string(),
  password: z.string(),
  email: z.string().email(),
  accessibilityPreferences: z.object({
    signLanguage: z.boolean().optional(),
    highContrast: z.boolean().optional(),
    largeText: z.boolean().optional(),
  }).optional(),
});

const GetUserSchema = z.object({
  userId: z.string(),
});

// Define available tools
const tools: Tool[] = [
  {
    name: 'authenticate_user',
    description: 'Authenticate a user with username and password',
    inputSchema: {
      type: 'object',
      properties: {
        username: { type: 'string', description: 'User username' },
        password: { type: 'string', description: 'User password' },
      },
      required: ['username', 'password'],
    },
  },
  {
    name: 'create_user',
    description: 'Create a new user account with accessibility preferences',
    inputSchema: {
      type: 'object',
      properties: {
        username: { type: 'string', description: 'Unique username' },
        password: { type: 'string', description: 'User password' },
        email: { type: 'string', description: 'User email address' },
        accessibilityPreferences: {
          type: 'object',
          description: 'User accessibility preferences',
          properties: {
            signLanguage: { type: 'boolean', description: 'Enable sign language support' },
            highContrast: { type: 'boolean', description: 'Enable high contrast mode' },
            largeText: { type: 'boolean', description: 'Enable large text mode' },
          },
        },
      },
      required: ['username', 'password', 'email'],
    },
  },
  {
    name: 'get_user',
    description: 'Get user information by user ID',
    inputSchema: {
      type: 'object',
      properties: {
        userId: { type: 'string', description: 'User ID' },
      },
      required: ['userId'],
    },
  },
];

// Create server instance
const server = new Server(
  {
    name: 'deafauth-mcp-server',
    version: '2.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return { tools };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case 'authenticate_user': {
        const { username, password } = AuthenticateUserSchema.parse(args);
        // Mock authentication logic
        const authenticated = username && password;
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                success: authenticated,
                message: authenticated ? 'Authentication successful' : 'Authentication failed',
                token: authenticated ? 'mock-jwt-token-' + Date.now() : null,
              }),
            },
          ],
        };
      }

      case 'create_user': {
        const userData = CreateUserSchema.parse(args);
        // Mock user creation logic
        const userId = 'user-' + Date.now();
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                success: true,
                userId,
                message: 'User created successfully',
                user: {
                  id: userId,
                  username: userData.username,
                  email: userData.email,
                  accessibilityPreferences: userData.accessibilityPreferences || {
                    signLanguage: false,
                    highContrast: false,
                    largeText: false,
                  },
                },
              }),
            },
          ],
        };
      }

      case 'get_user': {
        const { userId } = GetUserSchema.parse(args);
        // Mock user retrieval logic
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                success: true,
                user: {
                  id: userId,
                  username: 'mock-user',
                  email: 'user@example.com',
                  accessibilityPreferences: {
                    signLanguage: true,
                    highContrast: false,
                    largeText: true,
                  },
                },
              }),
            },
          ],
        };
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    if (error instanceof z.ZodError) {
      throw new Error(`Invalid arguments: ${error.message}`);
    }
    throw error;
  }
});

// Start server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('DeafAUTH MCP Server running on stdio');
}

main().catch((error) => {
  console.error('Server error:', error);
  process.exit(1);
});
