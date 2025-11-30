/**
 * ASL Hand Motion Detection Module
 * 
 * Cost-optimized implementation using browser-based detection
 * with MediaPipe Hands for client-side processing.
 * 
 * This module provides server-side validation and feature extraction
 * from client-submitted hand landmark data.
 */

import { z } from 'zod';

// Hand landmark schema based on MediaPipe Hands output
export const HandLandmarkSchema = z.object({
  x: z.number().min(0).max(1),
  y: z.number().min(0).max(1),
  z: z.number(),
});

export const HandLandmarksSchema = z.array(HandLandmarkSchema).length(21);

export const HandFrameSchema = z.object({
  timestamp: z.number(),
  handedness: z.enum(['left', 'right']),
  landmarks: HandLandmarksSchema,
  confidence: z.number().min(0).max(1),
});

export const MotionSequenceSchema = z.object({
  sessionId: z.string().uuid(),
  frames: z.array(HandFrameSchema).min(5),
  captureStartTime: z.number(),
  captureEndTime: z.number(),
});

export type HandLandmark = z.infer<typeof HandLandmarkSchema>;
export type HandFrame = z.infer<typeof HandFrameSchema>;
export type MotionSequence = z.infer<typeof MotionSequenceSchema>;

// MediaPipe hand landmark indices for reference
export const HAND_LANDMARKS = {
  WRIST: 0,
  THUMB_CMC: 1,
  THUMB_MCP: 2,
  THUMB_IP: 3,
  THUMB_TIP: 4,
  INDEX_FINGER_MCP: 5,
  INDEX_FINGER_PIP: 6,
  INDEX_FINGER_DIP: 7,
  INDEX_FINGER_TIP: 8,
  MIDDLE_FINGER_MCP: 9,
  MIDDLE_FINGER_PIP: 10,
  MIDDLE_FINGER_DIP: 11,
  MIDDLE_FINGER_TIP: 12,
  RING_FINGER_MCP: 13,
  RING_FINGER_PIP: 14,
  RING_FINGER_DIP: 15,
  RING_FINGER_TIP: 16,
  PINKY_MCP: 17,
  PINKY_PIP: 18,
  PINKY_DIP: 19,
  PINKY_TIP: 20,
} as const;

/**
 * Calculate Euclidean distance between two landmarks
 */
export function calculateLandmarkDistance(a: HandLandmark, b: HandLandmark): number {
  return Math.sqrt(
    Math.pow(a.x - b.x, 2) + 
    Math.pow(a.y - b.y, 2) + 
    Math.pow(a.z - b.z, 2)
  );
}

/**
 * Calculate velocity of a landmark between two frames
 */
export function calculateLandmarkVelocity(
  current: HandLandmark,
  previous: HandLandmark,
  timeDelta: number
): number {
  if (timeDelta === 0) return 0;
  return calculateLandmarkDistance(current, previous) / timeDelta;
}

/**
 * Extract motion features from a sequence of hand frames
 */
