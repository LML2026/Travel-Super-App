import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';

class WalletFxService {
  WalletFxService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<double> getRate({
    required String base,
    required String target,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.currencyRate,
      queryParameters: {
        'base': base,
        'target': target,
      },
    );

    if (response.statusCode != 200 || response.data is! Map<String, dynamic>) {
      throw Exception('Failed to load FX rate.');
    }

    final data = response.data as Map<String, dynamic>;
    final rawRate = data['rate'];
    if (rawRate is num) {
      return rawRate.toDouble();
    }

    throw Exception('Invalid FX response payload.');
  }
}
