import 'dart:convert';
import '../../../core/utils/app_logger.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/flight.dart';

class FlightService {
  FlightService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Flight>> searchFlights({
    required String from,
    required String to,
    required String departureDate,
    String? returnDate,
    int passengers = 1,
    String cabinClass = 'economy',
  }) async {
    try {
      appLogger.i('FlightService: $from → $to on $departureDate');

      final response = await _apiClient.post(
        ApiEndpoints.flightsSearch,
        data: {
          'origin': from.trim().toUpperCase(),
          'destination': to.trim().toUpperCase(),
          'departureDate': departureDate,
          'returnDate': returnDate,
          'passengers': passengers,
          'cabinClass': cabinClass.toLowerCase(),
        },
      );

      appLogger.d('FlightService: response ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = response.data;

        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Unexpected server response.');
        }

        final rawFlights = decoded['flights'];

        if (rawFlights is! List) {
          throw const FormatException('Flight list is missing.');
        }

        final flightList = rawFlights
            .whereType<Map>()
            .map((item) => Flight.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();

        appLogger.i('FlightService: parsed ${flightList.length} flights');
        return flightList;
      } else {
        throw Exception('API Error ${response.statusCode}: ${jsonEncode(response.data)}');
      }
    } catch (e, st) {
      appLogger.e('FlightService: error', error: e, stackTrace: st);
      rethrow;
    }
  }
}
