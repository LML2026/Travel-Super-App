import {
  TranslationProvider,
  TranslationProviderError,
  TranslationProviderRequest,
  TranslationProviderResult,
} from "./translation_provider";

export class UnavailableTranslationProvider implements TranslationProvider {
  async translate(
    _request: TranslationProviderRequest,
  ): Promise<TranslationProviderResult> {
    throw new TranslationProviderError("providerUnavailable");
  }
}
