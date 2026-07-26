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
import 'package:travel_super_app/features/trips/presentation/screens/trip_list_page.dart';
import 'package:travel_super_app/features/weather/providers/weather_provider.dart';

class _FakeTripRepository extends TripRepository {
  _FakeTripRepository(this._trips);

  final List<Trip> _trips;

  @override
  Stream<List<domain.Trip>> watchAll() {
    return Stream.value(_trips);
  }

  @override
  Future<void> create(domain.Trip trip) async {}

  @override
  Future<void> update(domain.Trip trip) async {}

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
      weatherProvider('Paris').overrideWith(
        (ref) async => throw Exception('offline'),
      ),
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

  testWidgets('Trip list duplicate menu opens prefilled duplicate draft', (tester) async {
    final fakeRepo = _FakeTripRepository(<Trip>[makeTrip()]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: commonOverrides(fakeRepo),
        child: const MaterialApp(home: TripListPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duplicate').first);
    await tester.pumpAndSettle();

    expect(find.text('Duplicate Trip'), findsWidgets);
    expect(find.text('Create Trip'), findsOneWidget);
    expect(find.text('Paris (Copy)'), findsOneWidget);
    expect(find.text('1500'), findsOneWidget);
    expect(find.text('Anniversary trip'), findsOneWidget);
  });

  testWidgets('Trip details duplicate action opens prefilled duplicate draft', (tester) async {
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
    await tester.tap(find.text('Duplicate trip'));
    await tester.pumpAndSettle();

    expect(find.text('Duplicate Trip'), findsWidgets);
    expect(find.text('Create Trip'), findsOneWidget);
    expect(find.text('Paris (Copy)'), findsOneWidget);
    expect(find.text('1500'), findsOneWidget);
    expect(find.text('Anniversary trip'), findsOneWidget);
  });
}
