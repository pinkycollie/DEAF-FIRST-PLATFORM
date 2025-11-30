/**
 * ASL Identity Matching Module
 * 
 * Provides biometric identity verification using ASL signing patterns.
 * Uses motion feature analysis for cost-effective identity matching
 * without requiring expensive cloud AI services.
 */

import { v4 as uuidv4 } from 'uuid';
import { z } from 'zod';
import { 
  MotionFeatures, 
  MotionSequence, 
  extractMotionFeatures,
  validateMotionQuality 
} from './hand-motion-detection.js';

// Configuration for verification thresholds (can be overridden via environment)
export const BIOMETRIC_CONFIG = {
  // Minimum match score required for successful verification (0-1)
  // Higher values = more secure but may cause more false rejections
  VERIFICATION_THRESHOLD: parseFloat(process.env.BIOMETRIC_VERIFICATION_THRESHOLD || '0.75'),
  // Minimum quality score for enrollment
  MIN_ENROLLMENT_QUALITY: parseFloat(process.env.BIOMETRIC_MIN_QUALITY || '0.5'),
} as const;

// User biometric profile schema
export const BiometricProfileSchema = z.object({
  userId: z.string().uuid(),
  enrollmentDate: z.string().datetime(),
  signaturePatterns: z.array(z.object({
    patternId: z.string().uuid(),
    signType: z.string(),
    features: z.object({
      averageVelocity: z.number(),
      maxVelocity: z.number(),
      motionSmoothness: z.number(),
      averageFingerSpread: z.number(),
      averageWristMovement: z.number(),
      dominantHand: z.enum(['left', 'right']),
    }),
    capturedAt: z.string().datetime(),
  })),
  preferences: z.object({
    dominantHand: z.enum(['left', 'right']),
    preferredSigns: z.array(z.string()).optional(),
  }),
});

export type BiometricProfile = z.infer<typeof BiometricProfileSchema>;

// In-memory storage for demo (use Supabase in production)
const profiles = new Map<string, BiometricProfile>();

/**
 * Enroll a new user with ASL biometric pattern
 */
export async function enrollUser(
  userId: string,
  motionSequence: MotionSequence,
  signType: string = 'verification_sign'
): Promise<EnrollmentResult> {
  // Validate motion quality
  const features = extractMotionFeatures(motionSequence);
  const qualityCheck = validateMotionQuality(features);
  
  if (!qualityCheck.isValid) {
    return {
      success: false,
      error: 'Motion quality insufficient for enrollment',
      qualityIssues: qualityCheck.issues,
    };
  }
  
  // Check if user already has a profile
  let profile = profiles.get(userId);
  
  if (!profile) {
    profile = {
      userId,
      enrollmentDate: new Date().toISOString(),
      signaturePatterns: [],
      preferences: {
        dominantHand: features.dominantHand,
      },
    };
  }
  
  // Add new signature pattern
  const patternId = uuidv4();
  profile.signaturePatterns.push({
    patternId,
    signType,
    features: {
      averageVelocity: features.averageVelocity,
      maxVelocity: features.maxVelocity,
      motionSmoothness: features.motionSmoothness,
      averageFingerSpread: features.averageFingerSpread,
      averageWristMovement: features.averageWristMovement,
      dominantHand: features.dominantHand,
    },
    capturedAt: new Date().toISOString(),
  });
  
  profiles.set(userId, profile);
  
  return {
    success: true,
    patternId,
    qualityScore: qualityCheck.qualityScore,
    enrolledPatterns: profile.signaturePatterns.length,
  };
}

/**
 * Verify user identity using ASL motion pattern
 */
export async function verifyIdentity(
  userId: string,
  motionSequence: MotionSequence
): Promise<VerificationResult> {
  // Get user profile
  const profile = profiles.get(userId);
  
  if (!profile) {
    return {
      verified: false,
      error: 'User not enrolled',
      matchScore: 0,
    };
  }
  
  if (profile.signaturePatterns.length === 0) {
    return {
      verified: false,
      error: 'No enrolled patterns for user',
      matchScore: 0,
    };
  }
  
  // Extract features from verification attempt
  const features = extractMotionFeatures(motionSequence);
  const qualityCheck = validateMotionQuality(features);
  
  if (!qualityCheck.isValid) {
    return {
      verified: false,
      error: 'Motion quality insufficient for verification',
      qualityIssues: qualityCheck.issues,
      matchScore: 0,
    };
  }
  
  // Compare with enrolled patterns
  let bestMatchScore = 0;
  let matchedPatternId: string | undefined;
  
  for (const pattern of profile.signaturePatterns) {
    const score = calculateMatchScore(features, pattern.features);
    if (score > bestMatchScore) {
      bestMatchScore = score;
      matchedPatternId = pattern.patternId;
    }
  }
  
  // Use configurable verification threshold
  const verified = bestMatchScore >= BIOMETRIC_CONFIG.VERIFICATION_THRESHOLD;
  
  return {
    verified,
    matchScore: bestMatchScore,
    matchedPatternId: verified ? matchedPatternId : undefined,
    qualityScore: qualityCheck.qualityScore,
    confidence: verified ? calculateConfidence(bestMatchScore) : 'low',
  };
}

