import 'dart:convert';
import '../models/hotel.dart';
import '../models/hotel_search_request.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/utils/app_logger.dart';

class HotelService {
  HotelService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Hotel>> searchHotels(HotelSearchRequest request) async {
    try {
      appLogger.i('🔍 Searching hotels for ${request.city}...');

      final response = await _apiClient.post(
        ApiEndpoints.hotelsSearch,
        data: jsonEncode(request.toJson()),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Hotel search timed out after 15 seconds');
        },
      );

      appLogger.i('✅ Hotel search successful: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> hotelsList = response.data['hotels'] ?? [];
        final hotels = hotelsList
            .map((h) => Hotel.fromJson(h as Map<String, dynamic>))
            .toList();

        appLogger.i('Found ${hotels.length} hotels');
        return hotels;
      }

      throw Exception('Unexpected status code: ${response.statusCode}');
    } catch (e, st) {
      appLogger.e(
        '❌ Hotel search failed',
        error: e,
        stackTrace: st,
      );
      throw Exception('Hotel search failed: $e');
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
