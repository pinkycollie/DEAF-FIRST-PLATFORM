/**
 * Telehealth Verification Module
 * 
 * Provides ASL-based identity verification for telehealth sessions.
 * Designed for healthcare contexts with HIPAA-aware data handling.
 */

import { v4 as uuidv4 } from 'uuid';
import { z } from 'zod';
import { 
  MotionSequence, 
  MotionSequenceSchema 
} from './hand-motion-detection.js';
import { 
  enrollUser, 
  verifyIdentity, 
  getUserProfile,
  deleteUserBiometrics,
  type VerificationResult 
} from './identity-matching.js';
import { 
  analyzeGesture, 
  generateVerificationChallenge,
  type GestureAnalysisResult,
  type VerificationChallenge 
} from './motion-analysis.js';

// Session schema
export const TelehealthSessionSchema = z.object({
  sessionId: z.string().uuid(),
  patientId: z.string().uuid(),
  providerId: z.string().uuid(),
  sessionType: z.enum(['consultation', 'followup', 'prescription', 'emergency']),
  createdAt: z.string().datetime(),
  verificationStatus: z.enum(['pending', 'verified', 'failed', 'expired']),
});

export type TelehealthSession = z.infer<typeof TelehealthSessionSchema>;

// Active sessions storage (use Redis/Supabase in production)
const activeSessions = new Map<string, TelehealthSession>();
const pendingChallenges = new Map<string, VerificationChallenge & { sessionId: string }>();

/**
 * Initialize a new telehealth verification session
 */
export async function initializeSession(
  patientId: string,
  providerId: string,
  sessionType: TelehealthSession['sessionType'] = 'consultation'
): Promise<SessionInitResult> {
  const sessionId = uuidv4();
  
  const session: TelehealthSession = {
    sessionId,
    patientId,
    providerId,
    sessionType,
    createdAt: new Date().toISOString(),
    verificationStatus: 'pending',
  };
  
  activeSessions.set(sessionId, session);
  
  // Check if patient has enrolled biometrics
  const patientProfile = getUserProfile(patientId);
  const requiresEnrollment = patientProfile === null || patientProfile.enrolledPatterns === 0;
  
  // Generate verification challenge
  const challenge = generateVerificationChallenge();
  pendingChallenges.set(sessionId, {
    ...challenge,
    sessionId,
  });
  
  return {
    sessionId,
    requiresEnrollment,
    challenge,
    session,
    message: requiresEnrollment 
      ? 'Please enroll your ASL signature before verification'
      : 'Please perform the verification gesture',
  };
}

/**
 * Enroll patient biometrics during telehealth session
 */
export async function enrollPatientBiometrics(
  sessionId: string,
  motionSequence: MotionSequence
): Promise<EnrollmentSessionResult> {
  const session = activeSessions.get(sessionId);
  
  if (!session) {
    return {
      success: false,
      error: 'Session not found or expired',
    };
  }
  
  // Parse and validate motion sequence
  const parseResult = MotionSequenceSchema.safeParse(motionSequence);
  if (!parseResult.success) {
    return {
      success: false,
      error: 'Invalid motion sequence data',
      validationErrors: parseResult.error.errors.map(e => e.message),
    };
  }
  
  // Enroll the patient
  const enrollmentResult = await enrollUser(
    session.patientId,
    parseResult.data,
    'telehealth_verification'
  );
  
  if (!enrollmentResult.success) {
    return {
      success: false,
      error: enrollmentResult.error,
      qualityIssues: enrollmentResult.qualityIssues,
    };
  }
  
  // Analyze the gesture for additional context
  const gestureAnalysis = analyzeGesture(parseResult.data);
  
  return {
    success: true,
    patternId: enrollmentResult.patternId,
    qualityScore: enrollmentResult.qualityScore,
    enrolledPatterns: enrollmentResult.enrolledPatterns,
    gestureAnalysis,
    message: 'Biometric enrollment successful. You can now verify your identity.',
  };
}

/**
 * Verify patient identity during telehealth session
 */
