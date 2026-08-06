import 'dart:convert';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/utils/app_logger.dart';
import '../models/hotel.dart';
import '../models/hotel_search_request.dart';

class HotelApiService {
  HotelApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Hotel>> searchHotels(HotelSearchRequest request) async {
    try {
      appLogger.i('Searching hotels for ${request.city}...');

      final response = await _apiClient
          .post(
        ApiEndpoints.hotelsSearch,
        data: jsonEncode(request.toJson()),
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw _SearchTimeoutException(
              'Hotel search timed out. Please try again.');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> hotelsList = response.data['hotels'] ?? [];
        final hotels = hotelsList
            .map((h) => Hotel.fromJson(h as Map<String, dynamic>))
            .take(25)
            .toList();

        appLogger.i('Found ${hotels.length} hotels');
        return hotels;
      }

      throw Exception('Unexpected response from hotel search service.');
    } catch (e, st) {
      appLogger.e(
        'Hotel search failed',
        error: e,
        stackTrace: st,
      );
      throw Exception('Unable to search hotels right now. Please try again.');
    }
  }
}

class _SearchTimeoutException implements Exception {
  const _SearchTimeoutException(this.message);

  final String message;

  @override
  String toString() => message;
}
