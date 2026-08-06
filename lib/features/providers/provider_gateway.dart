import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/travel_provider_contracts.dart';
import '../flights/models/flight.dart';
import '../flights/models/flight_search_request.dart';
import '../hotels/models/hotel.dart';
import '../hotels/models/hotel_search_request.dart';

abstract interface class ProviderGateway {
  Future<List<PlaceResult>> searchPlaces({
    required String query,
    Set<PlaceCategory> categories = const {},
    int limit = 20,
  });

  Future<List<Flight>> searchFlights(FlightSearchRequest request);

  Future<List<Hotel>> searchHotels(HotelSearchRequest request);

  Future<List<String>> searchActivities({required String destination});

  Future<String> translate({
    required String text,
    required String sourceLanguageCode,
    required String targetLanguageCode,
  });
}

class _MockProviderGateway implements ProviderGateway {
  const _MockProviderGateway();

  @override
  Future<List<PlaceResult>> searchPlaces({
    required String query,
    Set<PlaceCategory> categories = const {},
    int limit = 20,
  }) async =>
      const <PlaceResult>[];

  @override
  Future<List<Flight>> searchFlights(FlightSearchRequest request) async =>
      const <Flight>[];

  @override
  Future<List<Hotel>> searchHotels(HotelSearchRequest request) async =>
      const <Hotel>[];

  @override
  Future<List<String>> searchActivities({required String destination}) async =>
      const <String>[];

  @override
  Future<String> translate({
    required String text,
    required String sourceLanguageCode,
    required String targetLanguageCode,
  }) async =>
      text;
}

final providerGatewayProvider = Provider<ProviderGateway>(
  (ref) => const _MockProviderGateway(),
);
