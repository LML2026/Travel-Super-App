import { NextFunction, Request, RequestHandler, Response, Router } from "express";
import { TokenVerifier, requireFirebaseAuth } from "../auth/auth_middleware";
import { PublicApiError } from "../translation/translation_errors";
import { TimezoneProvider, TimezoneProviderError } from "./timezone_provider";
import { validateTimezoneRequest } from "./timezone_validation";

export interface TimezoneRouteDependencies {
  tokenVerifier: TokenVerifier;
  provider: TimezoneProvider;
  now?: () => Date;
}

export function createTimezoneRouter(dependencies: TimezoneRouteDependencies): Router {
  const router = Router();
  router.post(
    "/timezone",
    requireFirebaseAuth(dependencies.tokenVerifier),
    resolveTimezone(dependencies),
  );
  return router;
}

function resolveTimezone(dependencies: TimezoneRouteDependencies): RequestHandler {
  return async (request: Request, response: Response, next: NextFunction) => {
    try {
      const timezoneRequest = validateTimezoneRequest(request.body);
      if (!request.verifiedIdentity) throw new PublicApiError("unauthorized", 401);

      const result = await dependencies.provider.resolve(timezoneRequest);
      response.status(200).json({
        timezoneId: result.timezoneId,
        status: "resolved",
        source: "authoritativeProvider",
        confidence: "confirmed",
        resolvedAt: (dependencies.now ?? (() => new Date()))().toISOString(),
        coordinateEvidence: {
          latitude: timezoneRequest.latitude,
          longitude: timezoneRequest.longitude,
        },
      });
    } catch (error) {
      if (error instanceof TimezoneProviderError) {
        next(new PublicApiError("providerUnavailable", 503));
        return;
      }
      next(error);
    }
  };
}
