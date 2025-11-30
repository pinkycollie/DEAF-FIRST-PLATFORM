import axios, { AxiosInstance } from 'axios';

export interface PinkSyncConfig {
  baseUrl: string;
  wsUrl?: string;
  timeout?: number;
}

export interface SyncData {
  channel: string;
  data: Record<string, unknown>;
}

export interface SyncResponse {
  success: boolean;
  syncId: string;
  message: string;
}

export interface SyncStatus {
  success: boolean;
  status: string;
  activeChannels: number;
  connectedClients: number;
}

export type MessageHandler = (data: unknown) => void;

export class PinkSyncClient {
  private client: AxiosInstance;
  private wsUrl: string;
  private connections: Map<string, WebSocket> = new Map();
  private messageHandlers: Map<string, Set<MessageHandler>> = new Map();

  constructor(config: PinkSyncConfig) {
    this.client = axios.create({
      baseURL: config.baseUrl,
      timeout: config.timeout || 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    });
    
    this.wsUrl = config.wsUrl || config.baseUrl.replace(/^http/, 'ws');
  }

  async sync(data: SyncData): Promise<SyncResponse> {
    const response = await this.client.post<SyncResponse>('/api/sync', data);
    return response.data;
  }

  async getStatus(): Promise<SyncStatus> {
    const response = await this.client.get<SyncStatus>('/api/sync/status');
    return response.data;
  }

  subscribe(channel: string, handler: MessageHandler): () => void {
    // Add handler
    if (!this.messageHandlers.has(channel)) {
      this.messageHandlers.set(channel, new Set());
    }
    this.messageHandlers.get(channel)?.add(handler);

    // Create WebSocket connection if not exists
    if (!this.connections.has(channel)) {
      const ws = new WebSocket(`${this.wsUrl}/ws/${channel}`);
      
      ws.onmessage = (event) => {
        const handlers = this.messageHandlers.get(channel);
        if (handlers) {
          try {
            const data = JSON.parse(event.data);
            handlers.forEach((h) => h(data));
          } catch {
            handlers.forEach((h) => h(event.data));
          }
        }
      };

      ws.onerror = (error) => {
        console.error(`PinkSync WebSocket error on channel ${channel}:`, error);
      };

      ws.onclose = () => {
        this.connections.delete(channel);
      };

      this.connections.set(channel, ws);
    }

    // Return unsubscribe function
    return () => {
      this.messageHandlers.get(channel)?.delete(handler);
      
      // Close connection if no more handlers
      if (this.messageHandlers.get(channel)?.size === 0) {
        this.connections.get(channel)?.close();
        this.connections.delete(channel);
        this.messageHandlers.delete(channel);
      }
    };
  }

  send(channel: string, data: unknown): void {
    const ws = this.connections.get(channel);
    if (ws?.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(data));
    } else {
      console.warn(`PinkSync: No active connection to channel ${channel}`);
    }
  }

  disconnect(channel?: string): void {
    if (channel) {
      this.connections.get(channel)?.close();
      this.connections.delete(channel);
      this.messageHandlers.delete(channel);
    } else {
      this.connections.forEach((ws) => ws.close());
      this.connections.clear();
      this.messageHandlers.clear();
    }
  }
}

export function createPinkSyncClient(config: PinkSyncConfig): PinkSyncClient {
  return new PinkSyncClient(config);
}
