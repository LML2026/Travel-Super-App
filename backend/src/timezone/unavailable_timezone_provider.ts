import {
  TimezoneProvider,
  TimezoneProviderError,
  TimezoneProviderRequest,
  TimezoneProviderResult,
} from "./timezone_provider";

export class UnavailableTimezoneProvider implements TimezoneProvider {
  async resolve(_request: TimezoneProviderRequest): Promise<TimezoneProviderResult> {
    throw new TimezoneProviderError("providerUnavailable");
  }
}
