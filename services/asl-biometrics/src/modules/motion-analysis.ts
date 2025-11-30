/**
 * ASL Motion Analysis Module
 * 
 * Provides pattern recognition and analysis for ASL signing motions.
 * Designed for telehealth verification contexts.
 */

import { z } from 'zod';
import { 
  HandFrame, 
  MotionSequence, 
  HandLandmark,
  HAND_LANDMARKS,
  calculateLandmarkDistance 
} from './hand-motion-detection.js';

// ASL gesture patterns for verification
export const ASL_VERIFICATION_GESTURES = {
  // Basic verification signs
  YES: 'yes',
  NO: 'no',
  HELLO: 'hello',
  THANK_YOU: 'thank_you',
  MY_NAME: 'my_name',
  UNDERSTAND: 'understand',
} as const;

export type ASLGestureType = typeof ASL_VERIFICATION_GESTURES[keyof typeof ASL_VERIFICATION_GESTURES];

export const GesturePatternSchema = z.object({
  gestureType: z.string(),
  keyframes: z.array(z.object({
    frameIndex: z.number(),
    fingerPositions: z.object({
      thumbExtended: z.boolean(),
      indexExtended: z.boolean(),
      middleExtended: z.boolean(),
      ringExtended: z.boolean(),
      pinkyExtended: z.boolean(),
    }),
    handOrientation: z.enum(['palm_up', 'palm_down', 'palm_forward', 'palm_back']),
    movementDirection: z.enum(['up', 'down', 'left', 'right', 'forward', 'back', 'stationary']).optional(),
  })),
});

export type GesturePattern = z.infer<typeof GesturePatternSchema>;

/**
 * Analyze a motion sequence to extract gesture characteristics
 */
export function analyzeGesture(sequence: MotionSequence): GestureAnalysisResult {
  const { frames } = sequence;
  
  // Extract keyframes (sample at regular intervals)
  const keyframeCount = Math.min(10, frames.length);
  const keyframeInterval = Math.floor(frames.length / keyframeCount);
  
  const keyframes: KeyframeAnalysis[] = [];
  
  for (let i = 0; i < keyframeCount; i++) {
    const frameIndex = Math.min(i * keyframeInterval, frames.length - 1);
    const frame = frames[frameIndex];
    
    keyframes.push({
      frameIndex,
      timestamp: frame.timestamp,
      fingerPositions: analyzeFingerPositions(frame),
      handOrientation: estimateHandOrientation(frame),
      movementDirection: i > 0 
        ? calculateMovementDirection(frames[frameIndex - keyframeInterval] || frames[0], frame)
        : undefined,
    });
  }
  
  // Analyze overall gesture characteristics
  const gesturePath = calculateGesturePath(frames);
  const signDuration = (sequence.captureEndTime - sequence.captureStartTime) / 1000;
  const complexity = calculateComplexity(keyframes);
  
  return {
    keyframes,
    gesturePath,
    signDuration,
    complexity,
    handedness: frames[0].handedness,
    confidence: calculateOverallConfidence(frames),
    suggestedGesture: detectKnownGesture(keyframes),
  };
}

/**
 * Analyze finger extension state
 */
function analyzeFingerPositions(frame: HandFrame): FingerPositions {
  const landmarks = frame.landmarks;
  
  return {
    thumbExtended: isFingerExtended(
      landmarks[HAND_LANDMARKS.THUMB_CMC],
      landmarks[HAND_LANDMARKS.THUMB_MCP],
      landmarks[HAND_LANDMARKS.THUMB_TIP]
    ),
    indexExtended: isFingerExtended(
      landmarks[HAND_LANDMARKS.INDEX_FINGER_MCP],
      landmarks[HAND_LANDMARKS.INDEX_FINGER_PIP],
      landmarks[HAND_LANDMARKS.INDEX_FINGER_TIP]
    ),
    middleExtended: isFingerExtended(
      landmarks[HAND_LANDMARKS.MIDDLE_FINGER_MCP],
      landmarks[HAND_LANDMARKS.MIDDLE_FINGER_PIP],
      landmarks[HAND_LANDMARKS.MIDDLE_FINGER_TIP]
    ),
    ringExtended: isFingerExtended(
      landmarks[HAND_LANDMARKS.RING_FINGER_MCP],
      landmarks[HAND_LANDMARKS.RING_FINGER_PIP],
      landmarks[HAND_LANDMARKS.RING_FINGER_TIP]
    ),
    pinkyExtended: isFingerExtended(
      landmarks[HAND_LANDMARKS.PINKY_MCP],
      landmarks[HAND_LANDMARKS.PINKY_PIP],
      landmarks[HAND_LANDMARKS.PINKY_TIP]
    ),
  };
}

