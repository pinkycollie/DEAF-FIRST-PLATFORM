import axios, { AxiosInstance } from 'axios';

export interface FibonRoseConfig {
  baseUrl: string;
  timeout?: number;
}

export interface Task {
  id: string;
  name: string;
  priority: number;
  duration?: number;
}

export interface OptimizedSchedule {
  success: boolean;
  optimizedSchedule: Task[];
  efficiency: number;
  message: string;
}

export interface FibonacciResult {
  success: boolean;
  position: number;
  value: number;
}

export interface GoldenRatioResult {
  success: boolean;
  inputValue: number;
  goldenRatio: number;
  multiplied: number;
  divided: number;
}

export class FibonRoseClient {
  private client: AxiosInstance;

  constructor(config: FibonRoseConfig) {
    this.client = axios.create({
      baseURL: config.baseUrl,
      timeout: config.timeout || 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }

  async optimizeSchedule(tasks: Task[]): Promise<OptimizedSchedule> {
    const response = await this.client.post<OptimizedSchedule>('/api/optimize/schedule', {
      tasks,
    });
    return response.data;
  }

  async fibonacci(n: number): Promise<FibonacciResult> {
    const response = await this.client.get<FibonacciResult>(`/api/fibonacci/${n}`);
    return response.data;
  }

  async goldenRatio(value: number): Promise<GoldenRatioResult> {
    const response = await this.client.post<GoldenRatioResult>('/api/golden-ratio', {
      value,
    });
    return response.data;
  }

  // Utility function for Fibonacci sequence calculation (client-side)
  static calculateFibonacci(n: number): number {
    if (n <= 1) return n;
    let prev = 0;
    let curr = 1;
    for (let i = 2; i <= n; i++) {
      const next = prev + curr;
      prev = curr;
      curr = next;
    }
    return curr;
  }

  // Utility function for golden ratio (phi)
  static readonly GOLDEN_RATIO = 1.618033988749895;
  static readonly GOLDEN_RATIO_CONJUGATE = 0.6180339887498949;

  static applyGoldenRatio(value: number): { multiplied: number; divided: number } {
    return {
      multiplied: value * FibonRoseClient.GOLDEN_RATIO,
      divided: value / FibonRoseClient.GOLDEN_RATIO,
    };
  }
}

export function createFibonRoseClient(config: FibonRoseConfig): FibonRoseClient {
  return new FibonRoseClient(config);
}
