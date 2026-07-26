import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/utils/app_logger.dart';
import '../../../core/constants/api_config.dart';
import '../models/flight.dart';

class FlightService {
  static const String backendUrl = '$apiBaseUrl/api/flights/search';

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

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'origin': from.trim().toUpperCase(),
          'destination': to.trim().toUpperCase(),
          'departureDate': departureDate,
          'returnDate': returnDate,
          'passengers': passengers,
          'cabinClass': cabinClass.toLowerCase(),
        }),
      );

      appLogger.d('FlightService: response ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

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
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e, st) {
      appLogger.e('FlightService: error', error: e, stackTrace: st);
      rethrow;
    }
  }
}
