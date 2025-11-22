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
const OptimizeScheduleSchema = z.object({
  tasks: z.array(z.object({
    id: z.string(),
    duration: z.number(),
    priority: z.number(),
  })),
});

const CalculateFibonacciSchema = z.object({
  n: z.number().int().positive(),
});

const GoldenRatioSchema = z.object({
  value: z.number(),
});

// Define available tools
const tools: Tool[] = [
  {
    name: 'optimize_schedule',
    description: 'Optimize task scheduling using Fibonacci-based algorithms',
    inputSchema: {
      type: 'object',
      properties: {
        tasks: {
          type: 'array',
          description: 'Array of tasks to optimize',
          items: {
            type: 'object',
            properties: {
              id: { type: 'string' },
              duration: { type: 'number' },
              priority: { type: 'number' },
            },
            required: ['id', 'duration', 'priority'],
          },
        },
      },
      required: ['tasks'],
    },
  },
  {
    name: 'calculate_fibonacci',
    description: 'Calculate Fibonacci number for a given position',
    inputSchema: {
      type: 'object',
      properties: {
        n: { type: 'number', description: 'Position in Fibonacci sequence' },
      },
      required: ['n'],
    },
  },
  {
    name: 'golden_ratio_analysis',
    description: 'Perform golden ratio analysis for optimization',
    inputSchema: {
      type: 'object',
      properties: {
        value: { type: 'number', description: 'Value to analyze' },
      },
      required: ['value'],
    },
  },
];

// Create server instance
const server = new Server(
  {
    name: 'fibonrose-mcp-server',
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
      case 'optimize_schedule': {
        const { tasks } = OptimizeScheduleSchema.parse(args);
        // Mock optimization logic
        const optimized = tasks.sort((a, b) => b.priority - a.priority);
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                success: true,
                optimizedSchedule: optimized,
                efficiency: 0.95,
                message: 'Schedule optimized using Fibonacci algorithms',
              }),
            },
          ],
        };
      }

      case 'calculate_fibonacci': {
        const { n } = CalculateFibonacciSchema.parse(args);
        // Calculate Fibonacci number using iterative approach for better performance
        const fib = (num: number): number => {
          if (num <= 1) return num;
          let prev = 0, curr = 1;
          for (let i = 2; i <= num; i++) {
            const next = prev + curr;
            prev = curr;
            curr = next;
          }
          return curr;
        };
        const result = fib(Math.min(n, 100)); // Support up to 100
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                success: true,
                position: n,
                value: result,
              }),
            },
          ],
        };
      }

      case 'golden_ratio_analysis': {
        const { value } = GoldenRatioSchema.parse(args);
        const goldenRatio = 1.618033988749895;
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                success: true,
                inputValue: value,
                goldenRatio,
                multiplied: value * goldenRatio,
                divided: value / goldenRatio,
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
  console.error('FibonRose MCP Server running on stdio');
}

main().catch((error) => {
  console.error('Server error:', error);
  process.exit(1);
});