export async function verifyPatientIdentity(
  sessionId: string,
  motionSequence: MotionSequence
): Promise<VerificationSessionResult> {
  const session = activeSessions.get(sessionId);
  
  if (!session) {
    return {
      success: false,
      verified: false,
      error: 'Session not found or expired',
    };
  }
  
  const challenge = pendingChallenges.get(sessionId);
  if (!challenge) {
    return {
      success: false,
      verified: false,
      error: 'No pending verification challenge',
    };
  }
  
  // Check challenge expiry
  if (Date.now() > challenge.expiresAt) {
    pendingChallenges.delete(sessionId);
    return {
      success: false,
      verified: false,
      error: 'Verification challenge expired. Please request a new one.',
    };
  }
  
  // Parse motion sequence
  const parseResult = MotionSequenceSchema.safeParse(motionSequence);
  if (!parseResult.success) {
    return {
      success: false,
      verified: false,
      error: 'Invalid motion sequence data',
    };
  }
  
  // Verify identity
  const verificationResult = await verifyIdentity(session.patientId, parseResult.data);
  
  // Update session status
  session.verificationStatus = verificationResult.verified ? 'verified' : 'failed';
  activeSessions.set(sessionId, session);
  
  // Clean up used challenge
  if (verificationResult.verified) {
    pendingChallenges.delete(sessionId);
  }
  
  // Analyze the gesture
  const gestureAnalysis = analyzeGesture(parseResult.data);
  
  return {
    success: true,
    verified: verificationResult.verified,
    matchScore: verificationResult.matchScore,
    confidence: verificationResult.confidence,
    qualityScore: verificationResult.qualityScore,
    gestureAnalysis,
    message: verificationResult.verified
      ? 'Identity verified successfully'
      : 'Verification failed. Please try again.',
  };
}

/**
 * Get a new verification challenge for a session
 */
export function refreshChallenge(sessionId: string): ChallengeRefreshResult {
  const session = activeSessions.get(sessionId);
  
  if (!session) {
    return {
      success: false,
      error: 'Session not found',
    };
  }
  
  const challenge = generateVerificationChallenge();
  pendingChallenges.set(sessionId, {
    ...challenge,
    sessionId,
  });
  
  return {
    success: true,
    challenge,
  };
}

/**
 * Get session status
 */
export function getSessionStatus(sessionId: string): SessionStatusResult {
  const session = activeSessions.get(sessionId);
  
  if (!session) {
    return {
      found: false,
    };
  }
  
  const patientProfile = getUserProfile(session.patientId);
  const challenge = pendingChallenges.get(sessionId);
  
  return {
    found: true,
    session,
    patientEnrolled: !!patientProfile && patientProfile.enrolledPatterns > 0,
    hasPendingChallenge: !!challenge,
    challengeExpired: challenge ? Date.now() > challenge.expiresAt : false,
  };
}

/**
 * End a telehealth session
 */
export function endSession(sessionId: string): boolean {
  pendingChallenges.delete(sessionId);
  return activeSessions.delete(sessionId);
}

/**
 * Delete all patient biometric data (GDPR/privacy compliance)
 */
export function deletePatientData(patientId: string): DataDeletionResult {
  const deleted = deleteUserBiometrics(patientId);
  
  // Also clean up any active sessions for this patient
  for (const [sessionId, session] of activeSessions.entries()) {
    if (session.patientId === patientId) {
      activeSessions.delete(sessionId);
      pendingChallenges.delete(sessionId);
    }
  }
  
  return {
    success: true,
    biometricsDeleted: deleted,
    message: 'All patient biometric data has been deleted',
  };
}

/**
 * Get session statistics (for monitoring)
 */
export function getSessionStats(): SessionStats {
  let pending = 0;
  let verified = 0;
  let failed = 0;
  
  for (const session of activeSessions.values()) {
    switch (session.verificationStatus) {
      case 'pending': pending++; break;
      case 'verified': verified++; break;
      case 'failed': failed++; break;
    }
  }
  
  return {
    totalActiveSessions: activeSessions.size,
    pendingVerifications: pending,
    verifiedSessions: verified,
    failedVerifications: failed,
    pendingChallenges: pendingChallenges.size,
  };
}

// Types
export interface SessionInitResult {
  sessionId: string;
  requiresEnrollment: boolean;
  challenge: VerificationChallenge;
  session: TelehealthSession;
  message: string;
}

export interface EnrollmentSessionResult {
  success: boolean;
  patternId?: string;
  qualityScore?: number;
  enrolledPatterns?: number;
  gestureAnalysis?: GestureAnalysisResult;
  error?: string;
  qualityIssues?: string[];
  validationErrors?: string[];
  message?: string;
}

export interface VerificationSessionResult {
  success: boolean;
  verified: boolean;
  matchScore?: number;
  confidence?: 'low' | 'medium' | 'high';
  qualityScore?: number;
  gestureAnalysis?: GestureAnalysisResult;
  error?: string;
  message?: string;
}

export interface ChallengeRefreshResult {
  success: boolean;
  challenge?: VerificationChallenge;
  error?: string;
}

export interface SessionStatusResult {
  found: boolean;
  session?: TelehealthSession;
  patientEnrolled?: boolean;
  hasPendingChallenge?: boolean;
  challengeExpired?: boolean;
}

export interface DataDeletionResult {
  success: boolean;
  biometricsDeleted: boolean;
  message: string;
}

export interface SessionStats {
  totalActiveSessions: number;
  pendingVerifications: number;
  verifiedSessions: number;
  failedVerifications: number;
  pendingChallenges: number;
}
