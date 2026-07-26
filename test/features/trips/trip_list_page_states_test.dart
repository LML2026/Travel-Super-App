import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart'
    as domain;
import 'package:travel_super_app/features/trips/domain/repositories/trip_repository.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_provider.dart';
import 'package:travel_super_app/features/trips/presentation/screens/trip_list_page.dart';

class _EmptyTripRepository implements TripRepository {
  @override
  Future<void> createTrip(domain.Trip trip) async {}

  @override
  Future<void> updateTrip(domain.Trip trip) async {}

  @override
  Future<void> deleteTrip(String tripId) async {}

  @override
  Stream<List<domain.Trip>> watchTrips() {
    return Stream.value(const <domain.Trip>[]);
  }

  @override
  Future<domain.Trip?> get(String tripId) async {
    return null;
  }

  @override
  Future<List<domain.Trip>> getAll() async {
    return watchTrips().first;
  }
}

class _ErrorTripRepository implements TripRepository {
  @override
  Future<void> createTrip(domain.Trip trip) async {}

  @override
  Future<void> updateTrip(domain.Trip trip) async {}

  @override
  Future<void> deleteTrip(String tripId) async {}

  @override
  Stream<List<domain.Trip>> watchTrips() {
    return Stream.error(Exception('firestore unavailable'));
  }

  @override
  Future<domain.Trip?> get(String tripId) async {
    return null;
  }

  @override
  Future<List<domain.Trip>> getAll() async {
    return watchTrips().first;
  }
}

class _SingleTripRepository implements TripRepository {
  _SingleTripRepository(this.trip);

  final domain.Trip trip;

  @override
  Future<void> createTrip(domain.Trip trip) async {}

  @override
  Future<void> updateTrip(domain.Trip trip) async {}

  @override
  Future<void> deleteTrip(String tripId) async {}

  @override
  Stream<List<domain.Trip>> watchTrips() {
    return Stream.value(<domain.Trip>[_toDomainTrip(trip)]);
  }

  @override
  Future<domain.Trip?> get(String tripId) async {
    return tripId == trip.id ? _toDomainTrip(trip) : null;
  }

  @override
  Future<List<domain.Trip>> getAll() async {
    return watchTrips().first;
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
  testWidgets('shows empty state when user has no trips', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripRepositoryProvider.overrideWithValue(_EmptyTripRepository()),
        ],
        child: const MaterialApp(home: TripListPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No trips yet'), findsOneWidget);
    expect(find.text('Tap + to create your first trip.'), findsOneWidget);
  });

  testWidgets('shows list item when repository returns trips', (tester) async {
    final trip = domain.Trip(
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripRepositoryProvider.overrideWithValue(_SingleTripRepository(trip)),
        ],
        child: const MaterialApp(home: TripListPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Paris'), findsOneWidget);
    expect(find.text('14 Sep 2026 → 18 Sep 2026'), findsOneWidget);
  });

  testWidgets('shows graceful error when stream fails', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripRepositoryProvider.overrideWithValue(_ErrorTripRepository()),
        ],
        child: const MaterialApp(home: TripListPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Exception: firestore unavailable'), findsOneWidget);
    expect(find.textContaining('firestore unavailable'), findsOneWidget);
  });
}
