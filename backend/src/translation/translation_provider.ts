export interface TranslationProviderRequest {
  text: string;
  sourceLanguage: string;
  targetLanguage: string;
}

export interface TranslationProviderResult {
  translatedText: string;
  detectedSourceLanguage?: string;
}

export interface TranslationProvider {
  translate(request: TranslationProviderRequest): Promise<TranslationProviderResult>;
}

export class TranslationProviderError extends Error {
  constructor(readonly kind: "providerUnavailable" | "timeout" | "translationFailed") {
    super(kind);
  }
}
