import axios, { AxiosInstance, AxiosRequestConfig } from 'axios';

export interface DeafAuthConfig {
  baseUrl: string;
  timeout?: number;
}

export interface User {
  id: string;
  username: string;
  email: string;
  accessibilityPreferences: {
    signLanguage: boolean;
    highContrast: boolean;
    largeText: boolean;
  };
}

export interface AuthResponse {
  success: boolean;
  token: string;
  user: User;
}

export interface RegisterData {
  username: string;
  email: string;
  password: string;
  accessibilityPreferences?: User['accessibilityPreferences'];
}

export class DeafAuthClient {
  private client: AxiosInstance;
  private token: string | null = null;

  constructor(config: DeafAuthConfig) {
    this.client = axios.create({
      baseURL: config.baseUrl,
      timeout: config.timeout || 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.client.interceptors.request.use((requestConfig) => {
      if (this.token) {
        requestConfig.headers.Authorization = `Bearer ${this.token}`;
      }
      return requestConfig;
    });
  }

  setToken(token: string): void {
    this.token = token;
  }

  clearToken(): void {
    this.token = null;
  }

  async login(username: string, password: string): Promise<AuthResponse> {
    const response = await this.client.post<AuthResponse>('/api/auth/login', {
      username,
      password,
    });
    
    if (response.data.token) {
      this.setToken(response.data.token);
    }
    
    return response.data;
  }

  async register(data: RegisterData): Promise<{ success: boolean; user: User }> {
    const response = await this.client.post('/api/auth/register', data);
    return response.data;
  }

  async getCurrentUser(): Promise<User> {
    const response = await this.client.get<{ success: boolean; user: User }>('/api/users/me');
    return response.data.user;
  }

  async getUser(userId: string): Promise<User> {
    const response = await this.client.get<{ success: boolean; user: User }>(`/api/users/${userId}`);
    return response.data.user;
  }

  async updateAccessibilityPreferences(
    preferences: User['accessibilityPreferences']
  ): Promise<User> {
    const response = await this.client.put<{ success: boolean; user: User }>(
      '/api/users/preferences',
      { accessibilityPreferences: preferences }
    );
    return response.data.user;
  }

  logout(): void {
    this.clearToken();
  }
}

export function createDeafAuthClient(config: DeafAuthConfig): DeafAuthClient {
  return new DeafAuthClient(config);
}
