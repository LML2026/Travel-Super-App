import { PublicApiError } from "../translation/translation_errors";
import { TimezoneProviderRequest } from "./timezone_provider";

const MAX_UNIX_TIMESTAMP_SECONDS = 10_000_000_000;

export function validateTimezoneRequest(body: unknown): TimezoneProviderRequest {
  if (!isRecord(body)) throw new PublicApiError("invalidRequest", 400);

  if (Object.keys(body).some((key) => !["latitude", "longitude", "timestamp"].includes(key))) {
    throw new PublicApiError("invalidRequest", 400);
  }

  const { latitude, longitude, timestamp } = body;
  if (
    typeof latitude !== "number" ||
    typeof longitude !== "number" ||
    typeof timestamp !== "number" ||
    !Number.isFinite(latitude) ||
    !Number.isFinite(longitude) ||
    !Number.isFinite(timestamp) ||
    latitude < -90 ||
    latitude > 90 ||
    longitude < -180 ||
    longitude > 180 ||
    !Number.isSafeInteger(timestamp) ||
    timestamp < 0 ||
    timestamp > MAX_UNIX_TIMESTAMP_SECONDS
  ) {
    throw new PublicApiError("invalidRequest", 400);
  }

  return { latitude, longitude, timestamp };
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
