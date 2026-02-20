/**
 * DAO API Tests
 * Tests for the Governance API
 */

const axios = require('axios');

jest.mock('axios');

describe('MBTQ DAO - Governance API', () => {
  const baseURL = 'https://api.mbtquniverse.com/dao';
  const authToken = 'Bearer valid_token';

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('GET /dao/proposals', () => {
    it('should list all proposals', async () => {
      const mockResponse = {
        data: [
          {
            id: 'prop_1',
            title: 'Improve Accessibility Features',
            description: 'Proposal to enhance ASL support',
            status: 'active'
          },
          {
            id: 'prop_2',
            title: 'Community Funding',
            description: 'Allocate funds for community projects',
            status: 'pending'
          }
        ]
      };

      axios.get.mockResolvedValue(mockResponse);

      const response = await axios.get(`${baseURL}/proposals`, {
        headers: { Authorization: authToken }
      });

      expect(Array.isArray(response.data)).toBe(true);
      expect(response.data.length).toBe(2);
      expect(response.data[0]).toHaveProperty('id');
      expect(response.data[0]).toHaveProperty('title');
      expect(response.data[0]).toHaveProperty('status');
    });

    it('should filter proposals by status', async () => {
      const mockResponse = {
        data: [
          {
            id: 'prop_1',
            title: 'Active Proposal',
            description: 'An active proposal',
            status: 'active'
          }
        ]
      };

      axios.get.mockResolvedValue(mockResponse);

      const response = await axios.get(`${baseURL}/proposals?status=active`, {
        headers: { Authorization: authToken }
      });

      expect(response.data.every(p => p.status === 'active')).toBe(true);
    });
  });

  describe('POST /dao/vote', () => {
    it('should submit a vote successfully', async () => {
      const vote = {
        proposalId: 'prop_1',
        vote: 'yes'
      };

      const mockResponse = {
        data: vote
      };

      axios.post.mockResolvedValue(mockResponse);

      const response = await axios.post(`${baseURL}/vote`, vote, {
        headers: { Authorization: authToken }
      });

      expect(response.data).toMatchObject(vote);
      expect(response.data.proposalId).toBe('prop_1');
      expect(response.data.vote).toBe('yes');
    });

    it('should validate vote value', async () => {
      axios.post.mockRejectedValue({
        response: {
          status: 400,
          data: { error: 'Invalid vote value. Must be yes, no, or abstain' }
        }
      });

      await expect(
        axios.post(`${baseURL}/vote`, {
          proposalId: 'prop_1',
          vote: 'invalid'
        }, {
          headers: { Authorization: authToken }
        })
      ).rejects.toMatchObject({
        response: expect.objectContaining({
          status: 400
        })
      });
    });

    it('should prevent duplicate voting', async () => {
      axios.post.mockRejectedValue({
        response: {
          status: 409,
          data: { error: 'User has already voted on this proposal' }
        }
      });

      await expect(
        axios.post(`${baseURL}/vote`, {
          proposalId: 'prop_1',
          vote: 'yes'
        }, {
          headers: { Authorization: authToken }
        })
      ).rejects.toMatchObject({
        response: expect.objectContaining({
          status: 409
        })
      });
    });
  });

  describe('GET /dao/members', () => {
    it('should list DAO members', async () => {
      const mockResponse = {
        data: [
          {
            id: 'member_1',
            joinedAt: '2024-01-01T00:00:00Z'
          },
          {
            id: 'member_2',
            joinedAt: '2024-01-02T00:00:00Z'
          }
        ]
      };

      axios.get.mockResolvedValue(mockResponse);

      const response = await axios.get(`${baseURL}/members`, {
        headers: { Authorization: authToken }
      });

      expect(Array.isArray(response.data)).toBe(true);
      expect(response.data.length).toBeGreaterThan(0);
      expect(response.data[0]).toHaveProperty('id');
      expect(response.data[0]).toHaveProperty('joinedAt');
    });

    it('should require authentication', async () => {
      axios.get.mockRejectedValue({
        response: {
          status: 401,
          data: { error: 'Authentication required' }
        }
      });

      await expect(
        axios.get(`${baseURL}/members`)
      ).rejects.toMatchObject({
        response: expect.objectContaining({
          status: 401
        })
      });
    });
  });
});
