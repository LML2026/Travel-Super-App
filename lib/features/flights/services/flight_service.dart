import 'dart:convert';
import '../../../core/utils/app_logger.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/flight.dart';
import 'duffel_flight_service.dart';

class FlightService {
  FlightService({
    ApiClient? apiClient,
    DuffelFlightService? duffelService,
  })  : _apiClient = apiClient ?? ApiClient(),
        _duffelService = duffelService ?? DuffelFlightService();

  final ApiClient _apiClient;
  final DuffelFlightService _duffelService;
  bool _lastSearchUsedFallback = false;

  bool get lastSearchUsedFallback => _lastSearchUsedFallback;

  Future<List<Flight>> searchFlights({
    required String from,
    required String to,
    required String departureDate,
    String? returnDate,
    int passengers = 1,
    String cabinClass = 'economy',
  }) async {
    _lastSearchUsedFallback = false;
    if (_duffelService.isConfigured) {
      try {
        final duffelFlights = await _duffelService.searchFlights(
          from: from,
          to: to,
          departureDate: departureDate,
          returnDate: returnDate,
          passengers: passengers,
          cabinClass: cabinClass,
        );
        if (duffelFlights.isNotEmpty) {
          appLogger.i('FlightService: received Duffel TEST offers');
          return duffelFlights;
        }
      } catch (_) {
        // Fall through to the existing provider and deterministic demo data.
      }
    }

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
            .map((item) => Flight.fromJson(
                  Map<String, dynamic>.from(item),
                  dataSource: FlightDataSource.backend,
                ))
            .toList();

        appLogger.i('FlightService: parsed ${flightList.length} flights');
        return flightList;
      } else {
        throw Exception(
            'API Error ${response.statusCode}: ${jsonEncode(response.data)}');
      }
    } catch (e, st) {
      _lastSearchUsedFallback = true;
      appLogger.e('FlightService: provider unavailable',
          error: e, stackTrace: st);
      return _demoFlights(
        from: from,
        to: to,
        departureDate: departureDate,
        cabinClass: cabinClass,
      );
    }
  }

  List<Flight> _demoFlights({
    required String from,
    required String to,
    required String departureDate,
    required String cabinClass,
  }) {
    return [
      Flight(
        id: 'demo-$from-$to-$departureDate',
        airline: 'Demo Airways',
        airlineLogo: '',
        flightNumber: 'DA101',
        origin: from.trim().toUpperCase(),
        destination: to.trim().toUpperCase(),
        departureAt: '${departureDate}T08:00:00',
        arrivalAt: '${departureDate}T10:15:00',
        duration: 'PT2H15M',
        stops: 0,
        amount: 129,
        currency: 'GBP',
        cabinClass: cabinClass,
        dataSource: FlightDataSource.demo,
      ),
    ];
  }
}
