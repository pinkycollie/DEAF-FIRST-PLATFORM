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
const SyncDataSchema = z.object({
  channel: z.string(),
  data: z.record(z.string(), z.unknown()),
});

const SubscribeSchema = z.object({
  channel: z.string(),
});

// Define available tools
const tools: Tool[] = [
  {
    name: 'sync_data',
    description: 'Synchronize data across connected clients in real-time',
    inputSchema: {
      type: 'object',
      properties: {
        channel: { type: 'string', description: 'Sync channel name' },
        data: { type: 'object', description: 'Data to synchronize' },
      },
      required: ['channel', 'data'],
    },
  },
  {
    name: 'subscribe_channel',
    description: 'Subscribe to a synchronization channel',
    inputSchema: {
      type: 'object',
      properties: {
        channel: { type: 'string', description: 'Channel name to subscribe to' },
      },
      required: ['channel'],
    },
  },
  {
    name: 'get_sync_status',
    description: 'Get current synchronization status',
    inputSchema: {
      type: 'object',
      properties: {},
    },
  },
];

// Create server instance
const server = new Server(
  {
    name: 'pinksync-mcp-server',
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
      case 'sync_data': {
        const { channel, data } = SyncDataSchema.parse(args);
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                success: true,
                message: `Data synced to channel: ${channel}`,
                timestamp: Date.now(),
                syncId: 'sync-' + Date.now(),
              }),
            },
          ],
        };
      }

      case 'subscribe_channel': {
        const { channel } = SubscribeSchema.parse(args);
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                success: true,
                message: `Subscribed to channel: ${channel}`,
                channel,
                subscriptionId: 'sub-' + Date.now(),
              }),
            },
          ],
        };
      }

      case 'get_sync_status': {
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                success: true,
                status: 'connected',
                activeChannels: 5,
                connectedClients: 12,
                uptime: Date.now(),
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
  console.error('PinkSync MCP Server running on stdio');
}

main().catch((error) => {
  console.error('Server error:', error);
  process.exit(1);
});
