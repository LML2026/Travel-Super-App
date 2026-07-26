import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart'
    as domain;
import 'package:travel_super_app/features/trips/domain/repositories/trip_repository.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart';
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
  Future<domain.Trip?> getTrip(String tripId) async {
    return null;
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
  Future<domain.Trip?> getTrip(String tripId) async {
    return null;
  }
}

class _SingleTripRepository implements TripRepository {
  _SingleTripRepository(this.trip);

  final Trip trip;

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
  Future<domain.Trip?> getTrip(String tripId) async {
    return tripId == trip.id ? _toDomainTrip(trip) : null;
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
    expect(find.text('Create Trip'), findsWidgets);
  });

  testWidgets('shows list item when repository returns trips', (tester) async {
    final trip = Trip(
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
    expect(find.text('View itinerary →'), findsOneWidget);
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

    expect(find.text('Trips unavailable'), findsOneWidget);
    expect(find.textContaining('firestore unavailable'), findsOneWidget);
  });
}
