import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/firestore_trip_repository.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../../domain/usecases/create_trip.dart';
import '../../domain/usecases/delete_trip.dart';
import '../../domain/usecases/get_trip.dart';
import '../../domain/usecases/get_trips.dart';
import '../../domain/usecases/update_trip.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return FirestoreTripRepository();
});

final getTripsUseCaseProvider = Provider<GetTrips>((ref) {
  return GetTrips(ref.watch(tripRepositoryProvider));
});

final getTripUseCaseProvider = Provider<GetTrip>((ref) {
  return GetTrip(ref.watch(tripRepositoryProvider));
});

final createTripUseCaseProvider = Provider<CreateTrip>((ref) {
  return CreateTrip(ref.watch(tripRepositoryProvider));
});

final updateTripUseCaseProvider = Provider<UpdateTrip>((ref) {
  return UpdateTrip(ref.watch(tripRepositoryProvider));
});

final deleteTripUseCaseProvider = Provider<DeleteTrip>((ref) {
  return DeleteTrip(ref.watch(tripRepositoryProvider));
});

final tripListProvider = StreamProvider<List<Trip>>((ref) {
  return ref.watch(getTripsUseCaseProvider).call();
});

final selectedTripProvider =
    FutureProvider.family<Trip?, String>((ref, tripId) async {
  return ref.watch(getTripUseCaseProvider).call(tripId);
});

class CreateTripNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Preferred mutation name for creating a new trip.
  Future<void> saveTrip(Trip trip) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(createTripUseCaseProvider).call(trip),
    );
  }

  /// Preferred mutation name for editing an existing trip.
  Future<void> updateTrip(Trip trip) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(updateTripUseCaseProvider).call(trip),
    );
  }

  /// Preferred mutation name for deleting an existing trip.
  Future<void> deleteTrip(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(deleteTripUseCaseProvider).call(id),
    );
  }

  /// Backward-compatible alias.
  Future<void> editTrip(Trip trip) => updateTrip(trip);

  /// Backward-compatible alias.
  Future<void> removeTrip(String id) => deleteTrip(id);
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
  await ref.read(createTripProvider.notifier).updateTrip(trip);
}

Future<void> removeTrip(WidgetRef ref, String tripId) async {
  await ref.read(createTripProvider.notifier).deleteTrip(tripId);
}

Trip duplicateTrip(Trip source) {
  return Trip(
    id: const Uuid().v4(),
    title: '${source.title} (Copy)',
    destination: '${source.destination} (Copy)',
    startDate: source.startDate,
    endDate: source.endDate,
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
