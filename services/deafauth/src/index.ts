import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.DEAFAUTH_PORT || 3002;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    service: 'DeafAUTH',
    version: '2.0.0',
    timestamp: new Date().toISOString()
  });
});

// Authentication endpoints
app.post('/api/auth/login', (req, res) => {
  const { username, password } = req.body;
  
  // Mock authentication logic
  if (username && password) {
    res.json({
      success: true,
      token: 'mock-jwt-token-' + Date.now(),
      user: {
        id: 'user-' + Date.now(),
        username,
      }
    });
  } else {
    res.status(401).json({
      success: false,
      message: 'Invalid credentials'
    });
  }
});

app.post('/api/auth/register', (req, res) => {
  const { username, password, email, accessibilityPreferences } = req.body;
  
  // Mock registration logic
  res.status(201).json({
    success: true,
    user: {
      id: 'user-' + Date.now(),
      username,
      email,
      accessibilityPreferences: accessibilityPreferences || {
        signLanguage: false,
        highContrast: false,
        largeText: false,
      }
    }
  });
});

app.get('/api/users/:userId', (req, res) => {
  const { userId } = req.params;
  
  // Mock user retrieval
  res.json({
    success: true,
    user: {
      id: userId,
      username: 'mock-user',
      email: 'user@example.com',
      accessibilityPreferences: {
        signLanguage: true,
        highContrast: false,
        largeText: true,
      }
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`DeafAUTH service running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});

export default app;
