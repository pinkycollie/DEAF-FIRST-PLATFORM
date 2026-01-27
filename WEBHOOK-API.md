# Webhook API Documentation

## Overview

The DEAF-FIRST Platform webhook system allows you to register and manage webhooks to receive real-time notifications about events in the platform. This replaces the functionality that was previously handled by Xano.

## Base URL

```
http://localhost:3000/api
```

## Webhook Management Endpoints

### 1. List All Webhooks

Get a list of all registered webhooks.

**Endpoint:** `GET /webhooks`

**Response:**
```json
{
  "success": true,
  "count": 2,
  "webhooks": [
    {
      "id": "wh_1234567890_abc123",
      "name": "Production Webhook",
      "url": "https://example.com/webhook",
      "events": ["user.created", "user.updated"],
      "secret": "***",
      "active": true,
      "createdAt": "2025-12-05T07:00:00.000Z",
      "updatedAt": "2025-12-05T07:00:00.000Z"
    }
  ]
}
```

### 2. Get Specific Webhook

Retrieve details of a specific webhook by ID.

**Endpoint:** `GET /webhooks/:id`

**Response:**
```json
{
  "success": true,
  "webhook": {
    "id": "wh_1234567890_abc123",
    "name": "Production Webhook",
    "url": "https://example.com/webhook",
    "events": ["user.created"],
    "secret": "***",
    "active": true,
    "createdAt": "2025-12-05T07:00:00.000Z",
    "updatedAt": "2025-12-05T07:00:00.000Z"
  }
}
```

### 3. Register New Webhook

Create a new webhook registration.

**Endpoint:** `POST /webhooks`

**Request Body:**
```json
{
  "name": "My Webhook",
  "url": "https://example.com/webhook",
  "events": ["user.created", "user.updated"],
  "secret": "optional-custom-secret"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Webhook registered successfully",
  "webhook": {
    "id": "wh_1234567890_abc123",
    "name": "My Webhook",
    "url": "https://example.com/webhook",
    "events": ["user.created", "user.updated"],
    "secret": "generated-or-custom-secret",
    "active": true,
    "createdAt": "2025-12-05T07:00:00.000Z",
    "updatedAt": "2025-12-05T07:00:00.000Z"
  }
}
```

### 4. Update Webhook

Update an existing webhook.

**Endpoint:** `PUT /webhooks/:id`

**Request Body:**
```json
{
  "name": "Updated Webhook Name",
  "url": "https://new-url.com/webhook",
  "events": ["user.created", "user.deleted"],
  "active": false
}
```

**Response:**
```json
{
  "success": true,
  "message": "Webhook updated successfully",
  "webhook": {
    "id": "wh_1234567890_abc123",
    "name": "Updated Webhook Name",
    "url": "https://new-url.com/webhook",
    "events": ["user.created", "user.deleted"],
    "secret": "***",
    "active": false,
    "createdAt": "2025-12-05T07:00:00.000Z",
    "updatedAt": "2025-12-05T08:00:00.000Z"
  }
}
```

### 5. Delete Webhook

Delete a webhook registration.

**Endpoint:** `DELETE /webhooks/:id`

**Response:**
```json
{
  "success": true,
  "message": "Webhook deleted successfully"
}
```

### 6. Get Delivery History

View delivery history for a specific webhook.

**Endpoint:** `GET /webhooks/:id/deliveries`

**Response:**
```json
{
  "success": true,
  "count": 5,
  "deliveries": [
    {
      "id": "del_1234567890_xyz789",
      "webhookId": "wh_1234567890_abc123",
      "event": "user.created",
      "payload": {
        "event": "user.created",
        "timestamp": "2025-12-05T07:00:00.000Z",
        "data": { "userId": "123", "email": "user@example.com" }
      },
      "response": {
        "status": 200,
        "body": "OK"
      },
      "attempts": 1,
      "status": "success",
      "timestamp": "2025-12-05T07:00:00.000Z"
    }
  ]
}
```

### 7. List Available Event Types

Get a list of all available webhook event types.

**Endpoint:** `GET /webhooks/events/types`

**Response:**
```json
{
  "success": true,
  "count": 12,
  "events": [
    "user.created",
    "user.updated",
    "user.deleted",
    "auth.login",
    "auth.logout",
    "document.uploaded",
    "document.processed",
    "accessibility.request",
    "sync.started",
    "sync.completed",
    "ai.process.started",
    "ai.process.completed"
  ]
}
```

