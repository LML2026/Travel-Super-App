import { NextFunction, Request, RequestHandler, Response } from "express";
import { PublicApiError } from "../translation/translation_errors";

export interface VerifiedIdentity {
  uid: string;
}

export interface TokenVerifier {
  verifyIdToken(token: string): Promise<VerifiedIdentity>;
}

declare global {
  namespace Express {
    interface Request {
      verifiedIdentity?: VerifiedIdentity;
    }
  }
}

export function requireFirebaseAuth(verifier: TokenVerifier): RequestHandler {
  return async (request: Request, _response: Response, next: NextFunction) => {
    const header = request.header("authorization");
    if (!header?.startsWith("Bearer ")) {
      next(new PublicApiError("unauthorized", 401));
      return;
    }

    const token = header.slice("Bearer ".length).trim();
    if (!token) {
      next(new PublicApiError("unauthorized", 401));
      return;
    }

    try {
      request.verifiedIdentity = await verifier.verifyIdToken(token);
      next();
    } catch (_) {
      next(new PublicApiError("unauthorized", 401));
    }
  };
}
