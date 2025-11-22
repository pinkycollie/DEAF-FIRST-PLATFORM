#!/usr/bin/env node

// Simple test script for MCP servers
import { spawn } from 'child_process';

const serverPath = process.argv[2];
if (!serverPath) {
  console.error('Usage: node test-mcp.mjs <path-to-mcp-server.js>');
  process.exit(1);
}

console.log(`Testing MCP Server: ${serverPath}`);

const server = spawn('node', [serverPath]);

// Send a list tools request
const listToolsRequest = JSON.stringify({
  jsonrpc: '2.0',
  id: 1,
  method: 'tools/list',
  params: {}
}) + '\n';

let output = '';

server.stdout.on('data', (data) => {
  output += data.toString();
  console.log('Server response:', data.toString());
});

server.stderr.on('data', (data) => {
  console.log('Server log:', data.toString());
});

server.on('close', (code) => {
  console.log(`Server exited with code ${code}`);
  if (output.includes('tools')) {
    console.log('✓ MCP Server is working!');
  } else {
    console.log('✗ MCP Server may have issues');
  }
});

// Give server time to start
setTimeout(() => {
  console.log('Sending list tools request...');
  server.stdin.write(listToolsRequest);
  
  // Give it time to respond then close
  setTimeout(() => {
    server.kill();
  }, 2000);
}, 1000);
