import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../discovery/domain/travel_discovery_models.dart';
import '../../../trips/presentation/providers/trip_activity_provider.dart';
import '../../data/saved_items_repository.dart';
import '../../domain/saved_item.dart';

final savedItemsRepositoryProvider = Provider<SavedItemsRepository>((ref) {
  return LocalSavedItemsRepository(ref.watch(storageServiceProvider));
});

final savedItemsControllerProvider =
    AsyncNotifierProvider<SavedItemsController, List<SavedItem>>(
  SavedItemsController.new,
);

class SavedItemsController extends AsyncNotifier<List<SavedItem>> {
  @override
  Future<List<SavedItem>> build() {
    return ref.read(savedItemsRepositoryProvider).load();
  }

  Future<void> saveDiscoveryResult(TravelDiscoveryResult result) async {
    final current = state.valueOrNull ?? await future;
    final item = SavedItem(
      id: result.id,
      category: _categoryFromDiscovery(result.category),
      title: result.title,
      subtitle: result.subtitle,
      location: result.location,
      provider: result.provider,
      savedAt: DateTime.now(),
      price: result.price,
      currency: result.currency,
      scheduledAt: result.startTime,
      notes: result.details,
      metadata: {
        ...Map<String, dynamic>.from(result.metadata),
        'duration': result.duration,
        'endTime': result.endTime.toIso8601String(),
      },
    );
    await _replace(item, current);
  }

  Future<void> remove(String id) async {
    final current = state.valueOrNull ?? await future;
    final updated = current.where((item) => item.id != id).toList();
    await ref.read(savedItemsRepositoryProvider).save(updated);
    state = AsyncData(updated);
  }

  Future<void> addToTrip({
    required SavedItem item,
    required String tripId,
  }) async {
    if (!item.isTripActivity) {
      throw StateError(
          'Only activities, restaurants and places can be added to itinerary.');
    }
    await ref.read(tripActivityActionsProvider).addActivity(
          tripId: tripId,
          title: item.title,
          location: item.location,
          notes: item.notes,
          scheduledAt: item.scheduledAt,
          cost: item.price,
          currency: item.currency,
          status: item.category == SavedItemCategory.restaurant
              ? 'Restaurant planned'
              : 'Saved plan',
        );
  }

  Future<void> _replace(SavedItem item, List<SavedItem> current) async {
    final updated = [
      item,
      ...current.where((existing) => existing.id != item.id),
    ];
    await ref.read(savedItemsRepositoryProvider).save(updated);
    state = AsyncData(updated);
  }

  SavedItemCategory _categoryFromDiscovery(DiscoveryCategory category) {
    return switch (category) {
      DiscoveryCategory.flights => SavedItemCategory.flight,
      DiscoveryCategory.hotels => SavedItemCategory.hotel,
      DiscoveryCategory.transport => SavedItemCategory.transport,
      DiscoveryCategory.activities => SavedItemCategory.activity,
      DiscoveryCategory.restaurants => SavedItemCategory.restaurant,
    };
  }
}
