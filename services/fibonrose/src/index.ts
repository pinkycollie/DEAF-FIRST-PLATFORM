import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.FIBONROSE_PORT || 3004;

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    service: 'FibonRose',
    version: '2.0.0',
    timestamp: new Date().toISOString()
  });
});

// Optimization endpoints
app.post('/api/optimize/schedule', (req, res) => {
  const { tasks } = req.body;
  
  // Mock optimization logic
  const optimized = tasks.sort((a: any, b: any) => b.priority - a.priority);
  
  res.json({
    success: true,
    optimizedSchedule: optimized,
    efficiency: 0.95,
    message: 'Schedule optimized using Fibonacci algorithms',
  });
});

app.get('/api/fibonacci/:n', (req, res) => {
  const n = parseInt(req.params.n);
  
  // Calculate Fibonacci number
  const fib = (num: number): number => {
    if (num <= 1) return num;
    return fib(num - 1) + fib(num - 2);
  };
  
  const result = fib(Math.min(n, 30)); // Limit to avoid performance issues
  
  res.json({
    success: true,
    position: n,
    value: result,
  });
});

app.post('/api/golden-ratio', (req, res) => {
  const { value } = req.body;
  const goldenRatio = 1.618033988749895;
  
  res.json({
    success: true,
    inputValue: value,
    goldenRatio,
    multiplied: value * goldenRatio,
    divided: value / goldenRatio,
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`FibonRose service running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});

export default app;
