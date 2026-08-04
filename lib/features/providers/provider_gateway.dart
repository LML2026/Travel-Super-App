import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/travel_provider_contracts.dart';
import '../flights/models/flight.dart';
import '../flights/models/flight_search_request.dart';
import '../hotels/models/hotel.dart';
import '../hotels/models/hotel_search_request.dart';

abstract interface class ProviderGateway {
  Future<List<Flight>> searchFlights(FlightSearchRequest request);
  Future<List<Hotel>> searchHotels(HotelSearchRequest request);
  Future<List<String>> searchActivities({required String destination});
  Future<List<PlaceResult>> searchPlaces({
    required String query,
    Set<PlaceCategory> categories = const {},
    int limit = 20,
  });
  Future<String> translate({
    required String text,
    required String sourceLanguageCode,
    required String targetLanguageCode,
  });
}

class DefaultProviderGateway implements ProviderGateway {
  const DefaultProviderGateway();

  @override
  Future<List<Flight>> searchFlights(FlightSearchRequest request) async {
    return const <Flight>[];
  }

  @override
  Future<List<Hotel>> searchHotels(HotelSearchRequest request) async {
    return const <Hotel>[];
  }

  @override
  Future<List<String>> searchActivities({required String destination}) async {
    return const <String>[];
  }

  @override
  Future<List<PlaceResult>> searchPlaces({
    required String query,
    Set<PlaceCategory> categories = const {},
    int limit = 20,
  }) async {
    return const <PlaceResult>[];
  }

  @override
  Future<String> translate({
    required String text,
    required String sourceLanguageCode,
    required String targetLanguageCode,
  }) async {
    return text;
  }
}

final providerGatewayProvider = Provider<ProviderGateway>((ref) {
  return const DefaultProviderGateway();
});