/**
 * Check if a finger is extended based on joint positions
 */
function isFingerExtended(
  mcp: HandLandmark,
  pip: HandLandmark,
  tip: HandLandmark
): boolean {
  // Finger is extended if tip is further from MCP than PIP
  const mcpToTip = calculateLandmarkDistance(mcp, tip);
  const mcpToPip = calculateLandmarkDistance(mcp, pip);
  
  return mcpToTip > mcpToPip * 1.3; // Extension threshold
}

/**
 * Estimate hand orientation from landmarks
 */
function estimateHandOrientation(frame: HandFrame): HandOrientation {
  const wrist = frame.landmarks[HAND_LANDMARKS.WRIST];
  const middleMcp = frame.landmarks[HAND_LANDMARKS.MIDDLE_FINGER_MCP];
  
  // Simple orientation estimation based on z-depth
  const zDiff = middleMcp.z - wrist.z;
  const yDiff = middleMcp.y - wrist.y;
  
  if (Math.abs(zDiff) > Math.abs(yDiff)) {
    return zDiff > 0 ? 'palm_forward' : 'palm_back';
  } else {
    return yDiff > 0 ? 'palm_down' : 'palm_up';
  }
}

/**
 * Calculate movement direction between frames
 */
function calculateMovementDirection(
  prev: HandFrame,
  current: HandFrame
): MovementDirection {
  const prevWrist = prev.landmarks[HAND_LANDMARKS.WRIST];
  const currWrist = current.landmarks[HAND_LANDMARKS.WRIST];
  
  const dx = currWrist.x - prevWrist.x;
  const dy = currWrist.y - prevWrist.y;
  const dz = currWrist.z - prevWrist.z;
  
  const threshold = 0.02;
  
  // Check for stationary
  if (Math.abs(dx) < threshold && Math.abs(dy) < threshold && Math.abs(dz) < threshold) {
    return 'stationary';
  }
  
  // Find dominant axis
  const absDx = Math.abs(dx);
  const absDy = Math.abs(dy);
  const absDz = Math.abs(dz);
  
  if (absDx >= absDy && absDx >= absDz) {
    return dx > 0 ? 'right' : 'left';
  } else if (absDy >= absDx && absDy >= absDz) {
    return dy > 0 ? 'down' : 'up';
  } else {
    return dz > 0 ? 'forward' : 'back';
  }
}

/**
 * Calculate the path traced by the hand during the gesture
 */
function calculateGesturePath(frames: HandFrame[]): GesturePath {
  const wristPositions = frames.map(f => f.landmarks[HAND_LANDMARKS.WRIST]);
  
  // Calculate bounding box
  const xs = wristPositions.map(p => p.x);
  const ys = wristPositions.map(p => p.y);
  
  const minX = Math.min(...xs);
  const maxX = Math.max(...xs);
  const minY = Math.min(...ys);
  const maxY = Math.max(...ys);
  
  // Calculate total distance traveled
  let totalDistance = 0;
  for (let i = 1; i < wristPositions.length; i++) {
    totalDistance += calculateLandmarkDistance(wristPositions[i], wristPositions[i - 1]);
  }
  
  // Determine path shape
  const aspectRatio = (maxX - minX) / (maxY - minY || 0.001);
  let pathShape: PathShape;
  
  if (totalDistance < 0.1) {
    pathShape = 'stationary';
  } else if (aspectRatio > 2) {
    pathShape = 'horizontal';
  } else if (aspectRatio < 0.5) {
    pathShape = 'vertical';
  } else {
    pathShape = 'circular';
  }
  
  return {
    boundingBox: {
      minX,
      maxX,
      minY,
      maxY,
    },
    totalDistance,
    pathShape,
  };
}

/**
 * Calculate gesture complexity score
 */
function calculateComplexity(keyframes: KeyframeAnalysis[]): number {
  let changes = 0;
  
  for (let i = 1; i < keyframes.length; i++) {
    const prev = keyframes[i - 1];
    const curr = keyframes[i];
    
    // Count finger state changes
    if (prev.fingerPositions.thumbExtended !== curr.fingerPositions.thumbExtended) changes++;
    if (prev.fingerPositions.indexExtended !== curr.fingerPositions.indexExtended) changes++;
    if (prev.fingerPositions.middleExtended !== curr.fingerPositions.middleExtended) changes++;
    if (prev.fingerPositions.ringExtended !== curr.fingerPositions.ringExtended) changes++;
    if (prev.fingerPositions.pinkyExtended !== curr.fingerPositions.pinkyExtended) changes++;
    
    // Count orientation changes
    if (prev.handOrientation !== curr.handOrientation) changes++;
    
    // Count movement direction changes
    if (prev.movementDirection !== curr.movementDirection) changes++;
  }
  
  // Normalize to 0-1 scale
  const maxPossibleChanges = keyframes.length * 7;
  return Math.min(1, changes / maxPossibleChanges);
}

