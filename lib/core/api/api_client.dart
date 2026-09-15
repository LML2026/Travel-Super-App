import 'package:dio/dio.dart';
import '../constants/api_config.dart';
import 'backend_auth.dart';

class ApiClient {
  ApiClient({
    Dio? dio,
    BackendAuth? backendAuth,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: apiBaseUrl,
                contentType: 'application/json',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 15),
              ),
            ),
        _backendAuth = backendAuth ?? FirebaseBackendAuth();

  final Dio _dio;
  final BackendAuth _backendAuth;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: Options(headers: await _headers()),
    );
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          ...await _headers(),
        },
      ),
    );
  }

  Future<Map<String, String>> _headers() async {
    final token = await _backendAuth.idToken();
    if (token == null || token.isEmpty) {
      return const <String, String>{};
    }
    return <String, String>{'Authorization': 'Bearer $token'};
  }
}
