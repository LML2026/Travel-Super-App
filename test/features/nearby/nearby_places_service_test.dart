import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_super_app/core/api/api_endpoints.dart';
import 'package:travel_super_app/core/providers/travel_provider_contracts.dart';
import 'package:travel_super_app/features/flights/models/flight.dart';
import 'package:travel_super_app/features/flights/models/flight_search_request.dart';
import 'package:travel_super_app/features/hotels/models/hotel.dart';
import 'package:travel_super_app/features/hotels/models/hotel_search_request.dart';
import 'package:travel_super_app/features/nearby/models/nearby_service_result.dart';
import 'package:travel_super_app/features/nearby/models/nearby_service_metadata.dart';
import 'package:travel_super_app/features/nearby/models/nearby_service_type.dart';
import 'package:travel_super_app/features/nearby/services/nearby_places_service.dart';
import 'package:travel_super_app/features/providers/provider_gateway.dart';

class _Gateway implements ProviderGateway {
  _Gateway(this.result);
  final PlaceResult result;

  @override
  Future<List<PlaceResult>> searchPlaces(
          {required String query,
          Set<PlaceCategory> categories = const {},
          int limit = 20}) async =>
      [result];
  @override
  Future<List<Flight>> searchFlights(FlightSearchRequest request) async =>
      const [];
  @override
  Future<List<Hotel>> searchHotels(HotelSearchRequest request) async =>
      const [];
  @override
  Future<List<String>> searchActivities({required String destination}) async =>
      const [];
  @override
  Future<String> translate(
          {required String text,
          required String sourceLanguageCode,
          required String targetLanguageCode}) async =>
      text;
}

void main() {
  test('backend nearby service maps category searches to production endpoint',
      () async {
    final requests = <Map<String, dynamic>>[];
    final service = BackendNearbyPlacesService(
      backendGet: (path, {queryParameters}) async {
        requests.add(<String, dynamic>{
          'path': path,
          'query': queryParameters,
        });
        return {
          'places': [
            {'name': 'Place', 'distanceKm': 1.2, 'type': 'nearby'},
          ],
        };
      },
    );

    for (final serviceType in nearbyEssentialsMvpServices) {
      final results = await service.search(NearbyPlacesQuery(
        location: 'London',
        serviceType: serviceType,
      ));

      expect(results.single.source, NearbyDataSource.backend);
    }

    expect(
      requests.every((request) => request['path'] == ApiEndpoints.nearbyPlaces),
      isTrue,
    );
    expect(
      requests.map((request) => request['query']['category']),
      containsAll(<String>[
        'toilets',
        'supermarkets',
        'parking',
        'petrol',
        'trainStation',
        'busStation',
        'airports',
        'pharmacies',
        'hospitals',
        'atms',
        'evCharging',
        'restaurants',
        'cafes',
        'attractions',
        'taxi',
        'transport',
      ]),
    );
  });

  test('backend nearby failures return disclosed demo fallback', () async {
    final service = BackendNearbyPlacesService(
      backendGet: (_, {queryParameters}) async => throw StateError('offline'),
    );

    final results = await service.search(const NearbyPlacesQuery(
      location: 'Paris',
      serviceType: NearbyServiceType.supermarket,
    ));

    expect(results, isNotEmpty);
    expect(results.every((place) => place.source == NearbyDataSource.fallback),
        isTrue);
    expect(
        results
            .every((place) => place.sourceMetadata['liveUnavailable'] == true),
        isTrue);
  });

  test('maps live Google place data and source metadata', () async {
    final service = GoogleNearbyPlacesService(
      gateway: _Gateway(const PlaceResult(
        id: 'google-1',
        name: 'Live Cafe',
        category: PlaceCategory.cafe,
        address: '1 Main Street',
        location: GeoPoint(51.5, -0.1),
        rating: 4.7,
        dataSource: TravelDataSource.live,
        isOpenNow: true,
      )),
    );

    final result = (await service.search(const NearbyPlacesQuery(
      location: 'London',
      serviceType: NearbyServiceType.cafe,
    )))
        .single;

    expect(result.source, NearbyDataSource.google);
    expect(result.name, 'Live Cafe');
    expect(result.isOpenNow, isTrue);
    expect(result.latitude, 51.5);
  });

  test('returns deterministic labelled demo fallback for non-live data',
      () async {
    final service = GoogleNearbyPlacesService(
      gateway: _Gateway(const PlaceResult(
        id: 'demo-1',
        name: 'Demo Cafe',
        category: PlaceCategory.cafe,
        dataSource: TravelDataSource.mock,
      )),
    );

    final first = await service.search(const NearbyPlacesQuery(
      location: 'Paris',
      serviceType: NearbyServiceType.cafe,
    ));
    final second = await service.search(const NearbyPlacesQuery(
      location: 'Paris',
      serviceType: NearbyServiceType.cafe,
    ));

    expect(first.map((place) => place.id), second.map((place) => place.id));
    expect(first.every((place) => place.source == NearbyDataSource.fallback),
        isTrue);
    expect(first.first.sourceMetadata['provider'], 'ITAREVO Demo Places');
  });
}