function calculateOverallConfidence(frames: HandFrame[]): number {
  return frames.reduce((sum, f) => sum + f.confidence, 0) / frames.length;
}

/**
 * Attempt to detect known ASL gestures
 */
function detectKnownGesture(keyframes: KeyframeAnalysis[]): string | null {
  // Simple pattern matching for common verification gestures
  
  if (keyframes.length < 2) return null;
  
  const firstFrame = keyframes[0];
  const lastFrame = keyframes[keyframes.length - 1];
  
  // Detect "YES" - fist moving up and down (nodding motion with fist)
  const allFingersClosed = (fp: FingerPositions) => 
    !fp.indexExtended && !fp.middleExtended && !fp.ringExtended && !fp.pinkyExtended;
  
  if (allFingersClosed(firstFrame.fingerPositions) && allFingersClosed(lastFrame.fingerPositions)) {
    const hasVerticalMovement = keyframes.some(k => k.movementDirection === 'up' || k.movementDirection === 'down');
    if (hasVerticalMovement) return 'yes';
  }
  
  // Detect "HELLO" - open hand waving side to side
  const allFingersOpen = (fp: FingerPositions) => 
    fp.indexExtended && fp.middleExtended && fp.ringExtended && fp.pinkyExtended;
  
  if (allFingersOpen(firstFrame.fingerPositions)) {
    const hasHorizontalMovement = keyframes.some(k => k.movementDirection === 'left' || k.movementDirection === 'right');
    if (hasHorizontalMovement) return 'hello';
  }
  
  // Detect "THANK YOU" - flat hand moves away from chin
  if (allFingersOpen(firstFrame.fingerPositions) && firstFrame.handOrientation === 'palm_up') {
    const hasForwardMovement = keyframes.some(k => k.movementDirection === 'forward');
    if (hasForwardMovement) return 'thank_you';
  }
  
  return null;
}

// Types
export type HandOrientation = 'palm_up' | 'palm_down' | 'palm_forward' | 'palm_back';
export type MovementDirection = 'up' | 'down' | 'left' | 'right' | 'forward' | 'back' | 'stationary';
export type PathShape = 'horizontal' | 'vertical' | 'circular' | 'stationary';

export interface FingerPositions {
  thumbExtended: boolean;
  indexExtended: boolean;
  middleExtended: boolean;
  ringExtended: boolean;
  pinkyExtended: boolean;
}

export interface KeyframeAnalysis {
  frameIndex: number;
  timestamp: number;
  fingerPositions: FingerPositions;
  handOrientation: HandOrientation;
  movementDirection?: MovementDirection;
}

export interface GesturePath {
  boundingBox: {
    minX: number;
    maxX: number;
    minY: number;
    maxY: number;
  };
  totalDistance: number;
  pathShape: PathShape;
}

export interface GestureAnalysisResult {
  keyframes: KeyframeAnalysis[];
  gesturePath: GesturePath;
  signDuration: number;
  complexity: number;
  handedness: 'left' | 'right';
  confidence: number;
  suggestedGesture: string | null;
}

/**
 * Generate a verification challenge (random gesture to perform)
 */
export function generateVerificationChallenge(): VerificationChallenge {
  const gestures = Object.values(ASL_VERIFICATION_GESTURES);
  const selectedGesture = gestures[Math.floor(Math.random() * gestures.length)];
  
  const instructions: Record<string, string> = {
    yes: 'Make a fist and nod it up and down',
    no: 'Extend index finger and shake side to side',
    hello: 'Wave with an open hand',
    thank_you: 'Touch chin with flat hand and move forward',
    my_name: 'Point to yourself with index finger',
    understand: 'Touch forehead with extended index finger',
  };
  
  return {
    gestureType: selectedGesture,
    instructions: instructions[selectedGesture] || 'Perform the sign',
    expiresAt: Date.now() + 60000, // 1 minute expiry
    challengeId: crypto.randomUUID(),
  };
}

export interface VerificationChallenge {
  gestureType: string;
  instructions: string;
  expiresAt: number;
  challengeId: string;
}
