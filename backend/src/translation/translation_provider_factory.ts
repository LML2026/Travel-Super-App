import {
  GoogleTranslationProvider,
  GoogleTranslationProviderOptions,
} from "./google_translation_provider";
import { TranslationProvider } from "./translation_provider";
import { UnavailableTranslationProvider } from "./unavailable_translation_provider";

export function createConfiguredTranslationProvider(
  environment: NodeJS.ProcessEnv = process.env,
  googleOptions: Omit<GoogleTranslationProviderOptions, "projectId" | "location"> = {},
): TranslationProvider {
  if (environment.TRANSLATION_PROVIDER !== "google") {
    return new UnavailableTranslationProvider();
  }

  if (!environment.GOOGLE_CLOUD_PROJECT) {
    return new UnavailableTranslationProvider();
  }

  return new GoogleTranslationProvider({
    projectId: environment.GOOGLE_CLOUD_PROJECT,
    location: environment.GOOGLE_TRANSLATION_LOCATION,
    ...googleOptions,
  });
}
