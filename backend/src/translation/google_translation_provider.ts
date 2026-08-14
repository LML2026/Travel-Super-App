import { v3 } from "@google-cloud/translate";
import {
  TranslationProvider,
  TranslationProviderError,
  TranslationProviderRequest,
  TranslationProviderResult,
} from "./translation_provider";

export interface TranslateTextClient {
  translateText(request: GoogleTranslateTextRequest): Promise<[
    GoogleTranslateTextResponse,
    unknown,
    unknown,
  ]>;
}

export interface GoogleTranslateTextRequest {
  parent: string;
  contents: string[];
  mimeType: string;
  targetLanguageCode: string;
  sourceLanguageCode?: string;
}

export interface GoogleTranslateTextResponse {
  translations?: Array<{
    translatedText?: string | null;
    detectedLanguageCode?: string | null;
  }> | null;
}

export interface GoogleTranslationProviderOptions {
  projectId?: string;
  location?: string;
  client?: TranslateTextClient;
}

export class GoogleTranslationProvider implements TranslationProvider {
  private readonly projectId: string | undefined;
  private readonly location: string;
  private readonly client: TranslateTextClient;

  constructor(options: GoogleTranslationProviderOptions = {}) {
    this.projectId = options.projectId ?? process.env.GOOGLE_CLOUD_PROJECT;
    this.location = options.location ?? process.env.GOOGLE_TRANSLATION_LOCATION ?? "global";
    this.client = options.client ?? new v3.TranslationServiceClient();
  }

  async translate(
    request: TranslationProviderRequest,
  ): Promise<TranslationProviderResult> {
    if (!this.projectId) {
      throw new TranslationProviderError("providerUnavailable");
    }

    try {
      const providerRequest: GoogleTranslateTextRequest = {
        parent: `projects/${this.projectId}/locations/${this.location}`,
        contents: [request.text],
        mimeType: "text/plain",
        targetLanguageCode: toGoogleLanguageCode(request.targetLanguage),
      };

      if (request.sourceLanguage !== "auto") {
        providerRequest.sourceLanguageCode = toGoogleLanguageCode(request.sourceLanguage);
      }

      const [response] = await this.client.translateText(providerRequest);
      const translation = response.translations?.[0];
      const translatedText = translation?.translatedText;
      if (!translatedText) {
        throw new TranslationProviderError("translationFailed");
      }

      return {
        translatedText,
        detectedSourceLanguage: translation.detectedLanguageCode
          ? fromGoogleLanguageCode(translation.detectedLanguageCode)
          : undefined,
      };
    } catch (error) {
      if (error instanceof TranslationProviderError) throw error;
      throw new TranslationProviderError(mapGoogleError(error));
    }
  }
}

export function toGoogleLanguageCode(code: string): string {
  return code === "zh_CN" ? "zh-CN" : code;
}

export function fromGoogleLanguageCode(code: string): string {
  return code === "zh-CN" || code === "zh" ? "zh_CN" : code;
}

function mapGoogleError(
  error: unknown,
): "providerUnavailable" | "timeout" | "unsupportedLanguage" | "translationFailed" {
  const code = typeof error === "object" && error !== null && "code" in error
    ? (error as { code?: unknown }).code
    : undefined;
  const message = typeof error === "object" && error !== null && "message" in error
    ? (error as { message?: unknown }).message
    : undefined;
  const normalizedMessage = typeof message === "string" ? message.toLowerCase() : "";

  if (code === 4 || normalizedMessage.includes("deadline") || normalizedMessage.includes("timeout")) {
    return "timeout";
  }
  if (
    code === 7 ||
    code === 16 ||
    normalizedMessage.includes("credential") ||
    normalizedMessage.includes("permission") ||
    normalizedMessage.includes("project") ||
    normalizedMessage.includes("not enabled")
  ) {
    return "providerUnavailable";
  }
  if (code === 3 || normalizedMessage.includes("language")) {
    return "unsupportedLanguage";
  }
  return "translationFailed";
}
