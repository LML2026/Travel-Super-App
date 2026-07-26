import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/trip_firestore_datasource.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';

final tripFirestoreDatasourceProvider = Provider<TripFirestoreDatasource>((ref) {
  return TripFirestoreDatasource();
});

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepositoryImpl(
    datasource: ref.watch(tripFirestoreDatasourceProvider),
  );
});

final tripListProvider = StreamProvider<List<Trip>>((ref) {
  return ref.watch(tripRepositoryProvider).watchAll();
});

final selectedTripProvider = FutureProvider.family<Trip?, String>((ref, tripId) {
  return ref.watch(tripRepositoryProvider).get(tripId);
});

class CreateTripNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> create(Trip trip) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tripRepositoryProvider).create(trip),
    );
  }

  Future<void> update(Trip trip) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tripRepositoryProvider).update(trip),
    );
  }

  Future<void> delete(String id) async {
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
  await ref.read(createTripProvider.notifier).create(trip);
}

Future<void> updateTrip(WidgetRef ref, Trip trip) async {
  await ref.read(createTripProvider.notifier).update(trip);
}

Future<void> deleteTrip(WidgetRef ref, String tripId) async {
  await ref.read(createTripProvider.notifier).delete(tripId);
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
  );
}
