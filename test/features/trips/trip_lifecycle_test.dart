import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/flights/providers/flight_provider.dart';
import 'package:travel_super_app/features/hotels/models/currency_rate.dart';
import 'package:travel_super_app/features/hotels/models/nearby_bundle.dart';
import 'package:travel_super_app/features/hotels/models/nearby_place.dart';
import 'package:travel_super_app/features/hotels/providers/hotel_experience_provider.dart';
import 'package:travel_super_app/features/hotels/providers/hotel_provider.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart' as domain;
import 'package:travel_super_app/features/trips/domain/repositories/trip_repository.dart';
import 'package:travel_super_app/features/trips/models/trip.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_provider.dart';
import 'package:travel_super_app/features/trips/presentation/screens/create_trip_page.dart';
import 'package:travel_super_app/features/trips/presentation/screens/trip_list_page.dart';
import 'package:travel_super_app/features/weather/providers/weather_provider.dart';

class _FakeTripRepository extends TripRepository {
  _FakeTripRepository(this._trips);

  final List<Trip> _trips;
  final List<Trip> savedTrips = <Trip>[];
  final List<Trip> updatedTrips = <Trip>[];

  @override
  Stream<List<domain.Trip>> watchAll() {
    return Stream.value(_trips);
  }

  @override
  Future<void> create(domain.Trip trip) async {
    savedTrips.add(trip);
  }

  @override
  Future<void> update(domain.Trip trip) async {
    updatedTrips.add(trip);
  }

  @override
  Future<void> delete(String id) async {}

  @override
  Future<domain.Trip?> get(String id) async {
    for (final trip in _trips) {
      if (trip.id == id) {
        return trip;
      }
    }
    return null;
  }
}

void main() {
  Trip makeTrip() {
    return Trip(
      id: 'trip-1',
      destination: 'Paris',
      startDate: DateTime(2026, 9, 14),
      endDate: DateTime(2026, 9, 18),
      budget: 1500,
      currency: 'GBP',
      travellers: 2,
      notes: 'Anniversary trip',
      createdAt: DateTime(2026, 7, 1),
    );
  }

  List<Override> commonOverrides(_FakeTripRepository fakeRepo) {
    return <Override>[
      tripRepositoryProvider.overrideWithValue(fakeRepo),
      savedFlightsProvider.overrideWith((ref) => Stream.value(const [])),
      savedHotelsProvider.overrideWith((ref) => Stream.value(const [])),
      weatherProvider('Paris').overrideWith((ref) async => throw Exception('offline')),
      weatherProvider('Paris (Copy)').overrideWith((ref) async => throw Exception('offline')),
      nearbyBundleProvider('Paris').overrideWith(
        (ref) async => const NearbyBundle(
          city: 'Paris',
          attractions: <NearbyPlace>[
            NearbyPlace(name: 'Eiffel Tower', distanceKm: 2.1, type: 'attraction'),
          ],
          restaurants: <NearbyPlace>[],
          transport: <NearbyPlace>[],
        ),
      ),
      currencyRateProvider('EUR').overrideWith(
        (ref) async => const CurrencyRate(base: 'GBP', target: 'EUR', rate: 1.17),
      ),
    ];
  }

  testWidgets('list to details to edit navigation regression remains intact', (tester) async {
    final fakeRepo = _FakeTripRepository(<Trip>[makeTrip()]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: commonOverrides(fakeRepo),
        child: const MaterialApp(home: TripListPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('View itinerary →').first);
    await tester.pumpAndSettle();

    expect(find.text('Trip to Paris'), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit trip'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateTripPage), findsOneWidget);
    expect(find.text('Edit Trip'), findsWidgets);
    expect(find.text('Update Trip'), findsOneWidget);
  });

  testWidgets('duplicate submit creates a new trip and does not update original id', (tester) async {
    final trip = makeTrip();
    final fakeRepo = _FakeTripRepository(<Trip>[trip]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: commonOverrides(fakeRepo),
        child: MaterialApp(
          home: CreateTripPage(
            initialTrip: trip,
            forceCreateMode: true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Create Trip').last);
    await tester.pumpAndSettle();

    expect(fakeRepo.updatedTrips, isEmpty);
    expect(fakeRepo.savedTrips.length, 1);
    expect(fakeRepo.savedTrips.first.id, isNot(equals(trip.id)));
    expect(fakeRepo.savedTrips.first.destination, 'Paris (Copy)');
  });
}
