import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/hotel.dart';
import '../models/hotel_search_request.dart';
import '../../../core/constants/api_config.dart';
import '../../../core/utils/app_logger.dart';

class HotelService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    contentType: 'application/json',
  ));

  Future<List<Hotel>> searchHotels(HotelSearchRequest request) async {
    try {
      appLogger.i('🔍 Searching hotels for ${request.city}...');

      final response = await _dio.post(
        '/api/hotels/search',
        data: jsonEncode(request.toJson()),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
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
    } on DioException catch (e) {
      appLogger.e(
        '❌ Hotel search failed',
        error: e,
        stackTrace: e.stackTrace,
      );
      throw Exception('Hotel search failed: ${e.message}');
    } catch (e, st) {
      appLogger.e(
        '❌ Unexpected error during hotel search',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
