import { GoogleTimezoneProvider, GoogleTimezoneProviderOptions } from "./google_timezone_provider";
import { TimezoneProvider } from "./timezone_provider";
import { UnavailableTimezoneProvider } from "./unavailable_timezone_provider";

export function createConfiguredTimezoneProvider(
  environment: NodeJS.ProcessEnv = process.env,
  options: Omit<GoogleTimezoneProviderOptions, "apiKey"> = {},
): TimezoneProvider {
  if (!environment.GOOGLE_TIMEZONE_API_KEY) {
    return new UnavailableTimezoneProvider();
  }

  return new GoogleTimezoneProvider({
    apiKey: environment.GOOGLE_TIMEZONE_API_KEY,
    ...options,
  });
}