export function extractMotionFeatures(sequence: MotionSequence): MotionFeatures {
  const { frames } = sequence;
  
  // Calculate frame-to-frame velocities for key landmarks
  const fingerTipIndices = [
    HAND_LANDMARKS.THUMB_TIP,
    HAND_LANDMARKS.INDEX_FINGER_TIP,
    HAND_LANDMARKS.MIDDLE_FINGER_TIP,
    HAND_LANDMARKS.RING_FINGER_TIP,
    HAND_LANDMARKS.PINKY_TIP,
  ];
  
  const velocities: number[] = [];
  const fingerSpreads: number[] = [];
  const wristMovements: number[] = [];
  
  for (let i = 1; i < frames.length; i++) {
    const currentFrame = frames[i];
    const previousFrame = frames[i - 1];
    const timeDelta = (currentFrame.timestamp - previousFrame.timestamp) / 1000; // Convert to seconds
    
    // Calculate average finger tip velocity
    let frameVelocity = 0;
    for (const tipIndex of fingerTipIndices) {
      frameVelocity += calculateLandmarkVelocity(
        currentFrame.landmarks[tipIndex],
        previousFrame.landmarks[tipIndex],
        timeDelta
      );
    }
    velocities.push(frameVelocity / fingerTipIndices.length);
    
    // Calculate finger spread (distance between thumb tip and pinky tip)
    const thumbTip = currentFrame.landmarks[HAND_LANDMARKS.THUMB_TIP];
    const pinkyTip = currentFrame.landmarks[HAND_LANDMARKS.PINKY_TIP];
    fingerSpreads.push(calculateLandmarkDistance(thumbTip, pinkyTip));
    
    // Track wrist movement
    const wristMovement = calculateLandmarkVelocity(
      currentFrame.landmarks[HAND_LANDMARKS.WRIST],
      previousFrame.landmarks[HAND_LANDMARKS.WRIST],
      timeDelta
    );
    wristMovements.push(wristMovement);
  }
  
  // Calculate statistics
  const avgVelocity = velocities.reduce((a, b) => a + b, 0) / velocities.length;
  const maxVelocity = Math.max(...velocities);
  const avgFingerSpread = fingerSpreads.reduce((a, b) => a + b, 0) / fingerSpreads.length;
  const avgWristMovement = wristMovements.reduce((a, b) => a + b, 0) / wristMovements.length;
  
  // Calculate motion smoothness using inverse variance formula:
  // smoothness = 1 / (1 + variance)
  // This maps high variance (erratic motion) to low smoothness (near 0)
  // and low variance (consistent motion) to high smoothness (near 1)
  const velocityVariance = velocities.reduce((acc, v) => 
    acc + Math.pow(v - avgVelocity, 2), 0
  ) / velocities.length;
  
  const motionSmoothness = 1 / (1 + velocityVariance);
  
  return {
    averageVelocity: avgVelocity,
    maxVelocity,
    motionSmoothness,
    averageFingerSpread: avgFingerSpread,
    averageWristMovement: avgWristMovement,
    frameDuration: (sequence.captureEndTime - sequence.captureStartTime) / 1000,
    frameCount: frames.length,
    dominantHand: frames[0].handedness,
    averageConfidence: frames.reduce((a, f) => a + f.confidence, 0) / frames.length,
  };
}

export interface MotionFeatures {
  averageVelocity: number;
  maxVelocity: number;
  motionSmoothness: number;
  averageFingerSpread: number;
  averageWristMovement: number;
  frameDuration: number;
  frameCount: number;
  dominantHand: 'left' | 'right';
  averageConfidence: number;
}

/**
 * Validate that captured motion meets minimum quality thresholds
 */
export function validateMotionQuality(features: MotionFeatures): MotionQualityResult {
  const issues: string[] = [];
  
  if (features.averageConfidence < 0.7) {
    issues.push('Low hand detection confidence - ensure good lighting');
  }
  
  if (features.frameCount < 10) {
    issues.push('Insufficient frames captured - sign for at least 1 second');
  }
  
  if (features.frameDuration < 0.5) {
    issues.push('Motion too brief - perform sign more slowly');
  }
  
  if (features.motionSmoothness < 0.3) {
    issues.push('Motion too erratic - try to sign more smoothly');
  }
  
  return {
    isValid: issues.length === 0,
    qualityScore: calculateQualityScore(features),
    issues,
    features,
  };
}

function calculateQualityScore(features: MotionFeatures): number {
  // Weighted quality score based on various factors
  const confidenceWeight = 0.3;
  const smoothnessWeight = 0.25;
  const durationWeight = 0.2;
  const frameCountWeight = 0.25;
  
  const confidenceScore = features.averageConfidence;
  const smoothnessScore = features.motionSmoothness;
  const durationScore = Math.min(1, features.frameDuration / 2); // Cap at 2 seconds
  const frameCountScore = Math.min(1, features.frameCount / 30); // Cap at 30 frames
  
  return (
    confidenceWeight * confidenceScore +
    smoothnessWeight * smoothnessScore +
    durationWeight * durationScore +
    frameCountWeight * frameCountScore
  );
}

export interface MotionQualityResult {
  isValid: boolean;
  qualityScore: number;
  issues: string[];
  features: MotionFeatures;
}
