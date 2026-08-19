import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/models/booking.dart';
import '../../../../core/repositories/booking_repository.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../saved_items/presentation/providers/saved_items_provider.dart';
import '../../../trips/presentation/providers/trip_activity_provider.dart';
import '../../data/travel_discovery_service.dart';
import '../../domain/travel_discovery_models.dart';

final travelDiscoveryServiceProvider = Provider<TravelDiscoveryService>((ref) {
  return const DemoTravelDiscoveryService();
});

final travelDiscoveryBookingSaverProvider =
    Provider<Future<void> Function(Booking)>((ref) {
  return ref.watch(bookingRepositoryProvider).saveBooking;
});

final travelDiscoveryControllerProvider =
    AsyncNotifierProvider<TravelDiscoveryController, TravelDiscoveryState>(
  TravelDiscoveryController.new,
);

class TravelDiscoveryController extends AsyncNotifier<TravelDiscoveryState> {
  @override
  Future<TravelDiscoveryState> build() async {
    final savedItems = await ref.watch(savedItemsControllerProvider.future);
    return TravelDiscoveryState(
      savedIds: savedItems.map((item) => item.id).toSet(),
    );
  }

  Future<void> search(TravelDiscoveryQuery query) async {
    final previous = state.valueOrNull ?? const TravelDiscoveryState();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final results =
          await ref.read(travelDiscoveryServiceProvider).search(query);
      final sorted = [...results]..sort((a, b) => a.price.compareTo(b.price));
      return previous.copyWith(results: sorted);
    });
  }

  void selectTrip(String? tripId) {
    final current = state.valueOrNull ?? const TravelDiscoveryState();
    state = AsyncData(current.copyWith(selectedTripId: tripId));
  }

  Future<void> toggleSave(String resultId) async {
    final current = state.valueOrNull ?? const TravelDiscoveryState();
    TravelDiscoveryResult? result;
    for (final item in current.results) {
      if (item.id == resultId) {
        result = item;
        break;
      }
    }
    final saved = {...current.savedIds};
    if (saved.contains(resultId)) {
      saved.remove(resultId);
      await ref.read(savedItemsControllerProvider.notifier).remove(resultId);
    } else {
      if (result != null) {
        await ref
            .read(savedItemsControllerProvider.notifier)
            .saveDiscoveryResult(result);
      }
      saved.add(resultId);
    }
    state = AsyncData(current.copyWith(savedIds: saved));
  }

  void toggleCompare(String resultId) {
    final current = state.valueOrNull ?? const TravelDiscoveryState();
    final compare = {...current.compareIds};
    compare.contains(resultId)
        ? compare.remove(resultId)
        : compare.add(resultId);
    state = AsyncData(current.copyWith(compareIds: compare));
  }

  Future<Booking> confirmBooking(TravelDiscoveryResult result) async {
    final tripId = state.valueOrNull?.selectedTripId;
    if (tripId == null || tripId.isEmpty) {
      throw StateError('Select a trip before booking.');
    }
    final user = ref.read(immediateCurrentUserProvider);
    if (user == null) {
      throw StateError('Please sign in before booking.');
    }

    final booking =
        _bookingFromResult(result, tripId: tripId, userId: user.uid);
    await ref.read(travelDiscoveryBookingSaverProvider).call(booking);
    return booking;
  }

  Future<void> addToTrip(TravelDiscoveryResult result) async {
    final tripId = state.valueOrNull?.selectedTripId;
    if (tripId == null || tripId.isEmpty) {
      throw StateError('Select a trip before adding to itinerary.');
    }

    await ref.read(tripActivityActionsProvider).addActivity(
          tripId: tripId,
          title: result.title,
          location: result.location,
          notes:
              '${result.details} Provider: ${result.provider}. Demo result, not live availability.',
          scheduledAt: result.startTime,
          cost: result.price,
          currency: result.currency,
          status: result.category == DiscoveryCategory.restaurants
              ? 'Restaurant planned'
              : 'Activity planned',
        );
  }

  Booking _bookingFromResult(
    TravelDiscoveryResult result, {
    required String tripId,
    required String userId,
  }) {
    final id = 'DISC-${const Uuid().v4()}';
    final metadata = <String, dynamic>{
      ...Map<String, dynamic>.from(result.metadata),
      'title': result.title,
      'provider': result.provider,
      'location': result.location,
      'startTime': result.startTime.toIso8601String(),
      'endTime': result.endTime.toIso8601String(),
      'duration': result.duration,
    };

    final booking = switch (result.category) {
      DiscoveryCategory.flights => Booking.flight(
          id: id,
          tripId: tripId,
          userId: userId,
          amount: result.price,
          currency: result.currency,
          metadata: metadata,
        ),
      DiscoveryCategory.hotels => Booking.hotel(
          id: id,
          tripId: tripId,
          userId: userId,
          amount: result.price,
          currency: result.currency,
          metadata: metadata,
        ),
      DiscoveryCategory.transport => Booking.transport(
          id: id,
          tripId: tripId,
          userId: userId,
          amount: result.price,
          currency: result.currency,
          metadata: metadata,
        ),
      _ => throw StateError('This result cannot be booked.'),
    };

    return booking.copyWith(status: BookingStatus.confirmed);
  }
}
