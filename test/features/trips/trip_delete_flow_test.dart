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
import 'package:travel_super_app/features/trips/presentation/screens/trip_details_page.dart';
import 'package:travel_super_app/features/trips/presentation/screens/trip_list_page.dart';
import 'package:travel_super_app/features/weather/providers/weather_provider.dart';

class _FakeTripRepository extends TripRepository {
  _FakeTripRepository(this._trips);

  final List<Trip> _trips;
  final List<String> deletedTripIds = <String>[];

  @override
  Stream<List<domain.Trip>> watchTrips() {
    return Stream.value(_trips.map(_toDomainTrip).toList());
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    deletedTripIds.add(tripId);
  }

  @override
  Future<void> createTrip(domain.Trip trip) async {}

  @override
  Future<void> updateTrip(domain.Trip trip) async {}

  @override
  Future<domain.Trip?> getTrip(String tripId) async {
    for (final trip in _trips) {
      if (trip.id == tripId) {
        return _toDomainTrip(trip);
      }
    }
    return null;
  }
}

domain.Trip _toDomainTrip(Trip trip) {
  return domain.Trip(
    id: trip.id,
    destination: trip.destination,
    departureDate: trip.departureDate,
    returnDate: trip.returnDate,
    budget: trip.budget,
    currency: trip.currency,
    travellers: trip.travellers,
    notes: trip.notes,
    createdAt: trip.createdAt,
    updatedAt: trip.updatedAt,
  );
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

  testWidgets('Trip list delete cancel does not delete item', (tester) async {
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
    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();

    expect(find.text('Delete trip?'), findsOneWidget);
    expect(find.textContaining('Remove your trip to Paris?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(fakeRepo.deletedTripIds, isEmpty);
  });

  testWidgets('Trip list delete confirm calls delete and shows feedback', (tester) async {
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
    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(fakeRepo.deletedTripIds, <String>['trip-1']);
    expect(find.text('Deleted trip to Paris.'), findsOneWidget);
  });

  testWidgets('Trip details delete confirm deletes and pops to previous page', (tester) async {
    final trip = makeTrip();
    final fakeRepo = _FakeTripRepository(<Trip>[trip]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: commonOverrides(fakeRepo),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TripDetailsPage(trip: trip),
                        ),
                      );
                    },
                    child: const Text('Open Details'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Details'));
    await tester.pumpAndSettle();

    expect(find.text('Trip to Paris'), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete trip'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(fakeRepo.deletedTripIds, <String>['trip-1']);
    expect(find.text('Open Details'), findsOneWidget);
    expect(find.text('Trip to Paris'), findsNothing);
  });
}
