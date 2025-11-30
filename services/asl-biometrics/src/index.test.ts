/**
 * ASL Biometrics Service Tests
 */

import { describe, it, expect } from 'vitest';
import {
  extractMotionFeatures,
  validateMotionQuality,
  HAND_LANDMARKS,
  calculateLandmarkDistance,
  type MotionSequence,
  type HandFrame,
} from './modules/hand-motion-detection.js';

// Helper to create mock hand landmarks
function createMockLandmarks(options: { spread?: number; z?: number } = {}): Array<{ x: number; y: number; z: number }> {
  const { spread = 0.1, z = 0 } = options;
  const landmarks: Array<{ x: number; y: number; z: number }> = [];
  
  // Generate 21 landmarks in a realistic hand pattern
  for (let i = 0; i < 21; i++) {
    landmarks.push({
      x: 0.5 + (Math.random() - 0.5) * spread,
      y: 0.5 + (Math.random() - 0.5) * spread,
      z: z + (Math.random() - 0.5) * 0.1,
    });
  }
  
  return landmarks;
}

// Helper to create mock hand frame
function createMockFrame(timestamp: number, options: { confidence?: number; handedness?: 'left' | 'right' } = {}): HandFrame {
  return {
    timestamp,
    handedness: options.handedness || 'right',
    landmarks: createMockLandmarks() as any,
    confidence: options.confidence || 0.9,
  };
}

// Helper to create mock motion sequence
function createMockSequence(frameCount: number, duration: number): MotionSequence {
  const startTime = Date.now();
  const frames: HandFrame[] = [];
  
  for (let i = 0; i < frameCount; i++) {
    const timestamp = startTime + (i * duration * 1000 / frameCount);
    frames.push(createMockFrame(timestamp));
  }
  
  return {
    sessionId: '00000000-0000-0000-0000-000000000001',
    frames,
    captureStartTime: startTime,
    captureEndTime: startTime + duration * 1000,
  };
}

describe('Hand Motion Detection', () => {
  describe('calculateLandmarkDistance', () => {
    it('should calculate correct distance between two points', () => {
      const a = { x: 0, y: 0, z: 0 };
      const b = { x: 1, y: 0, z: 0 };
      
      expect(calculateLandmarkDistance(a, b)).toBeCloseTo(1.0);
    });

    it('should return 0 for same point', () => {
      const a = { x: 0.5, y: 0.5, z: 0 };
      
      expect(calculateLandmarkDistance(a, a)).toBe(0);
    });

    it('should calculate 3D distance correctly', () => {
      const a = { x: 0, y: 0, z: 0 };
      const b = { x: 1, y: 1, z: 1 };
      
      expect(calculateLandmarkDistance(a, b)).toBeCloseTo(Math.sqrt(3));
    });
  });

  describe('extractMotionFeatures', () => {
    it('should extract features from a valid sequence', () => {
      const sequence = createMockSequence(15, 1.5);
      const features = extractMotionFeatures(sequence);
      
      expect(features).toHaveProperty('averageVelocity');
      expect(features).toHaveProperty('maxVelocity');
      expect(features).toHaveProperty('motionSmoothness');
      expect(features).toHaveProperty('averageFingerSpread');
      expect(features).toHaveProperty('averageWristMovement');
      expect(features).toHaveProperty('frameDuration');
      expect(features).toHaveProperty('frameCount');
      expect(features).toHaveProperty('dominantHand');
      expect(features).toHaveProperty('averageConfidence');
    });

    it('should report correct frame count', () => {
      const sequence = createMockSequence(20, 2);
      const features = extractMotionFeatures(sequence);
      
      expect(features.frameCount).toBe(20);
    });

    it('should report correct dominant hand', () => {
      const sequence = createMockSequence(10, 1);
      sequence.frames = sequence.frames.map(f => ({ ...f, handedness: 'left' as const }));
      
      const features = extractMotionFeatures(sequence);
      expect(features.dominantHand).toBe('left');
    });
  });

  describe('validateMotionQuality', () => {
    it('should pass validation for high-quality motion', () => {
      const sequence = createMockSequence(30, 2);
      const features = extractMotionFeatures(sequence);
      const result = validateMotionQuality(features);
      
      expect(result.isValid).toBe(true);
      expect(result.issues).toHaveLength(0);
      expect(result.qualityScore).toBeGreaterThan(0);
    });

    it('should fail for low confidence', () => {
      const sequence = createMockSequence(30, 2);
      sequence.frames = sequence.frames.map(f => ({ ...f, confidence: 0.3 }));
      
      const features = extractMotionFeatures(sequence);
      const result = validateMotionQuality(features);
      
      expect(result.isValid).toBe(false);
      expect(result.issues.some(i => i.includes('confidence'))).toBe(true);
    });

    it('should fail for insufficient frames', () => {
      const sequence = createMockSequence(5, 0.3);
      const features = extractMotionFeatures(sequence);
      const result = validateMotionQuality(features);
      
      expect(result.isValid).toBe(false);
      expect(result.issues.some(i => i.includes('frames'))).toBe(true);
    });
  });
});

describe('HAND_LANDMARKS constants', () => {
  it('should have 21 landmarks defined', () => {
    const landmarks = Object.values(HAND_LANDMARKS);
    const uniqueIndices = new Set(landmarks);
    
    expect(uniqueIndices.size).toBe(21);
  });

  it('should have wrist at index 0', () => {
    expect(HAND_LANDMARKS.WRIST).toBe(0);
  });

  it('should have finger tips at expected indices', () => {
    expect(HAND_LANDMARKS.THUMB_TIP).toBe(4);
    expect(HAND_LANDMARKS.INDEX_FINGER_TIP).toBe(8);
    expect(HAND_LANDMARKS.MIDDLE_FINGER_TIP).toBe(12);
    expect(HAND_LANDMARKS.RING_FINGER_TIP).toBe(16);
    expect(HAND_LANDMARKS.PINKY_TIP).toBe(20);
  });
});
