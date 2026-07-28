import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../trips/domain/entities/trip.dart';
import '../../../trips/presentation/providers/trip_provider.dart';
import '../../data/providers/airport_transfer_provider.dart';
import '../../data/providers/local_taxi_provider.dart';
import '../../data/providers/uber_taxi_provider.dart';
import '../../data/repositories/firestore_taxi_transport_repository.dart';
import '../../domain/entities/taxi_ride_option.dart';
import '../../domain/entities/taxi_ride_request.dart';
import '../../domain/entities/taxi_saved_ride.dart';
import '../../domain/providers/taxi_provider.dart';
import '../../domain/repositories/taxi_transport_repository.dart';

final taxiProvidersProvider = Provider<List<TaxiProvider>>((ref) {
  return const <TaxiProvider>[
    LocalTaxiProvider(),
    AirportTransferProvider(),
  ];
});

final taxiPrimaryProvider = Provider<TaxiProvider>((ref) {
  return UberTaxiProvider();
});

final taxiRideOptionsProvider =
    FutureProvider.family<List<TaxiRideOption>, TaxiRideRequest>(
        (ref, request) async {
  final providers = <TaxiProvider>[
    ref.read(taxiPrimaryProvider),
    ...ref.read(taxiProvidersProvider),
  ];

  final options = <TaxiRideOption>[];
  for (var i = 0; i < providers.length; i++) {
    final provider = providers[i];
    if (!await provider.isAvailable()) {
      continue;
    }

    // Stage 1: static comparison values to support a quick provider hub.
    options.add(
      TaxiRideOption(
        providerName: provider.name,
        estimatedFare: 18 + (i * 6) + (request.passengers * 1.5),
        currency: 'GBP',
        estimatedPickupMinutes: 4 + (i * 3),
        description: request.pickupTime == null
            ? 'Fast pickup from nearby drivers'
            : 'Scheduled pickup for your selected time',
      ),
    );
  }

  options.sort((a, b) => a.estimatedFare.compareTo(b.estimatedFare));
  return options;
});

typedef TaxiTransportRepositoryFactory = TaxiTransportRepository Function(
  String userId,
);

final taxiTransportRepositoryFactoryProvider =
    Provider<TaxiTransportRepositoryFactory>((ref) {
  return (userId) => FirestoreTaxiTransportRepository(
        firestore: FirebaseFirestore.instance,
        userId: userId,
      );
});

final taxiTransportRepositoryProvider = Provider<TaxiTransportRepository>((ref) {
  final user = ref.watch(immediateCurrentUserProvider);
  if (user == null) {
    return const _UnauthenticatedTaxiTransportRepository();
  }

  return ref.read(taxiTransportRepositoryFactoryProvider).call(user.uid);
});

final taxiTripSelectionProvider = StateProvider<String?>((ref) => null);

final taxiTripsProvider = Provider<AsyncValue<List<Trip>>>((ref) {
  return ref.watch(tripsProvider);
});

final taxiSavedRidesForTripProvider =
    StreamProvider.family<List<TaxiSavedRide>, String>((ref, tripId) {
  return ref.watch(taxiTransportRepositoryProvider).watchRidesForTrip(tripId);
});

final taxiSavedRidesForSelectedTripProvider =
    StreamProvider<List<TaxiSavedRide>>((ref) {
  final tripId = ref.watch(taxiTripSelectionProvider);
  if (tripId == null || tripId.isEmpty) {
    return Stream.value(const <TaxiSavedRide>[]);
  }

  return ref.watch(taxiTransportRepositoryProvider).watchRidesForTrip(tripId);
});

final taxiTransportActionsProvider = Provider<TaxiTransportActions>((ref) {
  return TaxiTransportActions(ref.watch(taxiTransportRepositoryProvider));
});

final selectedTaxiProviderNameProvider = StateProvider<String?>((ref) => null);

class TaxiTransportActions {
  TaxiTransportActions(this._repository);

  final TaxiTransportRepository _repository;

  Future<void> saveRideToTrip({
    required String tripId,
    required String provider,
    required TaxiRideRequest request,
    required TaxiRideOption option,
  }) async {
    final ride = TaxiSavedRide(
      id: const Uuid().v4(),
      tripId: tripId,
      provider: provider,
      pickupAddress: request.pickupAddress,
      destinationAddress: request.destinationAddress,
      pickupLatitude: request.pickupLatitude,
      pickupLongitude: request.pickupLongitude,
      destinationLatitude: request.destinationLatitude,
      destinationLongitude: request.destinationLongitude,
      scheduledAt: request.pickupTime,
      status: 'planned',
      estimatedFare: option.estimatedFare,
      currency: option.currency,
      passengers: request.passengers,
      luggage: request.luggage,
      createdAt: DateTime.now(),
    );

    await _repository.saveRide(
      tripId: tripId,
      ride: ride,
    );
  }
}

class _UnauthenticatedTaxiTransportRepository
    implements TaxiTransportRepository {
  const _UnauthenticatedTaxiTransportRepository();

  @override
  Future<void> saveRide({
    required String tripId,
    required TaxiSavedRide ride,
  }) async {
    throw StateError('Authentication required to save taxi rides.');
  }

  @override
  Stream<List<TaxiSavedRide>> watchRidesForTrip(String tripId) {
    return Stream.value(const <TaxiSavedRide>[]);
  }
}
