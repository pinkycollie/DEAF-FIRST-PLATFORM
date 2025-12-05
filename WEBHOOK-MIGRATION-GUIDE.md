# Webhook System Migration Guide

## Overview

This guide helps you migrate from the Xano webhook system to the new self-hosted webhook infrastructure that has been implemented in the DEAF-FIRST Platform.

## What Was Lost and What's Been Restored

### Lost from Xano
- Xano-hosted webhook endpoints
- Xano webhook management interface
- Automatic webhook delivery through Xano infrastructure

### Newly Implemented
- ✅ Self-hosted webhook management system
- ✅ RESTful API for webhook CRUD operations
- ✅ Incoming webhook endpoints to receive events from Xano and other services
- ✅ HMAC-SHA256 signature verification for security
- ✅ Webhook delivery tracking and history
- ✅ Support for 12 predefined event types
- ✅ Test endpoints for development
- ✅ Comprehensive documentation

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEAF-FIRST Platform                          │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Backend API (Express.js)                                 │  │
│  │                                                          │  │
│  │  ┌────────────────────┐  ┌─────────────────────────┐   │  │
│  │  │ Webhook Routes     │  │ Incoming Webhook Routes │   │  │
│  │  │ /api/webhooks      │  │ /api/incoming-webhooks  │   │  │
│  │  └────────┬───────────┘  └──────────┬──────────────┘   │  │
│  │           │                          │                   │  │
│  │           └──────────┬───────────────┘                   │  │
│  │                      │                                   │  │
│  │           ┌──────────▼───────────┐                      │  │
│  │           │  Webhook Service     │                      │  │
│  │           │  - Registration      │                      │  │
│  │           │  - Event Delivery    │                      │  │
│  │           │  - Signature Verify  │                      │  │
│  │           └──────────────────────┘                      │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
         │                                      ▲
         │ Sends webhooks to                   │ Receives webhooks from
         │ your registered URLs                │ Xano and other services
         ▼                                      │
┌─────────────────────┐              ┌─────────────────────┐
│  Your Application   │              │  External Services  │
│  - Receives events  │              │  - Xano             │
│  - Verifies sigs    │              │  - Stripe           │
│  - Processes data   │              │  - Custom services  │
└─────────────────────┘              └─────────────────────┘
```

## Migration Steps

### Step 1: Update Your Environment

Add webhook configuration to your `.env` file:

```bash
# Webhook Configuration
WEBHOOK_SECRET=your-webhook-secret-key-here
XANO_WEBHOOK_SECRET=your-xano-webhook-secret
```

Generate secure secrets:
```bash
openssl rand -hex 32  # For WEBHOOK_SECRET
openssl rand -hex 32  # For XANO_WEBHOOK_SECRET
```

### Step 2: Start the Backend Service

```bash
cd /path/to/DEAF-FIRST-PLATFORM
npm run dev:backend
```

The webhook system will be available at `http://localhost:3000/api/webhooks`

### Step 3: Register Your Webhook Endpoints

If you had webhooks configured in Xano that pointed to your application, register them in the new system:

```bash
curl -X POST http://localhost:3000/api/webhooks \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Production App Webhook",
    "url": "https://your-app.com/api/webhook",
    "events": [
      "user.created",
      "user.updated",
      "document.uploaded",
      "auth.login"
    ],
    "secret": "optional-custom-secret"
  }'
```

**Save the response!** You'll need the `id` and `secret` fields.

### Step 4: Update Xano Configuration

If you want to continue receiving events from Xano:

1. Log into your Xano workspace
2. Navigate to your API settings
3. Configure webhook URL to point to your new endpoint:
   ```
   https://your-server.com/api/incoming-webhooks/xano
   ```
4. Add the following headers in Xano webhook configuration:
   - `X-Webhook-Event`: The event type (e.g., `record.created`)
   - `X-Webhook-Signature`: Your XANO_WEBHOOK_SECRET (if implementing verification)

### Step 5: Update Your Application

Modify your application to handle webhooks from the new system:

#### Before (Xano Webhooks)
```javascript
// Your app received webhooks directly from Xano
app.post('/webhook/xano', (req, res) => {
  const event = req.body;
  // Process Xano event
  processXanoEvent(event);
  res.sendStatus(200);
});
```

#### After (New System)
```javascript
const crypto = require('crypto');

// Your app receives webhooks from DEAF-FIRST Platform
app.post('/api/webhook', (req, res) => {
  const signature = req.headers['x-webhook-signature'];
  const event = req.headers['x-webhook-event'];
  const payload = JSON.stringify(req.body);
  const secret = process.env.WEBHOOK_SECRET; // From registration
  
  // Verify signature
  const expectedSig = crypto
    .createHmac('sha256', secret)
    .update(payload)
    .digest('hex');
  
  if (!crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expectedSig))) {
    return res.status(401).json({ error: 'Invalid signature' });
  }
  
  // Process verified webhook
  console.log('Received event:', event);
  console.log('Payload:', req.body);
  
  res.status(200).json({ received: true });
});
```

### Step 6: Test the Integration

Use the test endpoint to verify your webhook is working:

