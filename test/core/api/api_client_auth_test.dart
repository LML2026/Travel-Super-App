import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/core/api/api_client.dart';
import 'package:travel_super_app/core/api/backend_auth.dart';

class _FakeBackendAuth implements BackendAuth {
  const _FakeBackendAuth(this.token);

  final String? token;

  @override
  Future<String?> idToken() async => token;
}

void main() {
  Dio dioWithCapture(List<Map<String, dynamic>> capturedHeaders) {
    final dio = Dio(BaseOptions(baseUrl: 'https://backend.example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedHeaders.add(Map<String, dynamic>.from(options.headers));
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: const <String, dynamic>{'ok': true},
            ),
          );
        },
      ),
    );
    return dio;
  }

  test('adds signed-in Firebase bearer token to API requests', () async {
    final capturedHeaders = <Map<String, dynamic>>[];
    final client = ApiClient(
      dio: dioWithCapture(capturedHeaders),
      backendAuth: const _FakeBackendAuth('signed-in-token'),
    );

    await client.get('/api/weather');

    expect(capturedHeaders.single['Authorization'], 'Bearer signed-in-token');
  });

  test('adds anonymous Firebase bearer token to API requests', () async {
    final capturedHeaders = <Map<String, dynamic>>[];
    final client = ApiClient(
      dio: dioWithCapture(capturedHeaders),
      backendAuth: const _FakeBackendAuth('anonymous-token'),
    );

    await client.post(
      '/api/flights/search',
      data: const <String, dynamic>{'origin': 'LHR'},
    );

    expect(capturedHeaders.single['Authorization'], 'Bearer anonymous-token');
    expect(capturedHeaders.single['Content-Type'], 'application/json');
  });
}
