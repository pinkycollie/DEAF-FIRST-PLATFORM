import { Router, Request, Response } from 'express';
import { webhookService } from '../webhooks/webhook.service';
import { WebhookRequest, WebhookEventType } from '../types/webhook.types';

const router = Router();

/**
 * GET /api/webhooks
 * List all registered webhooks
 */
router.get('/', (req: Request, res: Response) => {
  try {
    const webhooks = webhookService.getAllWebhooks();
    res.json({
      success: true,
      count: webhooks.length,
      webhooks: webhooks.map(webhook => ({
        ...webhook,
        secret: '***' // Hide secret in response
      }))
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve webhooks',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * GET /api/webhooks/:id
 * Get a specific webhook by ID
 */
router.get('/:id', (req: Request, res: Response) => {
  try {
    const webhook = webhookService.getWebhook(req.params.id);
    
    if (!webhook) {
      return res.status(404).json({
        success: false,
        error: 'Webhook not found'
      });
    }

    res.json({
      success: true,
      webhook: {
        ...webhook,
        secret: '***' // Hide secret in response
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve webhook',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * POST /api/webhooks
 * Register a new webhook
 */
router.post('/', (req: Request, res: Response) => {
  try {
    const { name, url, events, secret }: WebhookRequest = req.body;

    // Validation
    if (!name || !url || !events || !Array.isArray(events)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid request',
        message: 'Name, URL, and events array are required'
      });
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return res.status(400).json({
        success: false,
        error: 'Invalid URL',
        message: 'URL must start with http:// or https://'
      });
    }

    const webhook = webhookService.registerWebhook(name, url, events, secret);

    res.status(201).json({
      success: true,
      message: 'Webhook registered successfully',
      webhook
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to register webhook',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * PUT /api/webhooks/:id
 * Update an existing webhook
 */
router.put('/:id', (req: Request, res: Response) => {
  try {
    const { name, url, events, active } = req.body;
    const updates: any = {};

    if (name !== undefined) updates.name = name;
    if (url !== undefined) updates.url = url;
    if (events !== undefined) updates.events = events;
    if (active !== undefined) updates.active = active;

    const webhook = webhookService.updateWebhook(req.params.id, updates);

    if (!webhook) {
      return res.status(404).json({
        success: false,
        error: 'Webhook not found'
      });
    }

    res.json({
      success: true,
      message: 'Webhook updated successfully',
      webhook: {
        ...webhook,
        secret: '***' // Hide secret in response
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to update webhook',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * DELETE /api/webhooks/:id
 * Delete a webhook
 */
router.delete('/:id', (req: Request, res: Response) => {
  try {
    const deleted = webhookService.deleteWebhook(req.params.id);

    if (!deleted) {
      return res.status(404).json({
        success: false,
        error: 'Webhook not found'
      });
    }

    res.json({
      success: true,
      message: 'Webhook deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to delete webhook',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * POST /api/webhooks/trigger
 * Manually trigger a webhook event (for testing)
 */
router.post('/trigger', async (req: Request, res: Response) => {
  try {
    const { event, data } = req.body;

    if (!event || !data) {
      return res.status(400).json({
        success: false,
        error: 'Invalid request',
        message: 'Event and data are required'
      });
    }

    await webhookService.triggerEvent(event, data);

    res.json({
      success: true,
      message: 'Webhook event triggered successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to trigger webhook event',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * GET /api/webhooks/:id/deliveries
 * Get delivery history for a webhook
 */
router.get('/:id/deliveries', (req: Request, res: Response) => {
  try {
    const deliveries = webhookService.getDeliveries(req.params.id);

    res.json({
      success: true,
      count: deliveries.length,
      deliveries
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve deliveries',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * GET /api/webhooks/events/types
 * Get list of available webhook event types
 */
router.get('/events/types', (req: Request, res: Response) => {
  try {
    const eventTypes = Object.values(WebhookEventType);
    
    res.json({
      success: true,
      count: eventTypes.length,
      events: eventTypes
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve event types',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;
