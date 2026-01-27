/**
 * Webhook Types for DEAF-FIRST Platform
 * These types define the structure for webhook events and configurations
 */

export interface WebhookEvent {
  id: string;
  event: string;
  timestamp: string;
  data: any;
  signature?: string;
}

export interface WebhookConfig {
  id: string;
  name: string;
  url: string;
  events: string[];
  secret: string;
  active: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface WebhookDelivery {
  id: string;
  webhookId: string;
  event: string;
  payload: any;
  response?: {
    status: number;
    body: any;
  };
  attempts: number;
  status: 'pending' | 'success' | 'failed';
  timestamp: string;
}

export interface WebhookRequest {
  name: string;
  url: string;
  events: string[];
  secret?: string;
}

export interface WebhookResponse {
  success: boolean;
  webhook?: WebhookConfig;
  message?: string;
  error?: string;
}

// Available webhook event types
export enum WebhookEventType {
  USER_CREATED = 'user.created',
  USER_UPDATED = 'user.updated',
  USER_DELETED = 'user.deleted',
  AUTH_LOGIN = 'auth.login',
  AUTH_LOGOUT = 'auth.logout',
  DOCUMENT_UPLOADED = 'document.uploaded',
  DOCUMENT_PROCESSED = 'document.processed',
  ACCESSIBILITY_REQUEST = 'accessibility.request',
  SYNC_STARTED = 'sync.started',
  SYNC_COMPLETED = 'sync.completed',
  AI_PROCESS_STARTED = 'ai.process.started',
  AI_PROCESS_COMPLETED = 'ai.process.completed',
}
