import { NextFunction, Request, RequestHandler, Response, Router } from "express";
import { TokenVerifier, requireFirebaseAuth } from "../auth/auth_middleware";
import { PublicApiError } from "./translation_errors";
import { RateLimiter } from "../security/rate_limiter";
import { TranslationProvider, TranslationProviderError } from "./translation_provider";
import { validateTranslationRequest } from "./translation_validation";

export interface TranslationRouteDependencies {
  tokenVerifier: TokenVerifier;
  provider: TranslationProvider;
  rateLimiter: RateLimiter;
}

export function createTranslationRouter(
  dependencies: TranslationRouteDependencies,
): Router {
  const router = Router();
  router.post(
    "/translate",
    requireFirebaseAuth(dependencies.tokenVerifier),
    translate(dependencies),
  );
  return router;
}

function translate(dependencies: TranslationRouteDependencies): RequestHandler {
  return async (request: Request, response: Response, next: NextFunction) => {
    try {
      const translationRequest = validateTranslationRequest(request.body);
      const identity = request.verifiedIdentity;
      if (!identity) throw new PublicApiError("unauthorized", 401);

      const decision = dependencies.rateLimiter.check(
        identity.uid,
        translationRequest.text.length,
      );
      if (!decision.allowed) {
        if (decision.retryAfterSeconds) {
          response.setHeader("Retry-After", decision.retryAfterSeconds);
        }
        throw new PublicApiError("rateLimited", 429);
      }

      const result = await dependencies.provider.translate(translationRequest);
      response.status(200).json({
        translatedText: result.translatedText,
        ...(result.detectedSourceLanguage
          ? { detectedSourceLanguage: result.detectedSourceLanguage }
          : {}),
      });
    } catch (error) {
      if (error instanceof TranslationProviderError) {
        const status = error.kind === "timeout" ? 504 : 503;
        next(new PublicApiError(error.kind, status));
        return;
      }
      next(error);
    }
  };
}
