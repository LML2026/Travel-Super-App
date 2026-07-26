import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/trip_firestore_datasource.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../domain/entities/trip.dart' as domain;
import '../../domain/repositories/trip_repository.dart';
import '../../models/trip.dart';

final tripFirestoreDatasourceProvider = Provider<TripFirestoreDatasource>((ref) {
  return TripFirestoreDatasource();
});

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepositoryImpl(
    datasource: ref.watch(tripFirestoreDatasourceProvider),
  );
});

final tripListProvider = StreamProvider<List<Trip>>((ref) {
  return ref.watch(tripRepositoryProvider).watchAll().map(
        (trips) => trips.map(_toPresentationTrip).toList(),
      );
});

final selectedTripProvider = FutureProvider.family<Trip?, String>((ref, tripId) async {
  final trip = await ref.watch(tripRepositoryProvider).get(tripId);
  if (trip == null) {
    return null;
  }
  return _toPresentationTrip(trip);
});

class CreateTripNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> create(Trip trip) async {
    await createTrip(trip);
  }

  Future<void> createTrip(Trip trip) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tripRepositoryProvider).create(_toDomainTrip(trip)),
    );
  }

  Future<void> updateTrip(Trip trip) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tripRepositoryProvider).update(_toDomainTrip(trip)),
    );
  }

  Future<void> deleteTrip(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tripRepositoryProvider).delete(id),
    );
  }
}

final createTripProvider =
    AutoDisposeAsyncNotifierProvider<CreateTripNotifier, void>(
  CreateTripNotifier.new,
);

// Alias to keep parity with requested naming style.
final CreateTripProvider = createTripProvider;

// Backward-compatible provider name used by existing screens/tests.
final tripsProvider = tripListProvider;

Future<void> createTrip(WidgetRef ref, Trip trip) async {
  await ref.read(createTripProvider.notifier).createTrip(trip);
}

Future<void> updateTrip(WidgetRef ref, Trip trip) async {
  await ref.read(createTripProvider.notifier).updateTrip(trip);
}

Future<void> deleteTrip(WidgetRef ref, String tripId) async {
  await ref.read(createTripProvider.notifier).deleteTrip(tripId);
}

Trip duplicateTrip(Trip source) {
  return Trip(
    id: const Uuid().v4(),
    destination: '${source.destination} (Copy)',
    departureDate: source.departureDate,
    returnDate: source.returnDate,
    budget: source.budget,
    currency: source.currency,
    travellers: source.travellers,
    notes: source.notes,
    createdAt: source.createdAt,
    selectedFlightId: source.selectedFlightId,
    selectedHotelId: source.selectedHotelId,
    weatherSnapshot: source.weatherSnapshot,
    weatherSnapshotCapturedAt: source.weatherSnapshotCapturedAt,
    status: source.status,
  );
}

Trip _toPresentationTrip(domain.Trip trip) {
  return Trip(
    id: trip.id,
    destination: trip.destination,
    departureDate: trip.departureDate,
    returnDate: trip.returnDate,
    budget: trip.budget,
    currency: trip.currency,
    travellers: trip.travellers,
    notes: trip.notes,
    createdAt: DateTime.now(),
  );
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
  );
}
