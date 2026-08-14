import express, { ErrorRequestHandler } from "express";
import { TokenVerifier } from "./auth/auth_middleware";
import { InMemoryRateLimiter, RateLimiter } from "./security/rate_limiter";
import { PublicApiError, publicErrorResponse } from "./translation/translation_errors";
import { TranslationProvider } from "./translation/translation_provider";
import { createTranslationRouter } from "./translation/translation_routes";
import { UnavailableTranslationProvider } from "./translation/unavailable_translation_provider";

export interface AppDependencies {
  tokenVerifier: TokenVerifier;
  provider?: TranslationProvider;
  rateLimiter?: RateLimiter;
}

export function createApp(dependencies: AppDependencies) {
  const app = express();
  app.disable("x-powered-by");
  app.use(express.json({ limit: "16kb", strict: true }));
  app.get("/healthz", (_request, response) => response.status(200).json({ ok: true }));
  app.use(
    createTranslationRouter({
      tokenVerifier: dependencies.tokenVerifier,
      provider: dependencies.provider ?? new UnavailableTranslationProvider(),
      rateLimiter: dependencies.rateLimiter ?? new InMemoryRateLimiter(),
    }),
  );
  app.use(safeErrorHandler);
  return app;
}

const safeErrorHandler: ErrorRequestHandler = (error, _request, response, _next) => {
  if (error instanceof PublicApiError) {
    response.status(error.status).json(publicErrorResponse(error.code));
    return;
  }

  if (error instanceof Error && error.name === "TranslationProviderError") {
    response.status(503).json(publicErrorResponse("translationFailed"));
    return;
  }

  if (isBodyParseOrSizeError(error)) {
    const code = error.type === "entity.too.large" ? "requestTooLarge" : "invalidRequest";
    response.status(error.type === "entity.too.large" ? 413 : 400).json(publicErrorResponse(code));
    return;
  }

  response.status(500).json(publicErrorResponse("translationFailed"));
};

function isBodyParseOrSizeError(error: unknown): error is { type: string } {
  return (
    typeof error === "object" &&
    error !== null &&
    "type" in error &&
    ((error as { type?: unknown }).type === "entity.parse.failed" ||
      (error as { type?: unknown }).type === "entity.too.large")
  );
}
