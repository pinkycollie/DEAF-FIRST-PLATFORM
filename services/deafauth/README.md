# DeafAUTH - Identity Cortex

Secure authentication system designed with deaf-first principles for the MBTQ Universe.

## Overview

DeafAUTH is the foundational identity and authentication layer that provides secure, accessible authentication for all MBTQ Universe services. It's built with deaf-first principles, ensuring accessibility features are integrated into every aspect of the authentication process.

## API Endpoints

**Base URL:** `https://api.mbtquniverse.com/auth`

**Note:** The endpoints below show full paths for clarity. In the OpenAPI specification, these are defined as relative paths (e.g., `/register`) with the base URL specified in the `servers` section.

### Authentication

- `POST /auth/register` - User registration
- `POST /auth/login` - User authentication
- `GET /auth/verify` - Token verification
- `POST /auth/refresh` - Token refresh

## Features

- JWT-based authentication
- Deaf-first accessible authentication flows
- Secure token management
- Refresh token rotation
- Integration with all MBTQ services

## Environment Variables

```bash
# DeafAUTH Configuration
DEAFAUTH_API_KEY=your_api_key_here
DEAFAUTH_SECRET=your_secret_here
DEAFAUTH_TOKEN_EXPIRY=3600
DEAFAUTH_REFRESH_TOKEN_EXPIRY=604800
DEAFAUTH_JWT_ALGORITHM=HS256
```

## Middleware Sample

```javascript
const deafAuthMiddleware = async (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  try {
    const decoded = await verifyDeafAuthToken(token);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(403).json({ error: 'Invalid token' });
  }
};

module.exports = deafAuthMiddleware;
```

## Integration

All MBTQ Universe services use DeafAUTH for authentication. Include the Bearer token in the Authorization header:

```bash
Authorization: Bearer <your_token>
```

## OpenAPI Specification

See [openapi/openapi.yaml](openapi/openapi.yaml) for the complete API specification.

## Security

- All passwords are hashed using bcrypt
- Tokens are signed with HMAC-SHA256
- Refresh tokens are stored securely and rotated on use
- Rate limiting on authentication endpoints
- Audit logging for all authentication events
