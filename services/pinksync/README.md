# PinkSync - Accessibility Engine

Real-time accessibility features and synchronization for the MBTQ Universe.

## Overview

PinkSync is the accessibility engine that provides real-time synchronization of accessibility preferences across all MBTQ Universe services. It acts as an API broker network of partners' APIs that enhance deaf accessibility.

## API Endpoints

**Base URL:** `https://api.mbtquniverse.com/sync`

**Note:** The endpoints below show full paths for clarity. In the OpenAPI specification, these are defined as relative paths (e.g., `/status`) with the base URL specified in the `servers` section.

### Synchronization

- `GET /sync/status` - Check synchronization status
- `POST /sync/preferences` - Update accessibility preferences
- `GET /sync/features` - List available accessibility features

## Features

- Real-time preference synchronization
- ASL (American Sign Language) mode support
- Caption management
- Contrast and font size preferences
- Integration with Google Cloud Vision API
- Google Speech-to-Text for real-time captioning
- Multi-language support via Google Translate API

## Environment Variables

```bash
# PinkSync Configuration
PINKSYNC_API_ENDPOINT=https://api.pinksync.mbtq.dev
PINKSYNC_WS_ENDPOINT=wss://sync.mbtq.dev
PINKSYNC_GOOGLE_CLOUD_API_KEY=your_google_api_key
PINKSYNC_SPEECH_TO_TEXT_ENABLED=true
PINKSYNC_VISION_API_ENABLED=true
```

## Middleware Sample

```javascript
const pinkSyncMiddleware = async (req, res, next) => {
  const userId = req.user?.id;
  
  if (userId) {
    const preferences = await getPinkSyncPreferences(userId);
    req.accessibilityPrefs = preferences;
  }
  
  next();
};

module.exports = pinkSyncMiddleware;
```

## Accessibility Preferences Schema

```json
{
  "captions": true,
  "aslMode": true,
  "contrast": "high",
  "fontSize": "large"
}
```

## Integration with Google APIs

PinkSync integrates with multiple Google Cloud services:

- **Google Cloud Vision API** - Visual accessibility features
- **Google Speech-to-Text** - Real-time captioning
- **Google Translate API** - Multi-language support

## OpenAPI Specification

See [openapi/openapi.yaml](openapi/openapi.yaml) for the complete API specification.

## Fastify Implementation

PinkSync has been recently updated to use Fastify for improved performance. See the [pinkycollie/pinksync](https://github.com/pinkycollie/pinksync) repository for implementation details.
