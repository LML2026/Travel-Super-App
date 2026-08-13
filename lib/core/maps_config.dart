class MapsConfig {
  MapsConfig._();

  static const String apiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  static bool get hasApiKey => apiKey.isNotEmpty;
}
