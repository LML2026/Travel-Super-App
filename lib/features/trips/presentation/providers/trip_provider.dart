import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/firestore_trip_repository.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return FirestoreTripRepository();
});

final tripListProvider = StreamProvider<List<Trip>>((ref) {
  return ref.watch(tripRepositoryProvider).watchTrips();
});

final selectedTripProvider =
    FutureProvider.family<Trip?, String>((ref, tripId) async {
  return ref.watch(tripRepositoryProvider).getTrip(tripId);
});

class CreateTripNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Preferred mutation name for creating a new trip.
  Future<void> saveTrip(Trip trip) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tripRepositoryProvider).createTrip(trip),
    );
  }

  /// Preferred mutation name for editing an existing trip.
  Future<void> editTrip(Trip trip) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tripRepositoryProvider).updateTrip(trip),
    );
  }

  /// Preferred mutation name for deleting an existing trip.
  Future<void> removeTrip(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tripRepositoryProvider).deleteTrip(id),
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

Future<void> saveTrip(WidgetRef ref, Trip trip) async {
  await ref.read(createTripProvider.notifier).saveTrip(trip);
}

Future<void> editTrip(WidgetRef ref, Trip trip) async {
  await ref.read(createTripProvider.notifier).editTrip(trip);
}

Future<void> removeTrip(WidgetRef ref, String tripId) async {
  await ref.read(createTripProvider.notifier).removeTrip(tripId);
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
