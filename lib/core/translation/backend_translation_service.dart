import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_service.dart';
import 'translation_api_exception.dart';
import 'translation_service.dart';

class BackendTranslationService implements TranslationService {
  static const configuredBaseUrl = String.fromEnvironment(
    'ITAREVO_TRANSLATION_BACKEND_URL',
  );

  final AuthService authService;
  final http.Client _client;
  final Uri? _baseUri;
  final Duration requestTimeout;

  BackendTranslationService({
    required this.authService,
    http.Client? client,
    String? baseUrl,
    this.requestTimeout = const Duration(seconds: 15),
  })  : _client = client ?? http.Client(),
        _baseUri = _parseBaseUri(baseUrl ?? configuredBaseUrl);

  bool get isConfigured => _baseUri != null;

  @override
  Future<TranslationResult> translate(TranslationRequest request) async {
    final baseUri = _baseUri;
    if (baseUri == null) {
      throw const TranslationApiException('providerUnavailable');
    }

    final token = await _readToken();
    if (token == null || token.isEmpty) {
      throw const TranslationApiException('unauthorized');
    }

    try {
      final response = await _client
          .post(
            baseUri.resolve('translate'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'text': request.sourceText,
              'sourceLanguage': request.sourceLanguageCode,
              'targetLanguage': request.targetLanguageCode,
            }),
          )
          .timeout(requestTimeout);

      final payload = _decodeObject(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw TranslationApiException(_errorCode(response.statusCode, payload));
      }

      final translatedText = payload?['translatedText'];
      if (translatedText is! String || translatedText.isEmpty) {
        throw const TranslationApiException('translationFailed');
      }

      final detected = payload?['detectedSourceLanguage'];
      return TranslationResult(
        translatedText: translatedText,
        detectedSourceLanguage: detected is String ? detected : null,
      );
    } on TranslationApiException {
      rethrow;
    } on TimeoutException {
      throw const TranslationApiException('timeout');
    } on http.ClientException {
      throw const TranslationApiException('providerUnavailable');
    } catch (_) {
      throw const TranslationApiException('translationFailed');
    }
  }

  Future<String?> _readToken() async {
    try {
      return await authService.getIdToken();
    } on AuthException {
      return null;
    } catch (_) {
      return null;
    }
  }

  static Uri? _parseBaseUri(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed.endsWith('/') ? trimmed : '$trimmed/');
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http') || uri.host.isEmpty) {
      return null;
    }
    return uri;
  }

  static Map<String, dynamic>? _decodeObject(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  static String _errorCode(int statusCode, Map<String, dynamic>? payload) {
    final value = payload?['error'];
    final code = value is Map<String, dynamic> ? value['code'] : null;
    const publicCodes = {
      'invalidRequest',
      'unsupportedLanguage',
      'requestTooLarge',
      'rateLimited',
      'unauthorized',
      'providerUnavailable',
      'timeout',
      'translationFailed',
    };
    if (code is String && publicCodes.contains(code)) return code;
    if (statusCode == 401) return 'unauthorized';
    if (statusCode == 413) return 'requestTooLarge';
    if (statusCode == 429) return 'rateLimited';
    if (statusCode == 504) return 'timeout';
    if (statusCode == 503) return 'providerUnavailable';
    return 'translationFailed';
  }

  void close() => _client.close();
}