```bash
curl -X POST http://localhost:3000/api/webhooks/trigger \
  -H "Content-Type: application/json" \
  -d '{
    "event": "user.created",
    "data": {
      "userId": "test-123",
      "email": "test@example.com",
      "name": "Test User"
    }
  }'
```

Check your application logs to confirm the webhook was received.

### Step 7: Monitor Deliveries

View webhook delivery history:

```bash
# Get your webhook ID
curl http://localhost:3000/api/webhooks

# View deliveries for a specific webhook
curl http://localhost:3000/api/webhooks/{webhook-id}/deliveries
```

## Event Mapping

Map your Xano events to the new event types:

| Xano Event | New Event Type | Description |
|------------|----------------|-------------|
| `user_created` | `user.created` | New user registration |
| `user_updated` | `user.updated` | User profile updated |
| `user_deleted` | `user.deleted` | User account deleted |
| `record_created` | (varies) | Map to appropriate domain event |
| `record_updated` | (varies) | Map to appropriate domain event |

## Common Issues and Solutions

### Issue: Webhooks not being received

**Solution:**
1. Check webhook is active: `GET /api/webhooks/{id}`
2. Verify URL is publicly accessible
3. Check firewall/security group settings
4. Review delivery history for error details

### Issue: Signature verification failing

**Solution:**
1. Ensure you're using the correct secret from registration
2. Verify you're hashing the raw JSON payload
3. Check that both strings are in hex format
4. Ensure no whitespace or encoding issues

### Issue: Missing events

**Solution:**
1. Verify the event type is included in webhook registration
2. Check event name matches exactly (case-sensitive)
3. Ensure webhook is active

### Issue: Local testing problems

**Solution:**
Use ngrok or similar tool to expose local server:
```bash
ngrok http 3000
# Use the ngrok URL in your webhook configuration
```

## Best Practices

### 1. Use HTTPS in Production
```json
{
  "url": "https://your-app.com/webhook"  // ✓ Good
  "url": "http://your-app.com/webhook"   // ✗ Bad (insecure)
}
```

### 2. Always Verify Signatures
```javascript
// ✓ Good: Verify before processing
if (verifySignature(payload, signature, secret)) {
  processWebhook(payload);
}

// ✗ Bad: Process without verification
processWebhook(payload);  // Security risk!
```

### 3. Respond Quickly
```javascript
// ✓ Good: Respond immediately, process async
app.post('/webhook', async (req, res) => {
  res.status(200).json({ received: true });
  await processWebhookAsync(req.body);
});

// ✗ Bad: Process synchronously
app.post('/webhook', async (req, res) => {
  await longRunningProcess(req.body);  // May timeout
  res.status(200).json({ received: true });
});
```

### 4. Handle Idempotency
```javascript
// ✓ Good: Track processed events
const processedEvents = new Set();

app.post('/webhook', (req, res) => {
  const eventId = req.headers['x-webhook-delivery'];
  
  if (processedEvents.has(eventId)) {
    return res.status(200).json({ received: true }); // Already processed
  }
  
  processWebhook(req.body);
  processedEvents.add(eventId);
  res.status(200).json({ received: true });
});
```

### 5. Monitor and Alert
```javascript
// ✓ Good: Log and monitor webhook health
app.post('/webhook', (req, res) => {
  logger.info('Webhook received', {
    event: req.headers['x-webhook-event'],
    deliveryId: req.headers['x-webhook-delivery']
  });
  
  processWebhook(req.body);
  res.status(200).json({ received: true });
});
```

## Rollback Plan

If you need to rollback to Xano:

1. Keep Xano webhooks configured in parallel during migration
2. Test thoroughly before removing Xano webhooks
3. Monitor both systems during transition period
4. Document any differences in event payloads

## Production Checklist

Before going live:

- [ ] Environment variables configured with secure secrets
- [ ] All webhooks registered and tested
- [ ] Signature verification implemented in your app
- [ ] Error handling and logging in place
- [ ] HTTPS URLs used for all webhook endpoints
- [ ] Monitoring and alerting configured
- [ ] Delivery history reviewed for any failures
- [ ] Documentation updated for your team
- [ ] Rollback plan documented and tested
- [ ] Load testing completed

## Support Resources

- **API Documentation**: [WEBHOOK-API.md](./WEBHOOK-API.md)
- **Quick Start Guide**: [QUICKSTART-WEBHOOKS.md](./QUICKSTART-WEBHOOKS.md)
- **Main Documentation**: [README.md](./README.md)

## Getting Help

If you encounter issues:

1. Check the delivery history: `GET /api/webhooks/{id}/deliveries`
2. Review server logs for detailed error messages
3. Test with the trigger endpoint to isolate issues
4. Verify signature calculation matches the documentation
5. Create an issue in the repository with:
   - Webhook configuration (hide secret)
   - Error messages
   - Delivery history
   - Steps to reproduce

## Next Steps

After successful migration:

1. Set up monitoring for webhook failures
2. Implement retry logic for failed deliveries
3. Configure alerting for webhook endpoint downtime
4. Document webhook events for your team
5. Consider implementing webhook event replay functionality
6. Set up automated testing for webhook handlers

Congratulations on successfully migrating your webhook system! 🎉
