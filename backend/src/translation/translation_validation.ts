import { PublicApiError } from "./translation_errors";
import { TranslationProviderRequest } from "./translation_provider";

export const MAX_TRANSLATION_CHARACTERS = 5000;
export const supportedTranslationLanguages = new Set([
  "en",
  "it",
  "es",
  "fr",
  "de",
  "ru",
  "zh_CN",
  "ja",
  "ko",
  "pt",
  "ar",
  "tr",
  "pl",
  "nl",
  "hi",
  "ka",
  "fa",
  "hy",
  "uk",
]);

export function validateTranslationRequest(
  body: unknown,
): TranslationProviderRequest {
  if (!isRecord(body)) throw new PublicApiError("invalidRequest", 400);

  const text = body.text;
  const sourceLanguage = body.sourceLanguage;
  const targetLanguage = body.targetLanguage;

  if (
    typeof text !== "string" ||
    typeof sourceLanguage !== "string" ||
    typeof targetLanguage !== "string"
  ) {
    throw new PublicApiError("invalidRequest", 400);
  }

  const normalizedText = text.trim();
  if (normalizedText.length === 0) {
    throw new PublicApiError("invalidRequest", 400);
  }
  if (normalizedText.length > MAX_TRANSLATION_CHARACTERS) {
    throw new PublicApiError("requestTooLarge", 413);
  }

  const validSource = sourceLanguage === "auto" || supportedTranslationLanguages.has(sourceLanguage);
  const validTarget = supportedTranslationLanguages.has(targetLanguage);
  if (!validSource || !validTarget) {
    throw new PublicApiError("unsupportedLanguage", 400);
  }
  if (sourceLanguage !== "auto" && sourceLanguage === targetLanguage) {
    throw new PublicApiError("invalidRequest", 400);
  }

  return {
    text: normalizedText,
    sourceLanguage,
    targetLanguage,
  };
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
