import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../saved_items/presentation/providers/saved_items_provider.dart';
import '../../../trips/presentation/providers/trip_activity_provider.dart';
import '../../../trips/presentation/providers/trip_booking_link_provider.dart';
import '../../../trips/presentation/providers/trip_provider.dart';
import '../../../trips/services/trip_booking_link_service.dart';
import '../../../nearby/services/nearby_places_service.dart';
import '../../../providers/provider_gateway.dart';
import '../../data/travel_discovery_service.dart';
import '../../domain/travel_discovery_models.dart';

final travelDiscoveryServiceProvider = Provider<TravelDiscoveryService>((ref) {
  return ProviderTravelDiscoveryService(
    nearbyService: GoogleNearbyPlacesService(
      gateway: ref.watch(providerGatewayProvider),
    ),
  );
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

  Future<TripBookingLinkResult> linkBookableResult(
    TravelDiscoveryResult result,
  ) async {
    final tripId = state.valueOrNull?.selectedTripId;
    if (tripId == null || tripId.isEmpty) {
      throw StateError('Select a trip before adding this plan.');
    }
    final trip = await ref.read(selectedTripProvider(tripId).future);
    if (trip == null) {
      throw StateError('The selected trip is no longer available.');
    }

    return ref.read(tripBookingLinkActionsProvider).linkDiscoveryResult(
          trip: trip,
          result: result,
        );
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
}
