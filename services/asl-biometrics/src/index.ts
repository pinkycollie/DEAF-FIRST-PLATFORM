/**
 * ASL Biometrics Service
 * 
 * Cost-optimized ASL biometric system for telehealth verification.
 * Bootstrap-ready implementation with lean dependencies.
 */

import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';

import { MotionSequenceSchema } from './modules/hand-motion-detection.js';
import { getUserProfile, deleteUserBiometrics } from './modules/identity-matching.js';
import { generateVerificationChallenge, analyzeGesture } from './modules/motion-analysis.js';
import {
  initializeSession,
  enrollPatientBiometrics,
  verifyPatientIdentity,
  refreshChallenge,
  getSessionStatus,
  endSession,
  deletePatientData,
  getSessionStats,
} from './modules/telehealth-verification.js';

dotenv.config();

const app = express();
const PORT = process.env.ASL_BIOMETRICS_PORT || 3007;

// Middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "blob:"],
      mediaSrc: ["'self'", "blob:"],
    },
  },
}));
app.use(cors());
app.use(express.json({ limit: '10mb' })); // Allow larger payloads for motion data

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'ASL Biometrics',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    features: [
      'hand-motion-detection',
      'identity-matching',
      'motion-analysis',
      'telehealth-verification',
    ],
  });
});

// ============== Telehealth Verification API ==============

/**
 * Initialize a new telehealth verification session
 */
app.post('/api/telehealth/session', async (req, res) => {
  try {
    const { patientId, providerId, sessionType } = req.body;
    
    if (!patientId || !providerId) {
      return res.status(400).json({
        success: false,
        error: 'patientId and providerId are required',
      });
    }
    
    const result = await initializeSession(patientId, providerId, sessionType);
    res.status(201).json(result);
  } catch (error) {
    console.error('Session initialization error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to initialize session',
    });
  }
});

/**
 * Get session status
 */
app.get('/api/telehealth/session/:sessionId', (req, res) => {
  const { sessionId } = req.params;
  const status = getSessionStatus(sessionId);
  
  if (!status.found) {
    return res.status(404).json({
      success: false,
      error: 'Session not found',
    });
  }
  
  res.json({
    success: true,
    ...status,
  });
});

/**
 * Enroll patient biometrics
 */
app.post('/api/telehealth/session/:sessionId/enroll', async (req, res) => {
  try {
    const { sessionId } = req.params;
    const { motionSequence } = req.body;
    
    if (!motionSequence) {
      return res.status(400).json({
        success: false,
        error: 'motionSequence is required',
      });
    }
    
    const result = await enrollPatientBiometrics(sessionId, motionSequence);
    res.json(result);
  } catch (error) {
    console.error('Enrollment error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to enroll biometrics',
    });
  }
});

/**
 * Verify patient identity
 */
app.post('/api/telehealth/session/:sessionId/verify', async (req, res) => {
  try {
    const { sessionId } = req.params;
    const { motionSequence } = req.body;
    
    if (!motionSequence) {
      return res.status(400).json({
        success: false,
        error: 'motionSequence is required',
      });
    }
    
    const result = await verifyPatientIdentity(sessionId, motionSequence);
    res.json(result);
  } catch (error) {
    console.error('Verification error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to verify identity',
    });
  }
});

/**
 * Refresh verification challenge
 */
app.post('/api/telehealth/session/:sessionId/challenge', (req, res) => {
  const { sessionId } = req.params;
  const result = refreshChallenge(sessionId);
  
  if (!result.success) {
    return res.status(404).json(result);
  }
  
  res.json(result);
});

/**
 * End telehealth session
 */
app.delete('/api/telehealth/session/:sessionId', (req, res) => {
  const { sessionId } = req.params;
  const deleted = endSession(sessionId);
  
  res.json({
    success: deleted,
    message: deleted ? 'Session ended' : 'Session not found',
  });
});

// ============== Biometric Profile API ==============

/**
 * Get user biometric profile info
 */
app.get('/api/biometrics/profile/:userId', (req, res) => {
  const { userId } = req.params;
  const profile = getUserProfile(userId);
  
  if (!profile) {
    return res.status(404).json({
      success: false,
      error: 'User profile not found',
    });
  }
  
  res.json({
    success: true,
    profile,
  });
});

/**
 * Delete user biometric data (privacy compliance)
 */
app.delete('/api/biometrics/profile/:userId', (req, res) => {
  const { userId } = req.params;
  const result = deletePatientData(userId);
  res.json(result);
});

// ============== Motion Analysis API ==============

/**
 * Analyze a motion sequence (standalone)
 */
app.post('/api/motion/analyze', (req, res) => {
  try {
    const { motionSequence } = req.body;
    
    const parseResult = MotionSequenceSchema.safeParse(motionSequence);
    if (!parseResult.success) {
      return res.status(400).json({
        success: false,
        error: 'Invalid motion sequence',
        validationErrors: parseResult.error.errors.map(e => e.message),
      });
    }
    
    const analysis = analyzeGesture(parseResult.data);
    res.json({
      success: true,
      analysis,
    });
  } catch (error) {
    console.error('Motion analysis error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to analyze motion',
    });
  }
});

/**
 * Get a verification challenge (standalone)
 */
app.get('/api/motion/challenge', (req, res) => {
  const challenge = generateVerificationChallenge();
  res.json({
    success: true,
    challenge,
  });
});

// ============== Admin/Monitoring API ==============

/**
 * Get session statistics
 */
app.get('/api/admin/stats', (req, res) => {
  const stats = getSessionStats();
  res.json({
    success: true,
    stats,
    timestamp: new Date().toISOString(),
  });
});

// ============== Client SDK Info ==============

/**
 * Get client SDK information for browser-based detection
 */
app.get('/api/sdk/info', (req, res) => {
  res.json({
    success: true,
    sdk: {
      name: 'ASL Biometrics Client SDK',
      version: '1.0.0',
      dependencies: {
        mediapipe: {
          package: '@mediapipe/hands',
          cdn: 'https://cdn.jsdelivr.net/npm/@mediapipe/hands',
          purpose: 'Browser-based hand landmark detection',
        },
        camera: {
          package: '@mediapipe/camera_utils',
          cdn: 'https://cdn.jsdelivr.net/npm/@mediapipe/camera_utils',
          purpose: 'Camera access utilities',
        },
      },
      sampleCode: `
// Client-side hand detection setup
import { Hands } from '@mediapipe/hands';
import { Camera } from '@mediapipe/camera_utils';

const hands = new Hands({
  locateFile: (file) => \`https://cdn.jsdelivr.net/npm/@mediapipe/hands/\${file}\`
});

hands.setOptions({
  maxNumHands: 1,
  modelComplexity: 1,
  minDetectionConfidence: 0.7,
  minTrackingConfidence: 0.5,
});

// Collect frames and send to /api/telehealth/session/:id/verify
      `.trim(),
    },
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`ASL Biometrics service running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
  console.log(`API documentation: http://localhost:${PORT}/api/sdk/info`);
});

export default app;
