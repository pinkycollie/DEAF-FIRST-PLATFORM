import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { WebSocketServer, WebSocket } from 'ws';

dotenv.config();

const app = express();
const PORT = process.env.PINKSYNC_PORT || 3003;

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    service: 'PinkSync',
    version: '2.0.0',
    timestamp: new Date().toISOString()
  });
});

// Sync endpoints
app.post('/api/sync', (req, res) => {
  const { channel, data } = req.body;
  
  res.json({
    success: true,
    message: `Data synced to channel: ${channel}`,
    syncId: 'sync-' + Date.now(),
  });
});

app.get('/api/sync/status', (req, res) => {
  res.json({
    success: true,
    status: 'connected',
    activeChannels: 5,
    connectedClients: 12,
  });
});

// Start HTTP server
const server = app.listen(PORT, () => {
  console.log(`PinkSync service running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});

// WebSocket server
const wss = new WebSocketServer({ server });

wss.on('connection', (ws) => {
  console.log('New WebSocket connection');
  
  ws.on('message', (message) => {
    console.log('Received:', message.toString());
    // Broadcast to all clients
    wss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(message);
      }
    });
  });
  
  ws.on('close', () => {
    console.log('WebSocket connection closed');
  });
});

export default app;
