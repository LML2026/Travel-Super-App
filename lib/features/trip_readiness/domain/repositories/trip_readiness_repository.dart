import '../entities/trip_readiness_item.dart';

abstract interface class TripReadinessRepository {
  Stream<List<TripReadinessItem>> watchItems(String tripId);
  Stream<List<TripReminder>> watchReminders(String tripId);

  Future<void> saveItem(TripReadinessItem item);
  Future<void> deleteItem({required String tripId, required String itemId});

  Future<void> saveReminder(TripReminder reminder);
  Future<void> deleteReminder({
    required String tripId,
    required String reminderId,
  });
}
