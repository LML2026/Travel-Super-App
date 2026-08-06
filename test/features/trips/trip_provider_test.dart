import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart'
    as domain;
import 'package:travel_super_app/features/trips/domain/repositories/trip_repository.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart'
    as model;
import 'package:travel_super_app/features/trips/presentation/providers/trip_provider.dart';

class _FakeTripRepository extends TripRepository {
  _FakeTripRepository(this._trips);

  final List<domain.Trip> _trips;
  final List<domain.Trip> createdTrips = <domain.Trip>[];
  final List<domain.Trip> updatedTrips = <domain.Trip>[];
  final List<String> deletedTripIds = <String>[];

  @override
  Stream<List<domain.Trip>> watchTrips() {
    return Stream.value(_trips);
  }

  @override
  Future<void> createTrip(domain.Trip trip) async {
    createdTrips.add(trip);
  }

  @override
  Future<void> updateTrip(domain.Trip trip) async {
    updatedTrips.add(trip);
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    deletedTripIds.add(tripId);
  }

  @override
  Future<domain.Trip?> get(String tripId) async {
    for (final trip in _trips) {
      if (trip.id == tripId) {
        return trip;
      }
    }
    return null;
  }

  @override
  Future<List<domain.Trip>> getAll() async {
    return _trips;
  }
}

void main() {
  model.Trip makeModelTrip({String id = 'trip-1'}) {
    return model.Trip(
      id: id,
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

  domain.Trip makeDomainTrip({String id = 'trip-1'}) {
    return domain.Trip(
      id: id,
      title: 'Paris Getaway',
      destination: 'Paris',
      startDate: DateTime(2026, 9, 14),
      endDate: DateTime(2026, 9, 18),
      budget: 1500,
      currency: 'GBP',
      travellers: 2,
      notes: 'Anniversary trip',
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 1),
    );
  }

  test('tripsProvider reads watch stream from repository', () async {
    final fakeRepo = _FakeTripRepository(<domain.Trip>[makeDomainTrip()]);
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

  test('saveTrip provider delegates to repository create', () async {
    final fakeRepo = _FakeTripRepository(const <domain.Trip>[]);
    final container = ProviderContainer(
      overrides: [
        tripRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(createTripProvider.notifier);
    await notifier.createTrip(makeModelTrip(id: 'new-trip'));

    expect(fakeRepo.createdTrips, hasLength(1));
    expect(fakeRepo.createdTrips.single.id, 'new-trip');
  });

  test('editTrip provider delegates to repository update', () async {
    final fakeRepo = _FakeTripRepository(const <domain.Trip>[]);
    final container = ProviderContainer(
      overrides: [
        tripRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(createTripProvider.notifier);
    await notifier.updateTrip(makeModelTrip(id: 'edit-trip'));

    expect(fakeRepo.updatedTrips, hasLength(1));
    expect(fakeRepo.updatedTrips.single.id, 'edit-trip');
  });

  test('removeTrip provider delegates to repository delete', () async {
    final fakeRepo = _FakeTripRepository(const <domain.Trip>[]);
    final container = ProviderContainer(
      overrides: [
        tripRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(createTripProvider.notifier);
    await notifier.deleteTrip('trip-delete');

    expect(fakeRepo.deletedTripIds, <String>['trip-delete']);
  });
}
