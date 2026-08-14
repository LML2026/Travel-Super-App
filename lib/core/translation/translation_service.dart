class TranslationRequest {
  final String sourceText;
  final String sourceLanguageCode;
  final String targetLanguageCode;

  const TranslationRequest({
    required this.sourceText,
    required this.sourceLanguageCode,
    required this.targetLanguageCode,
  });
}

class TranslationResult {
  final String translatedText;
  final String? detectedSourceLanguage;

  const TranslationResult({
    required this.translatedText,
    this.detectedSourceLanguage,
  });
}

abstract interface class TranslationService {
  Future<TranslationResult> translate(TranslationRequest request);
}

class TranslationProviderUnavailable implements Exception {
  final String message;

  const TranslationProviderUnavailable(this.message);

  @override
  String toString() => message;
}

class UnavailableTranslationService implements TranslationService {
  const UnavailableTranslationService();

  @override
  Future<TranslationResult> translate(TranslationRequest request) {
    throw const TranslationProviderUnavailable(
      'Translation provider is not configured.',
    );
  }
}
