export interface RateLimitDecision {
  allowed: boolean;
  retryAfterSeconds?: number;
}

export interface RateLimiter {
  check(identity: string, characterCount: number): RateLimitDecision;
}

export class InMemoryRateLimiter implements RateLimiter {
  private readonly buckets = new Map<string, { startedAt: number; requests: number }>();

  constructor(
    private readonly maxRequestsPerMinute = 20,
    private readonly maxCharactersPerRequest = 5000,
  ) {}

  check(identity: string, characterCount: number): RateLimitDecision {
    if (characterCount > this.maxCharactersPerRequest) {
      return { allowed: false, retryAfterSeconds: 60 };
    }

    const now = Date.now();
    const current = this.buckets.get(identity);
    if (!current || now - current.startedAt >= 60_000) {
      this.buckets.set(identity, { startedAt: now, requests: 1 });
      return { allowed: true };
    }

    if (current.requests >= this.maxRequestsPerMinute) {
      return { allowed: false, retryAfterSeconds: 60 };
    }

    current.requests += 1;
    return { allowed: true };
  }
}
