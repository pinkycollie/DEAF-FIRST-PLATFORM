# 360Magicians - AI Agent Platform

Intelligent automation and assistance agents for the MBTQ Universe.

## Overview

360Magicians is a comprehensive AI agent platform providing intelligent automation, document processing, and assistance for deaf-first services. It supports multiple AI models and provides extensive capabilities for agent management, workflow orchestration, and knowledge management.

## API Endpoints

**Base URL:** `https://api.mbtquniverse.com/ai`

**Note:** The endpoints below show full paths for clarity. In the OpenAPI specification, these are defined as relative paths with the base URL specified in the `servers` section. Path parameters use `{paramName}` syntax in the OpenAPI spec but are shown as `:paramName` here for readability.

### Agents

- `POST /ai/agents` - Create agent
- `GET /ai/agents` - List agents
- `GET /ai/agents/:agentId` - Get agent
- `PATCH /ai/agents/:agentId` - Update agent config
- `DELETE /ai/agents/:agentId` - Delete agent
- `POST /ai/agents/:agentId/clone` - Clone agent

### Execution and Runs

- `POST /ai/agents/:agentId/execute` - One-off execution with input
- `POST /ai/agents/:agentId/runs` - Start a long-running run
- `GET /ai/runs` - List runs
- `GET /ai/runs/:runId` - Run status and output stream pointer
- `POST /ai/runs/:runId/cancel` - Cancel run
- `GET /ai/runs/:runId/logs` - Execution logs
- `GET /ai/runs/:runId/artifacts` - Generated files or outputs

### Tasks and Queue

- `POST /ai/tasks` - Enqueue task for any agent
- `GET /ai/tasks` - List tasks with filters
- `GET /ai/tasks/:taskId` - Task status
- `POST /ai/tasks/:taskId/cancel` - Cancel task
- `POST /ai/tasks/:taskId/retry` - Retry failed task

### Tools and Capabilities

- `GET /ai/tools` - List available tools
- `POST /ai/tools` - Register custom tool
- `GET /ai/tools/:toolId` - Tool details
- `PATCH /ai/tools/:toolId` - Update tool
- `DELETE /ai/tools/:toolId` - Remove tool
- `POST /ai/agents/:agentId/tools/:toolId/enable` - Enable tool for agent
- `POST /ai/agents/:agentId/tools/:toolId/disable` - Disable tool for agent

### Models and Routing

- `GET /ai/models` - List supported models
- `PATCH /ai/agents/:agentId/model` - Set primary model
- `POST /ai/agents/:agentId/model/fallbacks` - Set fallbacks or routing rules

### Memory and Context

- `GET /ai/agents/:agentId/memory` - Fetch memory items
- `POST /ai/agents/:agentId/memory` - Upsert memory
- `DELETE /ai/agents/:agentId/memory/:memoryId` - Delete memory
- `POST /ai/agents/:agentId/context` - Attach ephemeral context for next run

### Files, Knowledge, and Embeddings

- `POST /ai/agents/:agentId/files` - Upload knowledge file
- `GET /ai/agents/:agentId/files` - List files
- `DELETE /ai/agents/:agentId/files/:fileId` - Remove file
- `POST /ai/agents/:agentId/ingest` - Start ingestion and embedding
- `GET /ai/agents/:agentId/ingest/:jobId` - Ingestion status
- `POST /ai/search` - RAG style query across agent knowledge

### Workflows and Graphs

- `POST /ai/workflows` - Create workflow DAG
- `GET /ai/workflows` - List workflows
- `GET /ai/workflows/:workflowId` - Workflow details
- `POST /ai/workflows/:workflowId/execute` - Run workflow
- `GET /ai/workflow-runs/:runId` - Workflow run status

### Scheduling

- `POST /ai/agents/:agentId/schedules` - Create schedule
- `GET /ai/agents/:agentId/schedules` - List schedules
- `PATCH /ai/schedules/:scheduleId` - Update
- `DELETE /ai/schedules/:scheduleId` - Delete

### Webhooks and Events

- `POST /ai/webhooks` - Register webhook
- `GET /ai/webhooks` - List webhooks
- `DELETE /ai/webhooks/:webhookId` - Delete
- `POST /ai/events/test` - Send test event
- `GET /ai/events` - Event log

### Secrets and Configuration

- `GET /ai/secrets` - List names
- `POST /ai/secrets` - Set or rotate secret
- `DELETE /ai/secrets/:name` - Delete secret
- `GET /ai/config` - Current global config and limits

### Analytics and Audit

- `GET /ai/metrics` - Usage metrics per agent
- `GET /ai/metrics/costs` - Model and tool cost breakdown
- `GET /ai/audit` - Audit log of actions and runs

### Health and Operations

- `GET /ai/health` - Liveness/readiness
- `GET /ai/version` - Build and model registry versions

## Features

- Multiple AI model support (GPT-4, Gemini, Claude, and more)
- Agent lifecycle management
- Workflow orchestration with DAG support
- Vector embeddings and RAG (Retrieval-Augmented Generation)
- Task queuing and scheduling
- Tool extensibility
- Memory management
- File ingestion and processing
- Webhook integration
- Cost tracking and analytics

## Environment Variables

```bash
# 360Magicians Configuration
MAGICIANS_AI_KEY=your_ai_key_here
MAGICIANS_MODEL=gpt-4
MAGICIANS_OPENAI_API_KEY=your_openai_key
MAGICIANS_ANTHROPIC_API_KEY=your_anthropic_key
MAGICIANS_GOOGLE_API_KEY=your_google_key
MAGICIANS_MAX_TOKENS=4096
MAGICIANS_TEMPERATURE=0.7
MAGICIANS_VECTOR_DB_URL=your_vector_db_url
MAGICIANS_EMBEDDING_MODEL=text-embedding-ada-002
```

## Supported AI Models

360Magicians supports multiple AI model providers:

- **OpenAI**: GPT-4, GPT-4 Turbo, GPT-3.5 Turbo
- **Anthropic**: Claude 3 Opus, Claude 3 Sonnet, Claude 3 Haiku
- **Google**: Gemini Pro, Gemini Ultra
- **Open Source**: LLaMA, Mistral, and other open-source models

## AI SDK Integration

The platform uses the AI SDK for unified model access and streaming support. It integrates with:

- OpenAI SDK
- Anthropic SDK
- Google AI SDK
- TensorFlow.js for client-side processing
- Hugging Face Transformers for specialized accessibility models

## Integration with Deaf Research

360Magicians is designed to integrate with:

- Deaf research databases
- Sign language models
- Accessibility research repositories
- ASL recognition systems

## OpenAPI Specification

See [openapi/openapi.yaml](openapi/openapi.yaml) for the complete API specification.

## Related Repositories

- [pinkycollie/pinksync](https://github.com/pinkycollie/pinksync) - Accessibility engine
- [pinkycollie/deafauth-ecosystem](https://github.com/pinkycollie/deafauth-ecosystem) - Authentication system
- [pinkycollie/fibonrose](https://github.com/pinkycollie/fibonrose) - Blockchain layer
- [pinkycollie/pinkflow](https://github.com/pinkycollie/pinkflow) - Hub pipeline integrator
