import '../entities/trip_readiness_item.dart';

abstract interface class TripReminderNotificationService {
  Future<void> schedule(TripReminder reminder);

  Future<void> cancel(String reminderId);
}

class InAppOnlyTripReminderNotificationService
    implements TripReminderNotificationService {
  const InAppOnlyTripReminderNotificationService();

  @override
  Future<void> schedule(TripReminder reminder) async {
    // V1 surfaces due/upcoming reminders in-app. OS notification scheduling
    // can be added here later without changing readiness domain callers.
  }

  @override
  Future<void> cancel(String reminderId) async {}
}
