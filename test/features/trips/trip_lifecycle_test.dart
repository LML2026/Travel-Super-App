import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/flights/providers/flight_provider.dart';
import 'package:travel_super_app/features/hotels/models/currency_rate.dart';
import 'package:travel_super_app/features/hotels/models/nearby_bundle.dart';
import 'package:travel_super_app/features/hotels/models/nearby_place.dart';
import 'package:travel_super_app/features/hotels/providers/hotel_experience_provider.dart';
import 'package:travel_super_app/features/hotels/providers/hotel_provider.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart'
    as domain;
import 'package:travel_super_app/features/trips/domain/repositories/trip_repository.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_provider.dart';
import 'package:travel_super_app/features/trips/presentation/screens/trip_list_page.dart';
import 'package:travel_super_app/features/weather/providers/weather_provider.dart';

class _FakeTripRepository extends TripRepository {
  _FakeTripRepository(this._trips);

  final List<domain.Trip> _trips;
  final List<domain.Trip> savedTrips = <domain.Trip>[];
  final List<domain.Trip> updatedTrips = <domain.Trip>[];

  @override
  Stream<List<domain.Trip>> watchTrips() {
    return Stream.value(_trips.map(_toDomainTrip).toList());
  }

  @override
  Future<void> createTrip(domain.Trip trip) async {
    savedTrips.add(trip);
  }

  @override
  Future<void> updateTrip(domain.Trip trip) async {
    updatedTrips.add(trip);
  }

  @override
  Future<void> deleteTrip(String tripId) async {}

  @override
  Future<domain.Trip?> get(String tripId) async {
    for (final trip in _trips) {
      if (trip.id == tripId) {
        return _toDomainTrip(trip);
      }
    }
    return null;
  }

  @override
  Future<List<domain.Trip>> getAll() async {
    return _trips.map(_toDomainTrip).toList();
  }
}

domain.Trip _toDomainTrip(domain.Trip trip) {
  return domain.Trip(
    id: trip.id,
    title: trip.title,
    destination: trip.destination,
    startDate: trip.startDate,
    endDate: trip.endDate,
    budget: trip.budget,
    currency: trip.currency,
    travellers: trip.travellers,
    notes: trip.notes,
    createdAt: trip.createdAt,
    updatedAt: trip.updatedAt,
  );
}

void main() {
  domain.Trip makeTrip() {
    return domain.Trip(
      id: 'trip-1',
      title: 'Paris Getaway',
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
      weatherProvider(
        'Paris',
      ).overrideWith((ref) async => throw Exception('offline')),
      weatherProvider(
        'Paris (Copy)',
      ).overrideWith((ref) async => throw Exception('offline')),
      nearbyBundleProvider('Paris').overrideWith(
        (ref) async => const NearbyBundle(
          city: 'Paris',
          attractions: <NearbyPlace>[
            NearbyPlace(
              name: 'Eiffel Tower',
              distanceKm: 2.1,
              type: 'attraction',
            ),
          ],
          restaurants: <NearbyPlace>[],
          transport: <NearbyPlace>[],
        ),
      ),
      currencyRateProvider('EUR').overrideWith(
        (ref) async =>
            const CurrencyRate(base: 'GBP', target: 'EUR', rate: 1.17),
      ),
    ];
  }

  testWidgets('trip list opens trip dashboard on tap', (tester) async {
    final fakeRepo = _FakeTripRepository(<domain.Trip>[makeTrip()]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: commonOverrides(fakeRepo),
        child: const MaterialApp(home: TripListPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Paris'));
    await tester.pumpAndSettle();

    expect(find.text('Trip Dashboard'), findsOneWidget);
    expect(find.text('Flights'), findsOneWidget);
    expect(find.text('Hotel'), findsOneWidget);
  });
}
