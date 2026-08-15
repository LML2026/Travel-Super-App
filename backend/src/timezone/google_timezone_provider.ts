import {
  TimezoneProvider,
  TimezoneProviderError,
  TimezoneProviderRequest,
  TimezoneProviderResult,
} from "./timezone_provider";

export interface GoogleTimezoneHttpClient {
  fetch(input: string | URL, init?: RequestInit): Promise<Response>;
}

export interface GoogleTimezoneProviderOptions {
  apiKey?: string;
  client?: GoogleTimezoneHttpClient;
}

export class GoogleTimezoneProvider implements TimezoneProvider {
  private readonly apiKey: string | undefined;
  private readonly client: GoogleTimezoneHttpClient;

  constructor(options: GoogleTimezoneProviderOptions = {}) {
    this.apiKey = options.apiKey ?? process.env.GOOGLE_TIMEZONE_API_KEY;
    this.client = options.client ?? { fetch };
  }

  async resolve(request: TimezoneProviderRequest): Promise<TimezoneProviderResult> {
    if (!this.apiKey) throw new TimezoneProviderError("providerUnavailable");

    try {
      // Google Time Zone API results are intentionally not persisted or cached.
      const url = new URL("https://maps.googleapis.com/maps/api/timezone/json");
      url.searchParams.set("location", `${request.latitude},${request.longitude}`);
      url.searchParams.set("timestamp", String(request.timestamp));
      url.searchParams.set("key", this.apiKey);

      const response = await this.client.fetch(url, { method: "GET" });
      if (!response.ok) throw new TimezoneProviderError("providerUnavailable");

      const payload = await response.json() as unknown;
      const timezoneId = readTimezoneId(payload);
      if (!timezoneId) throw new TimezoneProviderError("providerUnavailable");

      return { timezoneId };
    } catch (error) {
      if (error instanceof TimezoneProviderError) throw error;
      throw new TimezoneProviderError("providerUnavailable");
    }
  }
}

function readTimezoneId(payload: unknown): string | null {
  if (typeof payload !== "object" || payload === null) return null;
  const record = payload as Record<string, unknown>;
  if (record.status !== "OK" || typeof record.timeZoneId !== "string") return null;
  const timezoneId = record.timeZoneId.trim();
  return timezoneId || null;
}
