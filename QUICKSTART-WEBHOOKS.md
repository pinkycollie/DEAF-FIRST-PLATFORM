# Webhook System Quick Start

This guide will help you quickly set up and use the webhook system that replaces the Xano webhook functionality.

## What's Been Restored

The webhook system provides:
- ✅ Webhook registration and management API
- ✅ Incoming webhook endpoints for external services (Xano, Stripe, custom)
- ✅ Webhook signature verification for security
- ✅ Webhook delivery history and logging
- ✅ Support for multiple event types
- ✅ Test endpoints for webhook development

## Quick Start

### 1. Start the Backend Server

```bash
npm run dev:backend
```

The server will start on port 3000 (or your configured BACKEND_PORT).

### 2. Register a Webhook

Register your webhook endpoint to receive events:

```bash
curl -X POST http://localhost:3000/api/webhooks \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My App Webhook",
    "url": "https://your-app.com/webhook",
    "events": ["user.created", "user.updated"]
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Webhook registered successfully",
  "webhook": {
    "id": "wh_...",
    "name": "My App Webhook",
    "url": "https://your-app.com/webhook",
    "events": ["user.created", "user.updated"],
    "secret": "generated-secret-key",
    "active": true
  }
}
```

**Important:** Save the `secret` key! You'll need it to verify webhook signatures.

### 3. Configure Xano to Send Webhooks

If you're migrating from Xano:

1. In Xano, go to your API settings
2. Configure webhook URL: `http://your-server:3000/api/incoming-webhooks/xano`
3. Select the events you want to receive

### 4. Test Your Webhook

Send a test webhook event:

```bash
curl -X POST http://localhost:3000/api/webhooks/trigger \
  -H "Content-Type: application/json" \
  -d '{
    "event": "user.created",
    "data": {
      "userId": "123",
      "email": "test@example.com"
    }
  }'
```

### 5. View Webhook Deliveries

Check the delivery status of your webhooks:

```bash
curl http://localhost:3000/api/webhooks/{webhook-id}/deliveries
```

## Available Endpoints

- `GET /api/webhooks` - List all webhooks
- `POST /api/webhooks` - Register a new webhook
- `GET /api/webhooks/:id` - Get webhook details
- `PUT /api/webhooks/:id` - Update a webhook
- `DELETE /api/webhooks/:id` - Delete a webhook
- `GET /api/webhooks/:id/deliveries` - View delivery history
- `GET /api/webhooks/events/types` - List available event types
- `POST /api/webhooks/trigger` - Trigger a test event
- `POST /api/incoming-webhooks/:service` - Receive external webhooks

## Available Event Types

- `user.created` - New user created
- `user.updated` - User information updated
- `user.deleted` - User deleted
- `auth.login` - User logged in
- `auth.logout` - User logged out
- `document.uploaded` - Document uploaded
- `document.processed` - Document processing completed
- `accessibility.request` - Accessibility feature requested
- `sync.started` - Synchronization started
- `sync.completed` - Synchronization completed
- `ai.process.started` - AI processing started
- `ai.process.completed` - AI processing completed

## Verifying Webhook Signatures

When you receive a webhook, verify the signature:

```javascript
const crypto = require('crypto');

function verifyWebhook(payload, signature, secret) {
  const expectedSignature = crypto
    .createHmac('sha256', secret)
    .update(payload)
    .digest('hex');
  
  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(expectedSignature)
  );
}

// In your webhook handler:
app.post('/webhook', (req, res) => {
  const signature = req.headers['x-webhook-signature'];
  const payload = JSON.stringify(req.body);
  
  if (verifyWebhook(payload, signature, YOUR_SECRET)) {
    // Process webhook
    console.log('Valid webhook received:', req.body);
    res.status(200).send('OK');
  } else {
    res.status(401).send('Invalid signature');
  }
});
```

## Receiving Xano Webhooks

To receive webhooks from Xano:

**Endpoint:** `POST /api/incoming-webhooks/xano`

**Xano sends:**
```json
{
  "event": "record.created",
  "table": "users",
  "data": {
    "id": 123,
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

The system automatically logs and processes these events.

## Environment Variables

Add to your `.env` file:

```env
WEBHOOK_SECRET=your-webhook-secret-key-here
XANO_WEBHOOK_SECRET=your-xano-webhook-secret
```

## Troubleshooting

### Webhook not receiving events
1. Check that the webhook is active: `GET /api/webhooks/:id`
2. Verify the URL is accessible from the server
3. Check delivery history: `GET /api/webhooks/:id/deliveries`

### Signature verification failing
1. Ensure you're using the correct secret
2. Verify you're hashing the raw JSON payload
3. Check that the signature header is being sent

### Testing locally
Use tools like [ngrok](https://ngrok.com/) to expose your local server:
```bash
ngrok http 3000
```

Then use the ngrok URL as your webhook URL.

## Next Steps

- See [WEBHOOK-API.md](./WEBHOOK-API.md) for complete API documentation
- Configure your production webhook URLs
- Set up monitoring for webhook deliveries
- Implement error handling and retry logic in your webhook handlers

## Need Help?

- Check the logs: Server logs show all incoming webhook events
- Review deliveries: Use the delivery history API to debug issues
- Test endpoints: Use the trigger endpoint to simulate events