### 8. Trigger Webhook Event (Testing)

Manually trigger a webhook event for testing purposes.

**Endpoint:** `POST /webhooks/trigger`

**Request Body:**
```json
{
  "event": "user.created",
  "data": {
    "userId": "123",
    "email": "test@example.com",
    "name": "Test User"
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Webhook event triggered successfully"
}
```

## Incoming Webhook Endpoints

These endpoints receive webhooks from external services like Xano.

### Receive External Webhook

**Endpoint:** `POST /incoming-webhooks/:service`

Where `:service` can be:
- `xano` - For Xano webhooks
- `stripe` - For Stripe webhooks
- `custom` - For custom webhooks

**Headers:**
- `X-Webhook-Signature`: HMAC signature for verification
- `X-Webhook-Event`: Event type

**Request Body:** (varies by service)
```json
{
  "event": "record.created",
  "data": {
    "id": "123",
    "table": "users",
    "record": { "name": "John Doe" }
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Webhook received successfully",
  "eventId": "evt_1234567890_xyz789"
}
```

### Health Check

**Endpoint:** `GET /incoming-webhooks/health`

**Response:**
```json
{
  "success": true,
  "message": "Incoming webhook endpoint is healthy",
  "timestamp": "2025-12-05T07:00:00.000Z"
}
```

## Webhook Security

### Signature Verification

All outgoing webhooks include an `X-Webhook-Signature` header containing an HMAC-SHA256 signature of the payload.

To verify a webhook:

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
```

### Headers

Every webhook delivery includes these headers:
- `Content-Type`: `application/json`
- `X-Webhook-Signature`: HMAC signature for verification
- `X-Webhook-Event`: The event type (e.g., "user.created")
- `X-Webhook-Delivery`: Unique delivery ID

## Event Types

### User Events
- `user.created` - Triggered when a new user is created
- `user.updated` - Triggered when user information is updated
- `user.deleted` - Triggered when a user is deleted

### Authentication Events
- `auth.login` - Triggered when a user logs in
- `auth.logout` - Triggered when a user logs out

### Document Events
- `document.uploaded` - Triggered when a document is uploaded
- `document.processed` - Triggered when document processing completes

### Accessibility Events
- `accessibility.request` - Triggered when accessibility features are requested

### Sync Events
- `sync.started` - Triggered when synchronization begins
- `sync.completed` - Triggered when synchronization completes

### AI Events
- `ai.process.started` - Triggered when AI processing begins
- `ai.process.completed` - Triggered when AI processing completes

## Example Webhook Payload

```json
{
  "event": "user.created",
  "timestamp": "2025-12-05T07:00:00.000Z",
  "data": {
    "userId": "usr_1234567890",
    "email": "user@example.com",
    "name": "John Doe",
    "preferences": {
      "signLanguage": true,
      "visualAccessibility": true
    }
  }
}
```

## Migrating from Xano

If you were previously using Xano webhooks:

1. **Register your webhook endpoints** using the `POST /webhooks` endpoint
2. **Configure incoming webhooks** to receive events from Xano at `/incoming-webhooks/xano`
3. **Update your Xano configuration** to point to your new webhook URL
4. **Test webhook delivery** using the trigger endpoint

## Error Handling

All endpoints return consistent error responses:

```json
{
  "success": false,
  "error": "Error type",
  "message": "Detailed error message"
}
```

Common HTTP status codes:
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `404` - Not Found
- `500` - Internal Server Error

## Rate Limiting

Currently, there are no rate limits applied to webhook endpoints. In production, consider implementing rate limiting based on your needs.

## Best Practices

1. **Verify signatures** - Always verify webhook signatures to ensure authenticity
2. **Handle idempotency** - Webhook events may be delivered multiple times; handle duplicates gracefully
3. **Respond quickly** - Return a 200 response as soon as possible; process webhooks asynchronously
4. **Log deliveries** - Use the delivery history endpoint to monitor webhook health
5. **Use HTTPS** - Always use HTTPS URLs for webhook endpoints in production
6. **Rotate secrets** - Periodically rotate webhook secrets for security

## Support

For issues or questions about the webhook system, please refer to the main documentation or create an issue in the repository.
