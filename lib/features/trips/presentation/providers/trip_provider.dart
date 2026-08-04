import 'package:cloud_firestore/cloud_firestore.dart';
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
  return FirestoreTripRepository(FirebaseFirestore.instance);
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

final tripsProvider = StreamProvider<List<Trip>>((ref) {
  return ref.watch(getTripsUseCaseProvider).call();
});

final selectedTripProvider = FutureProvider.family<Trip?, String>((
  ref,
  tripId,
) async {
  return ref.watch(getTripUseCaseProvider).call(tripId);
});

final tripListProvider = tripsProvider;

class CreateTripNotifier extends AsyncNotifier<void> {
  late final CreateTrip _createTrip;
  late final UpdateTrip _updateTrip;
  late final DeleteTrip _deleteTrip;

  @override
  Future<void> build() async {
    _createTrip = ref.read(createTripUseCaseProvider);
    _updateTrip = ref.read(updateTripUseCaseProvider);
    _deleteTrip = ref.read(deleteTripUseCaseProvider);
  }

  Future<void> createTrip(Trip trip) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _createTrip.call(trip);
    });
  }

  Future<void> updateTrip(Trip trip) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _updateTrip.call(trip);
    });
  }

  Future<void> deleteTrip(String id) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _deleteTrip.call(id);
    });
  }
}

final createTripProvider = AsyncNotifierProvider<CreateTripNotifier, void>(
  CreateTripNotifier.new,
);

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
