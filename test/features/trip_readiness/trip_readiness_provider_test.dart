import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/trip_readiness/domain/entities/trip_readiness_item.dart';
import 'package:travel_super_app/features/trip_readiness/domain/repositories/trip_readiness_repository.dart';
import 'package:travel_super_app/features/trip_readiness/presentation/providers/trip_readiness_provider.dart';

void main() {
  group('Trip readiness', () {
    test('summary tracks progress, overdue and due today records', () {
      final now = DateTime(2026, 8, 19, 10);
      final summary = TripReadinessSummary(
        now: now,
        items: [
          TripReadinessItem(
            id: 'passport',
            tripId: 'trip-1',
            title: 'Passport',
            category: ReadinessCategory.passport,
            isCompleted: true,
            createdAt: now,
          ),
          TripReadinessItem(
            id: 'visa',
            tripId: 'trip-1',
            title: 'Visa',
            category: ReadinessCategory.visa,
            dueAt: now.subtract(const Duration(days: 1)),
            createdAt: now,
          ),
          TripReadinessItem(
            id: 'packing',
            tripId: 'trip-1',
            title: 'Packing',
            category: ReadinessCategory.packing,
            dueAt: now,
            createdAt: now,
          ),
        ],
        reminders: [
          TripReminder(
            id: 'reminder-1',
            tripId: 'trip-1',
            title: 'Check in',
            dueAt: now,
            sourceType: 'flight',
            createdAt: now,
          ),
        ],
      );

      expect(summary.progress, closeTo(1 / 3, 0.001));
      expect(summary.completedCount, 1);
      expect(summary.remainingCount, 2);
      expect(summary.overdueItems.single.title, 'Visa');
      expect(summary.dueTodayItems.single.title, 'Packing');
      expect(summary.dueTodayReminders.single.title, 'Check in');
      expect(summary.nextTask?.title, 'Visa');
    });

    test('actions persist checklist items and reminders', () async {
      final repository = _MemoryReadinessRepository();
      final container = ProviderContainer(
        overrides: [
          tripReadinessRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final actions = container.read(tripReadinessActionsProvider);

      await actions.addCustomItem(
        tripId: 'trip-1',
        title: 'Buy medicine',
        category: ReadinessCategory.medication,
        dueAt: DateTime(2026, 8, 20),
        notes: 'Bring prescription.',
      );

      expect(repository.items, hasLength(1));
      expect(repository.items.single.title, 'Buy medicine');
      expect(repository.items.single.notes, 'Bring prescription.');

      await actions.toggleItem(repository.items.single);
      expect(repository.items.single.isCompleted, isTrue);

      await actions.addReminder(
        tripId: 'trip-1',
        title: 'Flight check-in',
        dueAt: DateTime(2026, 8, 21, 9),
        sourceType: 'flight',
        sourceId: 'booking-1',
      );

      expect(repository.reminders, hasLength(1));
      expect(repository.reminders.single.sourceId, 'booking-1');
    });
  });
}

class _MemoryReadinessRepository implements TripReadinessRepository {
  final items = <TripReadinessItem>[];
  final reminders = <TripReminder>[];
  final _itemController = StreamController<List<TripReadinessItem>>.broadcast();
  final _reminderController = StreamController<List<TripReminder>>.broadcast();

  @override
  Future<void> deleteItem({
    required String tripId,
    required String itemId,
  }) async {
    items.removeWhere((item) => item.tripId == tripId && item.id == itemId);
    _itemController.add([...items]);
  }

  @override
  Future<void> deleteReminder({
    required String tripId,
    required String reminderId,
  }) async {
    reminders.removeWhere(
      (reminder) => reminder.tripId == tripId && reminder.id == reminderId,
    );
    _reminderController.add([...reminders]);
  }

  @override
  Future<void> saveItem(TripReadinessItem item) async {
    items.removeWhere(
      (existing) => existing.tripId == item.tripId && existing.id == item.id,
    );
    items.add(item);
    _itemController.add([...items]);
  }

  @override
  Future<void> saveReminder(TripReminder reminder) async {
    reminders.removeWhere(
      (existing) =>
          existing.tripId == reminder.tripId && existing.id == reminder.id,
    );
    reminders.add(reminder);
    _reminderController.add([...reminders]);
  }

  @override
  Stream<List<TripReadinessItem>> watchItems(String tripId) {
    return Stream.value(
      items.where((item) => item.tripId == tripId).toList(),
    );
  }

  @override
  Stream<List<TripReminder>> watchReminders(String tripId) {
    return Stream.value(
      reminders.where((reminder) => reminder.tripId == tripId).toList(),
    );
  }
}