/**
 * Calculate match score between two feature sets
 */
function calculateMatchScore(
  attempt: MotionFeatures,
  enrolled: {
    averageVelocity: number;
    maxVelocity: number;
    motionSmoothness: number;
    averageFingerSpread: number;
    averageWristMovement: number;
    dominantHand: 'left' | 'right';
  }
): number {
  // Hand dominance must match
  if (attempt.dominantHand !== enrolled.dominantHand) {
    return 0;
  }
  
  // Calculate similarity for each feature
  const velocitySimilarity = calculateSimilarity(
    attempt.averageVelocity, 
    enrolled.averageVelocity, 
    0.5
  );
  
  const maxVelocitySimilarity = calculateSimilarity(
    attempt.maxVelocity, 
    enrolled.maxVelocity, 
    0.5
  );
  
  const smoothnessSimilarity = calculateSimilarity(
    attempt.motionSmoothness, 
    enrolled.motionSmoothness, 
    0.3
  );
  
  const fingerSpreadSimilarity = calculateSimilarity(
    attempt.averageFingerSpread, 
    enrolled.averageFingerSpread, 
    0.2
  );
  
  const wristMovementSimilarity = calculateSimilarity(
    attempt.averageWristMovement, 
    enrolled.averageWristMovement, 
    0.3
  );
  
  // Weighted average
  const weights = {
    velocity: 0.25,
    maxVelocity: 0.15,
    smoothness: 0.25,
    fingerSpread: 0.2,
    wristMovement: 0.15,
  };
  
  return (
    weights.velocity * velocitySimilarity +
    weights.maxVelocity * maxVelocitySimilarity +
    weights.smoothness * smoothnessSimilarity +
    weights.fingerSpread * fingerSpreadSimilarity +
    weights.wristMovement * wristMovementSimilarity
  );
}

/**
 * Calculate similarity between two values using tolerance
 */
function calculateSimilarity(a: number, b: number, tolerance: number): number {
  if (a === 0 && b === 0) return 1;
  const maxVal = Math.max(Math.abs(a), Math.abs(b));
  if (maxVal === 0) return 1;
  
  const diff = Math.abs(a - b) / maxVal;
  return Math.max(0, 1 - diff / tolerance);
}

function calculateConfidence(matchScore: number): 'low' | 'medium' | 'high' {
  if (matchScore >= 0.9) return 'high';
  if (matchScore >= 0.8) return 'medium';
  return 'low';
}

/**
 * Get user's biometric profile (without sensitive pattern data)
 */
export function getUserProfile(userId: string): UserProfileInfo | null {
  const profile = profiles.get(userId);
  if (!profile) return null;
  
  return {
    userId: profile.userId,
    enrollmentDate: profile.enrollmentDate,
    enrolledPatterns: profile.signaturePatterns.length,
    dominantHand: profile.preferences.dominantHand,
    lastPatternDate: profile.signaturePatterns.length > 0
      ? profile.signaturePatterns[profile.signaturePatterns.length - 1].capturedAt
      : null,
  };
}

/**
 * Delete user's biometric data (for privacy compliance)
 */
export function deleteUserBiometrics(userId: string): boolean {
  return profiles.delete(userId);
}

// Types
export interface EnrollmentResult {
  success: boolean;
  patternId?: string;
  qualityScore?: number;
  enrolledPatterns?: number;
  error?: string;
  qualityIssues?: string[];
}

export interface VerificationResult {
  verified: boolean;
  matchScore: number;
  matchedPatternId?: string;
  qualityScore?: number;
  confidence?: 'low' | 'medium' | 'high';
  error?: string;
  qualityIssues?: string[];
}

export interface UserProfileInfo {
  userId: string;
  enrollmentDate: string;
  enrolledPatterns: number;
  dominantHand: 'left' | 'right';
  lastPatternDate: string | null;
}
