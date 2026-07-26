import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart' as domain;
import 'package:travel_super_app/features/trips/domain/repositories/trip_repository.dart';
import 'package:travel_super_app/features/trips/models/trip.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_provider.dart';

class _OkRepo extends TripRepository {
  _OkRepo(this._trip);

  final domain.Trip _trip;
  bool created = false;

  @override
  Future<void> createTrip(domain.Trip trip) async {
    created = true;
  }

  @override
  Future<void> updateTrip(domain.Trip trip) async {}

  @override
  Future<void> deleteTrip(String tripId) async {}

  @override
  Stream<List<domain.Trip>> watchTrips() {
    return Stream.value(<domain.Trip>[_trip]);
  }

  @override
  Future<domain.Trip?> getTrip(String tripId) async {
    return tripId == _trip.id ? _trip : null;
  }
}

class _FailingRepo extends TripRepository {
  @override
  Future<void> createTrip(domain.Trip trip) async {
    throw Exception('firestore unavailable');
  }

  @override
  Future<void> updateTrip(domain.Trip trip) async {}

  @override
  Future<void> deleteTrip(String tripId) async {}

  @override
  Stream<List<domain.Trip>> watchTrips() {
    return const Stream.empty();
  }

  @override
  Future<domain.Trip?> getTrip(String tripId) async {
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

  domain.Trip toDomain(Trip trip) {
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

  test('CreateTripProvider succeeds and trip appears in list stream', () async {
    final trip = makeTrip();
    final repo = _OkRepo(toDomain(trip));

    final container = ProviderContainer(
      overrides: [
        tripRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(createTripProvider.notifier);
    await notifier.create(trip);

    expect(repo.created, isTrue);

    final trips = await container.read(tripListProvider.future);
    expect(trips, hasLength(1));
    expect(trips.first.destination, 'Paris');
  });

  test('CreateTripProvider exposes error when repository fails', () async {
    final trip = makeTrip();
    final container = ProviderContainer(
      overrides: [
        tripRepositoryProvider.overrideWithValue(_FailingRepo()),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(createTripProvider.notifier);
    await notifier.create(trip);

    final state = container.read(createTripProvider);
    expect(state.hasError, isTrue);
    expect(state.error.toString(), contains('firestore unavailable'));
  });
}
