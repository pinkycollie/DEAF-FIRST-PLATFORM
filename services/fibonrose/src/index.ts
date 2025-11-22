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
  const optimized = tasks.sort((a: { priority: number }, b: { priority: number }) => b.priority - a.priority);
  
  res.json({
    success: true,
    optimizedSchedule: optimized,
    efficiency: 0.95,
    message: 'Schedule optimized using Fibonacci algorithms',
  });
});

app.get('/api/fibonacci/:n', (req, res) => {
  const n = parseInt(req.params.n);
  
  // Calculate Fibonacci number using iterative approach
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
