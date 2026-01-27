import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import webhookRoutes from './routes/webhook.routes';
import incomingWebhookRoutes from './routes/incoming-webhook.routes';

dotenv.config();

const app = express();
const PORT = process.env.BACKEND_PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    service: 'Backend API',
    version: '2.0.0',
    timestamp: new Date().toISOString()
  });
});

// API endpoints
app.get('/api/status', (req, res) => {
  res.json({
    success: true,
    services: {
      backend: 'running',
      deafauth: 'running',
      pinksync: 'running',
      fibonrose: 'running',
      accessibility: 'running',
      ai: 'running',
    }
  });
});

// Webhook routes
app.use('/api/webhooks', webhookRoutes);
app.use('/api/incoming-webhooks', incomingWebhookRoutes);

// Start server
app.listen(PORT, () => {
  console.log(`Backend API running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
  console.log(`Webhook API: http://localhost:${PORT}/api/webhooks`);
  console.log(`Incoming Webhooks: http://localhost:${PORT}/api/incoming-webhooks`);
});

export default app;
