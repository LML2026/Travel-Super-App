class TranslationApiException implements Exception {
  final String code;

  const TranslationApiException(this.code);
}