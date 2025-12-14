// DeafAuth integration
export { DeafAuthClient, createDeafAuthClient } from './deafauth.js';
export type { DeafAuthConfig, User, AuthResponse, RegisterData } from './deafauth.js';

// PinkSync integration
export { PinkSyncClient, createPinkSyncClient } from './pinksync.js';
export type { PinkSyncConfig, SyncData, SyncResponse, SyncStatus, MessageHandler } from './pinksync.js';

// FibonRose integration
export { FibonRoseClient, createFibonRoseClient } from './fibonrose.js';
export type { FibonRoseConfig, Task, OptimizedSchedule, FibonacciResult, GoldenRatioResult } from './fibonrose.js';

// Platform configuration
import { createDeafAuthClient, type DeafAuthConfig } from './deafauth.js';
import { createPinkSyncClient, type PinkSyncConfig } from './pinksync.js';
import { createFibonRoseClient, type FibonRoseConfig } from './fibonrose.js';

export interface PlatformConfig {
  deafauth?: DeafAuthConfig;
  pinksync?: PinkSyncConfig;
  fibonrose?: FibonRoseConfig;
}

export function createPlatformClients(config: PlatformConfig) {
  return {
    deafauth: config.deafauth ? createDeafAuthClient(config.deafauth) : undefined,
    pinksync: config.pinksync ? createPinkSyncClient(config.pinksync) : undefined,
    fibonrose: config.fibonrose ? createFibonRoseClient(config.fibonrose) : undefined,
  };
}
