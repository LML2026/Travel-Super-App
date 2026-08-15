export interface TimezoneProviderRequest {
  latitude: number;
  longitude: number;
  timestamp: number;
}

export interface TimezoneProviderResult {
  timezoneId: string;
}

export interface TimezoneProvider {
  resolve(request: TimezoneProviderRequest): Promise<TimezoneProviderResult>;
}

export class TimezoneProviderError extends Error {
  constructor(readonly kind: "providerUnavailable") {
    super(kind);
  }
}
