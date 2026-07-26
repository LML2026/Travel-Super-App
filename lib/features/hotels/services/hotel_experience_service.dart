import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/currency_rate.dart';
import '../models/nearby_bundle.dart';

class HotelExperienceService {
  HotelExperienceService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<NearbyBundle> getNearbyBundle(String city) async {
    final response = await _apiClient.get(
      ApiEndpoints.nearbyPlaces,
      queryParameters: {'city': city},
    );

    if (response.statusCode != 200 || response.data is! Map<String, dynamic>) {
      throw Exception('Failed to load nearby places');
    }

    return NearbyBundle.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CurrencyRate> getCurrencyRate({
    String base = 'GBP',
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
      throw Exception('Failed to load currency rate');
    }

    return CurrencyRate.fromJson(response.data as Map<String, dynamic>);
  }

  String staticMapUrl({
    required double latitude,
    required double longitude,
    int zoom = 13,
  }) {
    return 'https://staticmap.openstreetmap.de/staticmap.php?center=$latitude,$longitude&zoom=$zoom&size=900x420&markers=$latitude,$longitude,red-pushpin';
  }
}
