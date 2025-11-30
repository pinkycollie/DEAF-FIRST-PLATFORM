# Uptime Robot Monitoring Configuration
# Free Tier Setup for DEAF-FIRST Platform

## Recommended Monitors

### 1. ASL Biometrics Health Check
```yaml
Monitor Type: HTTP(s)
URL: https://your-deployment-url/health
Friendly Name: DEAF-FIRST ASL Biometrics
Monitoring Interval: 5 minutes (Free tier minimum)
Alert Contacts: [Your alert contacts]
HTTP Method: GET
Expected Status: 200
Keyword Type: Contains
Keyword: "healthy"
```

### 2. Telehealth API Availability
```yaml
Monitor Type: HTTP(s)
URL: https://your-deployment-url/api/admin/stats
Friendly Name: DEAF-FIRST Telehealth API
Monitoring Interval: 5 minutes
Alert Contacts: [Your alert contacts]
HTTP Method: GET
Expected Status: 200
```

### 3. Frontend Health
```yaml
Monitor Type: HTTP(s)
URL: https://your-frontend-url
Friendly Name: DEAF-FIRST Frontend
Monitoring Interval: 5 minutes
Alert Contacts: [Your alert contacts]
HTTP Method: GET
Expected Status: 200
```

## API Setup (For Automation)

### Get Your API Key
1. Log in to Uptime Robot
2. Go to My Settings > API Settings
3. Create a Main API Key (read-only for monitoring)

### Create Monitor via API
```bash
curl -X POST \
  https://api.uptimerobot.com/v2/newMonitor \
  -H 'Content-Type: application/json' \
  -d '{
    "api_key": "YOUR_API_KEY",
    "friendly_name": "DEAF-FIRST ASL Biometrics",
    "url": "https://your-deployment-url/health",
    "type": 1,
    "interval": 300,
    "keyword_type": 2,
    "keyword_value": "healthy"
  }'
```

### Get Monitor Status
```bash
curl -X POST \
  https://api.uptimerobot.com/v2/getMonitors \
  -H 'Content-Type: application/json' \
  -d '{
    "api_key": "YOUR_API_KEY",
    "format": "json"
  }'
```

## Free Tier Limits
- 50 monitors
- 5-minute monitoring intervals
- Email/Webhook/SMS alerts
- Public status pages

## Recommended Alert Configuration

### Email Alerts
- Down alerts: Immediately
- Up alerts: After 3 consecutive successful checks
- SSL certificate expiry: 30 days before

### Webhook Integration (Optional)
For Slack/Discord notifications:
```json
{
  "url": "https://hooks.slack.com/services/YOUR/WEBHOOK/URL",
  "payload": {
    "text": "*{{monitorFriendlyName}}* is {{alertTypeFriendlyName}}",
    "attachments": [
      {
        "color": "{{alertType === 1 ? 'danger' : 'good'}}",
        "fields": [
          { "title": "URL", "value": "{{monitorURL}}", "short": true },
          { "title": "Duration", "value": "{{alertDuration}}", "short": true }
        ]
      }
    ]
  }
}
```

## Status Page Configuration

### Create Public Status Page
1. Go to Status Pages in Uptime Robot dashboard
2. Click "Add Status Page"
3. Configure:
   - Custom domain (optional): status.your-domain.com
   - Show monitors: Select DEAF-FIRST monitors
   - Design: Choose accessible color scheme

### Accessibility Considerations
- Use high-contrast status indicators
- Include clear text descriptions
- Support for screen readers
- Mobile-responsive design

## Integration with DEAF-FIRST Platform

### Health Check Response Format
Ensure your /health endpoint returns:
```json
{
  "status": "healthy",
  "service": "ASL Biometrics",
  "version": "1.0.0",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "features": [
    "hand-motion-detection",
    "identity-matching",
    "motion-analysis",
    "telehealth-verification"
  ]
}
```

### Custom Metrics (Advanced)
For detailed monitoring, expose:
```json
GET /api/admin/metrics
{
  "uptime": 99.95,
  "requestsPerMinute": 45,
  "averageResponseTime": 120,
  "activeSessionS": 5,
  "errorRate": 0.01
}
```
