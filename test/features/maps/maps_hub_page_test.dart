import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/core/providers/travel_provider_contracts.dart';
import 'package:travel_super_app/features/flights/models/flight.dart';
import 'package:travel_super_app/features/flights/models/flight_search_request.dart';
import 'package:travel_super_app/features/hotels/models/hotel.dart';
import 'package:travel_super_app/features/hotels/models/hotel_search_request.dart';
import 'package:travel_super_app/features/maps/presentation/screens/maps_hub_page.dart';
import 'package:travel_super_app/features/maps/models/live_location.dart';
import 'package:travel_super_app/features/maps/models/places_prefill.dart';
import 'package:travel_super_app/features/maps/providers/live_location_provider.dart';
import 'package:travel_super_app/features/maps/services/live_location_service.dart';
import 'package:travel_super_app/features/providers/provider_gateway.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_repository.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_provider.dart';
import 'package:travel_super_app/features/trips/presentation/widgets/map_card.dart';

class _FakeProviderGateway implements ProviderGateway {
  @override
  Future<List<String>> searchActivities({required String destination}) async =>
      const <String>[];

  @override
  Future<List<Flight>> searchFlights(FlightSearchRequest request) async =>
      const <Flight>[];

  @override
  Future<List<Hotel>> searchHotels(HotelSearchRequest request) async =>
      const <Hotel>[];

  @override
  Future<List<PlaceResult>> searchPlaces({
    required String query,
    Set<PlaceCategory> categories = const {},
    int limit = 20,
  }) async {
    return <PlaceResult>[
      PlaceResult(
        id: 'nearby-1',
        name: 'Terminal Restroom',
        category: categories.isEmpty ? PlaceCategory.toilet : categories.first,
        address: 'Terminal 2',
        dataSource: TravelDataSource.mock,
      ),
    ];
  }

  @override
  Future<String> translate({required String text, required String sourceLanguageCode, required String targetLanguageCode}) async =>
      text;
}

class _FakeLiveLocationService implements LiveLocationService {
  _FakeLiveLocationService(this.location);

  final LiveLocation location;

  @override
  Future<LiveLocation> getCurrentLocation() async => location;

  @override
  Stream<LiveLocation> watchCurrentLocation() => Stream.value(location);
}

class _FakeTripRepository implements TripRepository {
  _FakeTripRepository(this.trips);

  final List<Trip> trips;

  @override
  Future<void> createTrip(Trip trip) async {}

  @override
  Future<void> deleteTrip(String id) async {}

  @override
  Future<Trip?> get(String id) async {
    for (final trip in trips) {
      if (trip.id == id) {
        return trip;
      }
    }
    return null;
  }

  @override
  Future<List<Trip>> getAll() async => trips;

  @override
  Future<void> updateTrip(Trip trip) async {}

  @override
  Stream<List<Trip>> watchTrips() => Stream.value(trips);
}

void main() {
  testWidgets('Maps hub shows trip context and map card', (tester) async {
    final trip = Trip(
      id: 'trip-1',
      title: 'Rome Escape',
      destination: 'Rome',
      startDate: DateTime(2026, 9, 2),
      endDate: DateTime(2026, 9, 8),
      budget: 1500,
      currency: 'GBP',
      travellers: 2,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripRepositoryProvider.overrideWithValue(_FakeTripRepository(<Trip>[trip])),
          providerGatewayProvider.overrideWithValue(_FakeProviderGateway()),
          liveLocationServiceProvider.overrideWithValue(
            _FakeLiveLocationService(
              LiveLocation(
                latitude: 51.5072,
                longitude: -0.1276,
                accuracy: 9,
                timestamp: DateTime(2026, 7, 28),
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          home: MapsHubPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Maps'), findsOneWidget);
    expect(find.textContaining('Maps hub for 1 trip'), findsOneWidget);
    expect(find.text('Trip context'), findsOneWidget);
    expect(find.byType(MapCard), findsOneWidget);
  });

  testWidgets('Maps hub shows nearby essentials prefill title and category chip',
      (tester) async {
    final trip = Trip(
      id: 'trip-1',
      title: 'Rome Escape',
      destination: 'Rome',
      startDate: DateTime(2026, 9, 2),
      endDate: DateTime(2026, 9, 8),
      budget: 1500,
      currency: 'GBP',
      travellers: 2,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripRepositoryProvider.overrideWithValue(_FakeTripRepository(<Trip>[trip])),
          providerGatewayProvider.overrideWithValue(_FakeProviderGateway()),
          liveLocationServiceProvider.overrideWithValue(
            _FakeLiveLocationService(
              LiveLocation(
                latitude: 51.5072,
                longitude: -0.1276,
                accuracy: 9,
                timestamp: DateTime(2026, 7, 28),
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          home: MapsHubPage(
            prefill: PlacesPrefill(
              query: 'public toilets open now within 500 m',
              title: 'Toilets',
              categories: <PlaceCategory>{PlaceCategory.toilet},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final suggestedSearch =
        find.textContaining('Suggested search: public toilets open now within 500 m');
    await tester.scrollUntilVisible(
      suggestedSearch,
      220,
      scrollable: find.byType(Scrollable).first,
    );

    expect(suggestedSearch, findsOneWidget);
    expect(find.text('toilet'), findsOneWidget);
  });
}