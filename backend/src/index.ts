import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';

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

// Start server
app.listen(PORT, () => {
  console.log(`Backend API running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});

export default app;
