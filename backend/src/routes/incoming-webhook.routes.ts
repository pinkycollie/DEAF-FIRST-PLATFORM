import { Router, Request, Response } from 'express';
import { WebhookEvent } from '../types/webhook.types';

const router = Router();

/**
 * POST /api/incoming-webhooks/:service
 * Receive webhook events from external services
 * This endpoint accepts webhooks from services like Xano, Stripe, etc.
 */
router.post('/:service', async (req: Request, res: Response) => {
  try {
    const service = req.params.service;
    const signature = req.headers['x-webhook-signature'] as string;
    const event = req.headers['x-webhook-event'] as string;

    // Log incoming webhook
    console.log(`[Incoming Webhook] Service: ${service}, Event: ${event}`);
    console.log(`[Incoming Webhook] Payload:`, req.body);

    // Create webhook event
    const webhookEvent: WebhookEvent = {
      id: `evt_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      event: event || 'unknown',
      timestamp: new Date().toISOString(),
      data: req.body,
      signature
    };

    // Process based on service type
    switch (service) {
      case 'xano':
        await handleXanoWebhook(webhookEvent);
        break;
      case 'stripe':
        await handleStripeWebhook(webhookEvent);
        break;
      case 'custom':
        await handleCustomWebhook(webhookEvent);
        break;
      default:
        console.log(`[Incoming Webhook] Unknown service: ${service}`);
    }

    // Respond with success
    res.status(200).json({
      success: true,
      message: 'Webhook received successfully',
      eventId: webhookEvent.id
    });
  } catch (error) {
    console.error('[Incoming Webhook] Error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to process webhook',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * Handle Xano webhooks
 */
async function handleXanoWebhook(event: WebhookEvent): Promise<void> {
  console.log('[Xano Webhook] Processing:', event.event);
  
  // Add Xano-specific processing logic here
  switch (event.event) {
    case 'record.created':
      console.log('[Xano Webhook] Record created:', event.data);
      break;
    case 'record.updated':
      console.log('[Xano Webhook] Record updated:', event.data);
      break;
    case 'record.deleted':
      console.log('[Xano Webhook] Record deleted:', event.data);
      break;
    default:
      console.log('[Xano Webhook] Unhandled event:', event.event);
  }
}

/**
 * Handle Stripe webhooks
 */
async function handleStripeWebhook(event: WebhookEvent): Promise<void> {
  console.log('[Stripe Webhook] Processing:', event.event);
  
  // Add Stripe-specific processing logic here
  switch (event.event) {
    case 'payment_intent.succeeded':
      console.log('[Stripe Webhook] Payment succeeded:', event.data);
      break;
    case 'payment_intent.failed':
      console.log('[Stripe Webhook] Payment failed:', event.data);
      break;
    default:
      console.log('[Stripe Webhook] Unhandled event:', event.event);
  }
}

/**
 * Handle custom webhooks
 */
async function handleCustomWebhook(event: WebhookEvent): Promise<void> {
  console.log('[Custom Webhook] Processing:', event.event);
  console.log('[Custom Webhook] Data:', event.data);
}

/**
 * GET /api/incoming-webhooks/health
 * Health check for incoming webhook endpoint
 */
router.get('/health', (req: Request, res: Response) => {
  res.json({
    success: true,
    message: 'Incoming webhook endpoint is healthy',
    timestamp: new Date().toISOString()
  });
});

export default router;
