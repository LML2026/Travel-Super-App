import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/core/api/api_client.dart';
import 'package:travel_super_app/core/api/api_endpoints.dart';
import 'package:travel_super_app/core/api/backend_auth.dart';
import 'package:travel_super_app/features/wallet/data/services/wallet_fx_service.dart';

class _NoTokenBackendAuth implements BackendAuth {
  const _NoTokenBackendAuth();

  @override
  Future<String?> idToken() async => null;
}

void main() {
  test('parses existing backend {base,target,rate} response payload', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://backend.example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.path, ApiEndpoints.currencyRate);
          expect(options.queryParameters['base'], 'GBP');
          expect(options.queryParameters['target'], 'EUR');
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: const <String, dynamic>{
                'base': 'GBP',
                'target': 'EUR',
                'rate': 1.1666,
              },
            ),
          );
        },
      ),
    );

    final service = WalletFxService(
      apiClient: ApiClient(
        dio: dio,
        backendAuth: const _NoTokenBackendAuth(),
      ),
    );

    await expectLater(
      service.getRate(base: 'GBP', target: 'EUR'),
      completion(1.1666),
    );
  });
}
