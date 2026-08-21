import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/discovery/data/travel_discovery_service.dart';
import 'package:travel_super_app/features/discovery/domain/travel_discovery_models.dart';
import 'package:travel_super_app/features/flights/models/flight.dart';
import 'package:travel_super_app/features/hotels/models/hotel.dart';
import 'package:travel_super_app/features/nearby/models/nearby_service_result.dart';
import 'package:travel_super_app/features/nearby/models/nearby_service_type.dart';
import 'package:travel_super_app/features/nearby/services/nearby_places_service.dart';

void main() {
  test('normalizes Duffel, backend and Google Places sources', () async {
    final service = ProviderTravelDiscoveryService(
      flightSearch: (_) async => [
        const Flight(
          id: 'duffel-flight',
          airline: 'Test Air',
          airlineLogo: '',
          flightNumber: 'TA100',
          origin: 'LHR',
          destination: 'CDG',
          departureAt: '2026-09-01T08:00:00',
          arrivalAt: '2026-09-01T10:00:00',
          duration: 'PT2H',
          stops: 0,
          amount: 200,
          currency: 'GBP',
          dataSource: FlightDataSource.duffelTest,
        ),
      ],
      hotelSearch: (_) async => [
        const Hotel(
          id: 'backend-hotel',
          name: 'Backend Hotel',
          image: '',
          rating: 4.5,
          address: '1 Main Street',
          city: 'Paris',
          price: 150,
          currency: 'GBP',
          amenities: [],
          totalPrice: 300,
          nights: 2,
          dataSource: HotelDataSource.backend,
        ),
      ],
      nearbyService: _NearbyService((query) async => [
            NearbyServiceResult(
              id: 'google-place-${query.serviceType.name}',
              name: query.serviceType == NearbyServiceType.restaurant
                  ? 'Live Restaurant'
                  : 'Live Attraction',
              serviceType: query.serviceType,
              categoryLabel: query.serviceType.name,
              address: 'Paris centre',
              latitude: 48.85,
              longitude: 2.35,
              source: NearbyDataSource.google,
              sourceMetadata: const {'provider': 'Google Places'},
            ),
          ]),
    );

    final results = await service.search(_query());

    expect(_result(results, 'duffel-flight').source, DiscoveryDataSource.test);
    expect(
        _result(results, 'backend-hotel').source, DiscoveryDataSource.backend);
    expect(_result(results, 'google-place-attraction').source,
        DiscoveryDataSource.live);
    expect(_result(results, 'google-place-restaurant').source,
        DiscoveryDataSource.live);
  });

  test('provider failures use explicit deterministic fallback results',
      () async {
    final service = ProviderTravelDiscoveryService(
      flightSearch: (_) async => throw StateError('provider failure'),
      hotelSearch: (_) async => throw StateError('provider failure'),
      nearbyService: _NearbyService((_) async => throw StateError('offline')),
    );

    final results = await service.search(_query());

    expect(
      results
          .where((result) => result.category == DiscoveryCategory.flights)
          .every((result) => result.source == DiscoveryDataSource.fallback),
      isTrue,
    );
    expect(
      results
          .where((result) => result.category == DiscoveryCategory.hotels)
          .every((result) => result.source == DiscoveryDataSource.fallback),
      isTrue,
    );
    expect(
      results
          .where((result) => result.category == DiscoveryCategory.activities)
          .every((result) => result.source == DiscoveryDataSource.fallback),
      isTrue,
    );
    expect(
      results
          .where((result) => result.category == DiscoveryCategory.restaurants)
          .every((result) => result.source == DiscoveryDataSource.fallback),
      isTrue,
    );
  });
}

TravelDiscoveryQuery _query() => TravelDiscoveryQuery(
      destination: 'Paris',
      origin: 'LHR',
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 3),
      travellers: 2,
    );

TravelDiscoveryResult _result(
  List<TravelDiscoveryResult> results,
  String id,
) =>
    results.firstWhere((result) => result.id == id);

class _NearbyService implements NearbyPlacesService {
  _NearbyService(this._search);

  final Future<List<NearbyServiceResult>> Function(NearbyPlacesQuery query)
      _search;

  @override
  Future<List<NearbyServiceResult>> search(NearbyPlacesQuery query) =>
      _search(query);
}
