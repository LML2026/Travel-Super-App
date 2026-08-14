import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:itarevo/core/auth/auth_service.dart';
import 'package:itarevo/core/auth/auth_state.dart';
import 'package:itarevo/core/auth/auth_user.dart';
import 'package:itarevo/core/translation/backend_translation_service.dart';
import 'package:itarevo/core/translation/translation_api_exception.dart';
import 'package:itarevo/core/translation/translation_service.dart';

class _FakeAuthService implements AuthService {
  final String? token;
  int tokenCalls = 0;

  _FakeAuthService(this.token);

  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();

  @override
  Future<AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<AuthUser> createAccount({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();

  @override
  Future<String?> getIdToken() async {
    tokenCalls++;
    return token;
  }
}

TranslationRequest _request() => const TranslationRequest(
  sourceText: 'Where is the station?',
  sourceLanguageCode: 'auto',
  targetLanguageCode: 'it',
);

BackendTranslationService _service({
  required _FakeAuthService auth,
  required http.Client client,
  String baseUrl = 'https://backend.example.test/',
  Duration timeout = const Duration(seconds: 15),
}) => BackendTranslationService(
  authService: auth,
  client: client,
  baseUrl: baseUrl,
  requestTimeout: timeout,
);

void main() {
  test(
    'missing backend URL stays unavailable without requesting a token',
    () async {
      final auth = _FakeAuthService('token');
      final service = _service(
        auth: auth,
        client: MockClient((_) async => throw StateError('called')),
        baseUrl: '',
      );

      await expectLater(
        service.translate(_request()),
        throwsA(
          isA<TranslationApiException>().having(
            (error) => error.code,
            'code',
            'providerUnavailable',
          ),
        ),
      );
      expect(auth.tokenCalls, 0);
      service.close();
    },
  );

  test('missing token is unauthorized without an HTTP request', () async {
    final auth = _FakeAuthService(null);
    var requests = 0;
    final service = _service(
      auth: auth,
      client: MockClient((_) async {
        requests++;
        return http.Response('{}', 200);
      }),
    );

    await expectLater(
      service.translate(_request()),
      throwsA(
        isA<TranslationApiException>().having(
          (error) => error.code,
          'code',
          'unauthorized',
        ),
      ),
    );
    expect(requests, 0);
    service.close();
  });

  test('successful response maps translation and detected language', () async {
    final auth = _FakeAuthService('token');
    late http.Request sentRequest;
    final service = _service(
      auth: auth,
      client: MockClient((request) async {
        sentRequest = request;
        return http.Response(
          '{"translatedText":"Dove e la stazione?","detectedSourceLanguage":"en"}',
          200,
        );
      }),
    );

    final result = await service.translate(_request());

    expect(result.translatedText, 'Dove e la stazione?');
    expect(result.detectedSourceLanguage, 'en');
    expect(sentRequest.headers['authorization'], isNotNull);
    expect(sentRequest.headers['content-type'], contains('application/json'));
    service.close();
  });

  test('malformed success response is translationFailed', () async {
    final service = _service(
      auth: _FakeAuthService('token'),
      client: MockClient(
        (_) async => http.Response('{"unexpected":true}', 200),
      ),
    );

    await expectLater(
      service.translate(_request()),
      throwsA(
        isA<TranslationApiException>().having(
          (error) => error.code,
          'code',
          'translationFailed',
        ),
      ),
    );
    service.close();
  });

  test('public backend errors map without exposing response text', () async {
    for (final code in const [
      'invalidRequest',
      'unsupportedLanguage',
      'requestTooLarge',
      'rateLimited',
      'unauthorized',
      'providerUnavailable',
      'timeout',
      'translationFailed',
    ]) {
      final service = _service(
        auth: _FakeAuthService('token'),
        client: MockClient(
          (_) async => http.Response(
            '{"error":{"code":"$code","message":"private text"}}',
            code == 'unauthorized' ? 401 : 400,
          ),
        ),
      );

      await expectLater(
        service.translate(_request()),
        throwsA(
          isA<TranslationApiException>().having(
            (error) => error.code,
            'code',
            code,
          ),
        ),
      );
      service.close();
    }
  });

  test('timeout maps to timeout', () async {
    final service = _service(
      auth: _FakeAuthService('token'),
      timeout: const Duration(milliseconds: 1),
      client: MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return http.Response('{}', 200);
      }),
    );

    await expectLater(
      service.translate(_request()),
      throwsA(
        isA<TranslationApiException>().having(
          (error) => error.code,
          'code',
          'timeout',
        ),
      ),
    );
    service.close();
  });
}
