import crypto from 'crypto';
import { WebhookConfig, WebhookEvent, WebhookDelivery } from '../types/webhook.types';

/**
 * In-memory storage for webhooks (in production, use a database)
 */
class WebhookService {
  private webhooks: Map<string, WebhookConfig> = new Map();
  private deliveries: Map<string, WebhookDelivery> = new Map();

  /**
   * Register a new webhook
   */
  registerWebhook(name: string, url: string, events: string[], secret?: string): WebhookConfig {
    const id = this.generateId();
    const generatedSecret = secret || this.generateSecret();
    
    const webhook: WebhookConfig = {
      id,
      name,
      url,
      events,
      secret: generatedSecret,
      active: true,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    this.webhooks.set(id, webhook);
    return webhook;
  }

  /**
   * Get all registered webhooks
   */
  getAllWebhooks(): WebhookConfig[] {
    return Array.from(this.webhooks.values());
  }

  /**
   * Get a specific webhook by ID
   */
  getWebhook(id: string): WebhookConfig | undefined {
    return this.webhooks.get(id);
  }

  /**
   * Update a webhook
   */
  updateWebhook(id: string, updates: Partial<WebhookConfig>): WebhookConfig | null {
    const webhook = this.webhooks.get(id);
    if (!webhook) return null;

    const updated = {
      ...webhook,
      ...updates,
      id: webhook.id, // Prevent ID change
      updatedAt: new Date().toISOString(),
    };

    this.webhooks.set(id, updated);
    return updated;
  }

  /**
   * Delete a webhook
   */
  deleteWebhook(id: string): boolean {
    return this.webhooks.delete(id);
  }

  /**
   * Trigger webhook event
   */
  async triggerEvent(eventType: string, data: any): Promise<void> {
    const webhooks = Array.from(this.webhooks.values()).filter(
      (webhook) => webhook.active && webhook.events.includes(eventType)
    );

    const deliveryPromises = webhooks.map((webhook) =>
      this.deliverWebhook(webhook, eventType, data)
    );

    await Promise.allSettled(deliveryPromises);
  }

  /**
   * Deliver webhook to endpoint
   */
  private async deliverWebhook(
    webhook: WebhookConfig,
    eventType: string,
    data: any
  ): Promise<void> {
    const deliveryId = this.generateId();
    const payload = {
      event: eventType,
      timestamp: new Date().toISOString(),
      data,
    };

    const signature = this.generateSignature(JSON.stringify(payload), webhook.secret);

    const delivery: WebhookDelivery = {
      id: deliveryId,
      webhookId: webhook.id,
      event: eventType,
      payload,
      attempts: 1,
      status: 'pending',
      timestamp: new Date().toISOString(),
    };

    this.deliveries.set(deliveryId, delivery);

    try {
      const response = await fetch(webhook.url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Webhook-Signature': signature,
          'X-Webhook-Event': eventType,
          'X-Webhook-Delivery': deliveryId,
        },
        body: JSON.stringify(payload),
      });

      delivery.response = {
        status: response.status,
        body: await response.text(),
      };
      delivery.status = response.ok ? 'success' : 'failed';
    } catch (error) {
      delivery.status = 'failed';
      delivery.response = {
        status: 0,
        body: error instanceof Error ? error.message : 'Unknown error',
      };
    }

    this.deliveries.set(deliveryId, delivery);
  }

  /**
   * Get delivery history for a webhook
   */
  getDeliveries(webhookId?: string): WebhookDelivery[] {
    const deliveries = Array.from(this.deliveries.values());
    if (webhookId) {
      return deliveries.filter((d) => d.webhookId === webhookId);
    }
    return deliveries;
  }

  /**
   * Verify webhook signature
   */
  verifySignature(payload: string, signature: string, secret: string): boolean {
    const expectedSignature = this.generateSignature(payload, secret);
    // Normalize signatures to ensure they're in the same format (hex)
    const normalizedSignature = signature.toLowerCase().trim();
    const normalizedExpected = expectedSignature.toLowerCase().trim();
    
    // Ensure both signatures have the same length before comparison
    if (normalizedSignature.length !== normalizedExpected.length) {
      return false;
    }
    
    return crypto.timingSafeEqual(
      Buffer.from(normalizedSignature, 'hex'),
      Buffer.from(normalizedExpected, 'hex')
    );
  }

  /**
   * Generate HMAC signature
   */
  private generateSignature(payload: string, secret: string): string {
    return crypto.createHmac('sha256', secret).update(payload).digest('hex');
  }

  /**
   * Generate unique ID
   */
  private generateId(): string {
    return `wh_${Date.now()}_${Math.random().toString(36).slice(2, 11)}`;
  }

  /**
   * Generate webhook secret
   */
  private generateSecret(): string {
    return crypto.randomBytes(32).toString('hex');
  }
}

// Export singleton instance
export const webhookService = new WebhookService();
