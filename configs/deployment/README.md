# Docker Compose Setup Guide

This directory contains Docker configurations for running the DEAF-FIRST Platform in containers.

## Quick Start

### Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+

### Start All Services

```bash
# From the configs/deployment directory
docker-compose up -d

# Or from the project root
npm run docker:up
```

### Stop All Services

```bash
docker-compose down

# Or from the project root
npm run docker:down
```

### View Logs

```bash
docker-compose logs -f

# Or view specific service
docker-compose logs -f backend
```

## Services

The Docker Compose setup includes:

- **PostgreSQL** (port 5432) - Main database
- **Redis** (port 6379) - Cache and pub/sub
- **Backend** (port 3000) - Main API server
- **DeafAUTH** (port 3002) - Authentication service
- **PinkSync** (port 3003) - Real-time sync service
- **FibonRose** (port 3004) - Optimization service
- **Accessibility Nodes** (port 3005) - A11Y features
- **AI Services** (port 3006) - AI workflows
- **Frontend** (port 5173) - React application

## Environment Variables

Create a `.env` file in the project root:

```env
# OpenAI API Key (required for AI services)
OPENAI_API_KEY=your-openai-api-key

# JWT Secret (change in production)
JWT_SECRET=your-secure-jwt-secret

# Webhook Secret (change in production)
WEBHOOK_SECRET=your-webhook-secret
```

## Accessing Services

Once all services are running:

- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:3000
- **DeafAUTH**: http://localhost:3002
- **PinkSync WebSocket**: ws://localhost:3003
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379

## Development Mode

The Docker Compose setup supports hot-reloading in development:

1. Source code is mounted as volumes
2. Changes are reflected immediately
3. Node modules are preserved in container

## Building Images

Build all images:
```bash
docker-compose build
```

Build specific service:
```bash
docker-compose build backend
```

## Health Checks

Services include health checks:
- PostgreSQL: `pg_isready` check
- Redis: `redis-cli ping` check

## Production Deployment

For production, use a separate compose file:

```bash
docker-compose -f docker-compose.prod.yml up -d
```

Production considerations:
- Use environment-specific secrets
- Enable SSL/TLS
- Configure resource limits
- Set up monitoring
- Enable automated backups

## Troubleshooting

### Port Conflicts

If ports are already in use, modify the port mappings in `docker-compose.yml`:

```yaml
services:
  backend:
    ports:
      - "3001:3000"  # Use different host port
```

### Database Connection Issues

Ensure PostgreSQL is healthy:
```bash
docker-compose ps
docker-compose logs postgres
```

### Clean Restart

Remove all containers and volumes:
```bash
docker-compose down -v
docker-compose up -d
```

## Dockerfile Templates

Individual Dockerfiles for each service are provided:
- `Dockerfile.frontend` - React frontend
- `Dockerfile.backend` - Express backend
- `Dockerfile.deafauth` - DeafAUTH service
- `Dockerfile.pinksync` - PinkSync service
- `Dockerfile.fibonrose` - FibonRose service
- `Dockerfile.a11y` - Accessibility Nodes
- `Dockerfile.ai` - AI Services

## Network Configuration

Services communicate via the `deaf-first-network` bridge network, enabling service-to-service communication using service names as hostnames.

## Data Persistence

Volumes for data persistence:
- `deaf-first-postgres-data` - PostgreSQL data
- `deaf-first-redis-data` - Redis data

## Cleanup

Remove unused images and volumes:
```bash
docker system prune -a --volumes
```

---

For more information, see the main [README.md](../../README.md).
