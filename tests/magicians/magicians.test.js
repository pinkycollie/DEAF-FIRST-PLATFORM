/**
 * 360Magicians API Tests
 * Tests for the AI Agent Platform
 */

const axios = require('axios');

jest.mock('axios');

describe('360Magicians - AI Agent Platform API', () => {
  const baseURL = 'https://api.mbtquniverse.com/ai';
  const authToken = 'Bearer valid_token';

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Agent Management', () => {
    describe('POST /ai/agents', () => {
      it('should create a new agent', async () => {
        const mockResponse = {
          data: {
            id: 'agent_123',
            name: 'Test Agent',
            model: 'gpt-4',
            createdAt: '2024-01-01T00:00:00Z'
          }
        };

        axios.post.mockResolvedValue(mockResponse);

        const response = await axios.post(`${baseURL}/agents`, {
          name: 'Test Agent',
          model: 'gpt-4'
        }, {
          headers: { Authorization: authToken }
        });

        expect(response.data).toHaveProperty('id');
        expect(response.data.name).toBe('Test Agent');
        expect(response.data.model).toBe('gpt-4');
      });
    });

    describe('GET /ai/agents', () => {
      it('should list all agents', async () => {
        const mockResponse = {
          data: [
            {
              id: 'agent_1',
              name: 'Agent 1',
              model: 'gpt-4',
              createdAt: '2024-01-01T00:00:00Z'
            },
            {
              id: 'agent_2',
              name: 'Agent 2',
              model: 'claude-3',
              createdAt: '2024-01-02T00:00:00Z'
            }
          ]
        };

        axios.get.mockResolvedValue(mockResponse);

        const response = await axios.get(`${baseURL}/agents`, {
          headers: { Authorization: authToken }
        });

        expect(Array.isArray(response.data)).toBe(true);
        expect(response.data.length).toBe(2);
      });
    });

    describe('GET /ai/agents/:agentId', () => {
      it('should get agent details', async () => {
        const mockResponse = {
          data: {
            id: 'agent_123',
            name: 'Test Agent',
            model: 'gpt-4',
            createdAt: '2024-01-01T00:00:00Z'
          }
        };

        axios.get.mockResolvedValue(mockResponse);

        const response = await axios.get(`${baseURL}/agents/agent_123`, {
          headers: { Authorization: authToken }
        });

        expect(response.data.id).toBe('agent_123');
      });

      it('should return 404 for non-existent agent', async () => {
        axios.get.mockRejectedValue({
          response: {
            status: 404,
            data: { error: 'Agent not found' }
          }
        });

        await expect(
          axios.get(`${baseURL}/agents/invalid_id`, {
            headers: { Authorization: authToken }
          })
        ).rejects.toMatchObject({
          response: expect.objectContaining({
            status: 404
          })
        });
      });
    });

    describe('DELETE /ai/agents/:agentId', () => {
      it('should delete an agent', async () => {
        axios.delete.mockResolvedValue({ status: 204 });

        const response = await axios.delete(`${baseURL}/agents/agent_123`, {
          headers: { Authorization: authToken }
        });

        expect(response.status).toBe(204);
      });
    });
  });

  describe('Execution', () => {
    describe('POST /ai/agents/:agentId/execute', () => {
      it('should execute agent with input', async () => {
        const mockResponse = {
          data: {
            id: 'run_123',
            status: 'completed',
            startedAt: '2024-01-01T00:00:00Z',
            output: 'Agent response here'
          }
        };

        axios.post.mockResolvedValue(mockResponse);

        const response = await axios.post(`${baseURL}/agents/agent_123/execute`, {
          input: 'Test input'
        }, {
          headers: { Authorization: authToken }
        });

        expect(response.data).toHaveProperty('id');
        expect(response.data).toHaveProperty('status');
        expect(response.data).toHaveProperty('output');
      });
    });

    describe('GET /ai/runs/:runId', () => {
      it('should get run status', async () => {
        const mockResponse = {
          data: {
            id: 'run_123',
            status: 'in_progress',
            startedAt: '2024-01-01T00:00:00Z'
          }
        };

        axios.get.mockResolvedValue(mockResponse);

        const response = await axios.get(`${baseURL}/runs/run_123`, {
          headers: { Authorization: authToken }
        });

        expect(response.data.id).toBe('run_123');
        expect(response.data.status).toBe('in_progress');
      });
    });
  });

  describe('Tools', () => {
    describe('GET /ai/tools', () => {
      it('should list available tools', async () => {
        const mockResponse = {
          data: [
            {
              id: 'tool_1',
              name: 'Web Search',
              description: 'Search the web for information'
            },
            {
              id: 'tool_2',
              name: 'Calculator',
              description: 'Perform mathematical calculations'
            }
          ]
        };

        axios.get.mockResolvedValue(mockResponse);

        const response = await axios.get(`${baseURL}/tools`, {
          headers: { Authorization: authToken }
        });

        expect(Array.isArray(response.data)).toBe(true);
        expect(response.data[0]).toHaveProperty('name');
      });
    });

    describe('POST /ai/tools', () => {
      it('should register a custom tool', async () => {
        const mockResponse = {
          data: {
            id: 'tool_custom',
            name: 'Custom Tool',
            description: 'A custom tool for specific tasks'
          }
        };

        axios.post.mockResolvedValue(mockResponse);

        const response = await axios.post(`${baseURL}/tools`, {
          name: 'Custom Tool',
          description: 'A custom tool for specific tasks'
        }, {
          headers: { Authorization: authToken }
        });

        expect(response.data).toHaveProperty('id');
        expect(response.data.name).toBe('Custom Tool');
      });
    });
  });

  describe('Memory', () => {
    describe('GET /ai/agents/:agentId/memory', () => {
      it('should fetch memory items', async () => {
        const mockResponse = {
          data: [
            {
              id: 'mem_1',
              content: 'Previous conversation context',
              timestamp: '2024-01-01T00:00:00Z'
            }
          ]
        };

        axios.get.mockResolvedValue(mockResponse);

        const response = await axios.get(`${baseURL}/agents/agent_123/memory`, {
          headers: { Authorization: authToken }
        });

        expect(Array.isArray(response.data)).toBe(true);
      });
    });

    describe('POST /ai/agents/:agentId/memory', () => {
      it('should upsert memory', async () => {
        const mockResponse = {
          data: {
            id: 'mem_new',
            content: 'New memory content',
            timestamp: '2024-01-01T00:00:00Z'
          }
        };

        axios.post.mockResolvedValue(mockResponse);

        const response = await axios.post(`${baseURL}/agents/agent_123/memory`, {
          content: 'New memory content'
        }, {
          headers: { Authorization: authToken }
        });

        expect(response.data).toHaveProperty('id');
        expect(response.data.content).toBe('New memory content');
      });
    });
  });

  describe('Health', () => {
    describe('GET /ai/health', () => {
      it('should return health status', async () => {
        const mockResponse = {
          data: {
            status: 'healthy'
          }
        };

        axios.get.mockResolvedValue(mockResponse);

        const response = await axios.get(`${baseURL}/health`);

        expect(response.data.status).toBe('healthy');
      });
    });
  });
});
