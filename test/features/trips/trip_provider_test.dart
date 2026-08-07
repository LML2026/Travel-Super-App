import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_repository.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_provider.dart';

class _FakeTripRepository extends TripRepository {
  _FakeTripRepository(this._trips);

  final List<Trip> _trips;
  final List<Trip> createdTrips = <Trip>[];
  final List<Trip> updatedTrips = <Trip>[];
  final List<String> deletedTripIds = <String>[];

  @override
  Stream<List<Trip>> watchAll() {
    return Stream.value(_trips);
  }

  @override
  Future<void> create(Trip trip) async {
    createdTrips.add(trip);
  }

  @override
  Future<void> update(Trip trip) async {
    updatedTrips.add(trip);
  }

  @override
  Future<void> delete(String id) async {
    deletedTripIds.add(id);
  }

  @override
  Future<Trip?> get(String id) async {
    for (final trip in _trips) {
      if (trip.id == id) {
        return trip;
      }
    }
    return null;
  }
}

void main() {
  Trip makeTrip({String id = 'trip-1'}) {
    return Trip(
      id: id,
      destination: 'Paris',
      departureDate: DateTime(2026, 9, 14),
      returnDate: DateTime(2026, 9, 18),
      budget: 1500,
      currency: 'GBP',
      travellers: 2,
      notes: 'Anniversary trip',
    );
  }

  test('tripsProvider reads watch stream from repository', () async {
    final fakeRepo = _FakeTripRepository(<Trip>[makeTrip()]);
    final container = ProviderContainer(
      overrides: [
        tripRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    final trips = await container.read(tripsProvider.future);

    expect(trips, hasLength(1));
    expect(trips.first.destination, 'Paris');
  });

  test('createTripProvider.notifier.create delegates to repository create', () async {
    final fakeRepo = _FakeTripRepository(const <Trip>[]);
    final container = ProviderContainer(
      overrides: [
        tripRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    await container.read(createTripProvider.notifier).create(makeTrip(id: 'new-trip'));

    expect(fakeRepo.createdTrips, hasLength(1));
    expect(fakeRepo.createdTrips.single.id, 'new-trip');
  });

  test('createTripProvider.notifier.update delegates to repository update', () async {
    final fakeRepo = _FakeTripRepository(const <Trip>[]);
    final container = ProviderContainer(
      overrides: [
        tripRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    await container.read(createTripProvider.notifier).update(makeTrip(id: 'edit-trip'));

    expect(fakeRepo.updatedTrips, hasLength(1));
    expect(fakeRepo.updatedTrips.single.id, 'edit-trip');
  });

  test('createTripProvider.notifier.delete delegates to repository delete', () async {
    final fakeRepo = _FakeTripRepository(const <Trip>[]);
    final container = ProviderContainer(
      overrides: [
        tripRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    await container.read(createTripProvider.notifier).delete('trip-delete');

    expect(fakeRepo.deletedTripIds, <String>['trip-delete']);
  });
}
