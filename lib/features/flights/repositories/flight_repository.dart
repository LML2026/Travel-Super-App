import '../../../core/utils/app_logger.dart';
import '../../../core/utils/result.dart';
import '../models/flight.dart';
import '../models/flight_search_request.dart';
import '../services/flight_service.dart';

/// Repository layer — the UI and providers talk only to this class.
/// Returns Result<T> so callers never deal with raw exceptions.
class FlightRepository {
  final FlightService _api;

  FlightRepository({FlightService? api}) : _api = api ?? FlightService();

  Future<Result<List<Flight>>> searchFlights(
      FlightSearchRequest request) async {
    try {
      appLogger
          .i('FlightRepository: searching ${request.from} → ${request.to}');
      final flights = await _api.searchFlights(
        from: request.from,
        to: request.to,
        departureDate: request.departureDate,
        returnDate: request.returnDate,
        passengers: request.passengers,
        cabinClass: request.cabinClass,
      );
      appLogger.i('FlightRepository: got ${flights.length} results');
      return Success(flights);
    } catch (e, st) {
      appLogger.e('FlightRepository: search failed', error: e, stackTrace: st);
      return Failure(e.toString(), error: e);
    }
  }
}
