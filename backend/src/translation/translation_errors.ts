export const publicErrorCodes = [
  "invalidRequest",
  "unsupportedLanguage",
  "requestTooLarge",
  "rateLimited",
  "unauthorized",
  "providerUnavailable",
  "timeout",
  "translationFailed",
] as const;

export type PublicErrorCode = (typeof publicErrorCodes)[number];

export class PublicApiError extends Error {
  constructor(
    readonly code: PublicErrorCode,
    readonly status: number,
  ) {
    super(code);
  }
}

export function publicErrorResponse(code: PublicErrorCode) {
  return { error: { code } };
}
