import express, { ErrorRequestHandler } from "express";
import { TokenVerifier } from "./auth/auth_middleware";
import { InMemoryRateLimiter, RateLimiter } from "./security/rate_limiter";
import { PublicApiError, publicErrorResponse } from "./translation/translation_errors";
import { TranslationProvider } from "./translation/translation_provider";
import { createTranslationRouter } from "./translation/translation_routes";
import { UnavailableTranslationProvider } from "./translation/unavailable_translation_provider";
import { TimezoneProvider } from "./timezone/timezone_provider";
import { createTimezoneRouter } from "./timezone/timezone_routes";
import { UnavailableTimezoneProvider } from "./timezone/unavailable_timezone_provider";

export interface AppDependencies {
  tokenVerifier: TokenVerifier;
  provider?: TranslationProvider;
  timezoneProvider?: TimezoneProvider;
  rateLimiter?: RateLimiter;
  allowedOrigins?: string[];
}

export function createApp(dependencies: AppDependencies) {
  const app = express();
  app.disable("x-powered-by");
  app.use(createCorsMiddleware(dependencies.allowedOrigins ?? configuredOrigins()));
  app.use(express.json({ limit: "16kb", strict: true }));
  app.get("/healthz", (_request, response) => response.status(200).json({ status: "ok" }));
  app.get("/health", (_request, response) => response.status(200).json({ status: "ok" }));
  app.use(
    createTranslationRouter({
      tokenVerifier: dependencies.tokenVerifier,
      provider: dependencies.provider ?? new UnavailableTranslationProvider(),
      rateLimiter: dependencies.rateLimiter ?? new InMemoryRateLimiter(),
    }),
  );
  app.use(
    createTimezoneRouter({
      tokenVerifier: dependencies.tokenVerifier,
      provider: dependencies.timezoneProvider ?? new UnavailableTimezoneProvider(),
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

function configuredOrigins(): string[] {
  return (process.env.ITAREVO_ALLOWED_ORIGINS ?? "")
    .split(",")
    .map((origin) => origin.trim())
    .filter(Boolean);
}

function createCorsMiddleware(allowedOrigins: string[]): express.RequestHandler {
  const allowed = new Set(allowedOrigins);
  return (request, response, next) => {
    const origin = request.header("origin");

    if (!origin) {
      next();
      return;
    }

    if (!allowed.has(origin)) {
      response.status(403).json(publicErrorResponse("unauthorized"));
      return;
    }

    response.setHeader("Access-Control-Allow-Origin", origin);
    response.setHeader("Vary", "Origin");
    response.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Authorization, Content-Type");

    if (request.method === "OPTIONS") {
      response.status(204).end();
      return;
    }

    next();
  };
}
