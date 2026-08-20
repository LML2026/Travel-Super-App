import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../trips/domain/entities/trip.dart';
import '../../../trips/presentation/providers/trip_data_scope_provider.dart';
import '../../../trips/presentation/providers/trip_bookings_provider.dart';
import '../../../trips/presentation/providers/trip_document_provider.dart';
import '../../data/repositories/firestore_trip_readiness_repository.dart';
import '../../domain/entities/trip_readiness_item.dart';
import '../../domain/repositories/trip_readiness_repository.dart';
import '../../domain/services/trip_reminder_notification_service.dart';

typedef TripReadinessRepositoryFactory = TripReadinessRepository Function(
  String userId,
);

final tripReadinessRepositoryFactoryProvider =
    Provider<TripReadinessRepositoryFactory>((ref) {
  return (userId) => FirestoreTripReadinessRepository(
        firestore: FirebaseFirestore.instance,
        userId: userId,
      );
});

final tripReadinessRepositoryProvider =
    Provider<TripReadinessRepository>((ref) {
  final user = ref.watch(immediateCurrentUserProvider);
  if (user == null) {
    return const _UnauthenticatedTripReadinessRepository();
  }
  return ref.read(tripReadinessRepositoryFactoryProvider).call(user.uid);
});

final tripReadinessItemsProvider =
    StreamProvider.family<List<TripReadinessItem>, String>(
        (ref, tripId) async* {
  final user = ref.watch(immediateCurrentUserProvider);
  if (user == null) {
    yield* ref.watch(tripReadinessRepositoryProvider).watchItems(tripId);
    return;
  }
  final scope = await ref.watch(tripDataScopeProvider(tripId).future);
  if (scope == null) {
    yield const <TripReadinessItem>[];
    return;
  }
  yield* ref
      .read(tripReadinessRepositoryFactoryProvider)
      .call(scope.ownerUserId)
      .watchItems(tripId);
});

final tripRemindersProvider =
    StreamProvider.family<List<TripReminder>, String>((ref, tripId) async* {
  final user = ref.watch(immediateCurrentUserProvider);
  if (user == null) {
    yield* ref.watch(tripReadinessRepositoryProvider).watchReminders(tripId);
    return;
  }
  final scope = await ref.watch(tripDataScopeProvider(tripId).future);
  if (scope == null) {
    yield const <TripReminder>[];
    return;
  }
  yield* ref
      .read(tripReadinessRepositoryFactoryProvider)
      .call(scope.ownerUserId)
      .watchReminders(tripId);
});

final tripReadinessSummaryProvider =
    Provider.family<TripReadinessSummary, String>((ref, tripId) {
  return TripReadinessSummary(
    items: ref.watch(tripReadinessItemsProvider(tripId)).valueOrNull ??
        const <TripReadinessItem>[],
    reminders: ref.watch(tripRemindersProvider(tripId)).valueOrNull ??
        const <TripReminder>[],
    now: DateTime.now(),
  );
});

final tripReadinessActionsProvider = Provider<TripReadinessActions>((ref) {
  return TripReadinessActions(
    ref.watch(tripReadinessRepositoryProvider),
    ref.watch(tripReminderNotificationServiceProvider),
    repositoryFactory: ref.read(tripReadinessRepositoryFactoryProvider),
    scopeResolver: (tripId) => ref.read(tripDataScopeProvider(tripId).future),
  );
});

final tripReminderNotificationServiceProvider =
    Provider<TripReminderNotificationService>((ref) {
  return const InAppOnlyTripReminderNotificationService();
});

class TripReadinessActions {
  TripReadinessActions(
    this._repository,
    this._notificationService, {
    TripReadinessRepositoryFactory? repositoryFactory,
    Future<TripDataScope?> Function(String tripId)? scopeResolver,
  })  : _repositoryFactory = repositoryFactory,
        _scopeResolver = scopeResolver;

  final TripReadinessRepository _repository;
  final TripReminderNotificationService _notificationService;
  final TripReadinessRepositoryFactory? _repositoryFactory;
  final Future<TripDataScope?> Function(String tripId)? _scopeResolver;

  Future<TripReadinessRepository> _repositoryFor(String tripId) async {
    try {
      final scope = await _scopeResolver?.call(tripId);
      if (scope != null && _repositoryFactory != null) {
        return _repositoryFactory.call(scope.ownerUserId);
      }
    } catch (_) {
      // Keep injected/local repositories usable without Firebase initialization.
    }
    return _repository;
  }

  Future<void> saveItem(TripReadinessItem item) async {
    return (await _repositoryFor(item.tripId)).saveItem(item);
  }

  Future<void> toggleItem(TripReadinessItem item) async {
    return (await _repositoryFor(item.tripId)).saveItem(
      item.copyWith(
        isCompleted: !item.isCompleted,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> addCustomItem({
    required String tripId,
    required String title,
    required ReadinessCategory category,
    DateTime? dueAt,
    String? notes,
  }) {
    return _repositoryFor(tripId).then((repository) => repository.saveItem(
          TripReadinessItem(
            id: const Uuid().v4(),
            tripId: tripId,
            title: title,
            category: category,
            dueAt: dueAt,
            notes: notes,
            source: 'custom',
            createdAt: DateTime.now(),
          ),
        ));
  }

  Future<void> deleteItem(TripReadinessItem item) async {
    return (await _repositoryFor(item.tripId))
        .deleteItem(tripId: item.tripId, itemId: item.id);
  }

  Future<void> saveReminder(TripReminder reminder) async {
    await (await _repositoryFor(reminder.tripId)).saveReminder(reminder);
    await _notificationService.schedule(reminder);
  }

  Future<void> toggleReminder(TripReminder reminder) async {
    final updated = reminder.copyWith(isCompleted: !reminder.isCompleted);
    await (await _repositoryFor(reminder.tripId)).saveReminder(updated);
    if (updated.isCompleted) {
      await _notificationService.cancel(updated.id);
    } else {
      await _notificationService.schedule(updated);
    }
  }

  Future<void> addReminder({
    required String tripId,
    required String title,
    required DateTime dueAt,
    String? sourceId,
    String sourceType = 'custom',
    String? notes,
  }) {
    return saveReminder(
      TripReminder(
        id: const Uuid().v4(),
        tripId: tripId,
        title: title,
        dueAt: dueAt,
        sourceId: sourceId,
        sourceType: sourceType,
        notes: notes,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteReminder(TripReminder reminder) async {
    await (await _repositoryFor(reminder.tripId)).deleteReminder(
      tripId: reminder.tripId,
      reminderId: reminder.id,
    );
    await _notificationService.cancel(reminder.id);
  }
}

final suggestedReadinessItemsProvider =
    Provider.family<List<TripReadinessItem>, Trip>((ref, trip) {
  final bookings =
      ref.watch(tripBookingsProvider(trip.id)).valueOrNull ?? const [];
  final documents =
      ref.watch(tripDocumentsProvider(trip.id)).valueOrNull ?? const [];
  final suggestions = <TripReadinessItem>[
    _suggest(trip, 'Check passport validity', ReadinessCategory.passport,
        trip.startDate.subtract(const Duration(days: 30))),
    _suggest(trip, 'Confirm visa requirements', ReadinessCategory.visa,
        trip.startDate.subtract(const Duration(days: 21))),
    _suggest(trip, 'Confirm travel insurance', ReadinessCategory.insurance,
        trip.startDate.subtract(const Duration(days: 14))),
    _suggest(trip, 'Prepare travel money', ReadinessCategory.money,
        trip.startDate.subtract(const Duration(days: 7))),
    _suggest(trip, 'Pack essentials', ReadinessCategory.packing,
        trip.startDate.subtract(const Duration(days: 2))),
    _suggest(trip, 'Prepare medication', ReadinessCategory.medication,
        trip.startDate.subtract(const Duration(days: 3))),
  ];

  if (bookings.any((booking) => booking.type.name == 'flight')) {
    suggestions.add(_suggest(
      trip,
      'Complete flight check-in',
      ReadinessCategory.flight,
      trip.startDate.subtract(const Duration(hours: 24)),
    ));
  }
  if (bookings.any((booking) => booking.type.name == 'hotel')) {
    suggestions.add(_suggest(
      trip,
      'Save accommodation confirmation',
      ReadinessCategory.accommodation,
      trip.startDate.subtract(const Duration(days: 3)),
    ));
  }
  if (bookings.any((booking) => booking.type.name == 'transport')) {
    suggestions.add(_suggest(
      trip,
      'Confirm transport pickup details',
      ReadinessCategory.transport,
      trip.startDate.subtract(const Duration(days: 1)),
    ));
  }
  if (documents.isEmpty) {
    suggestions.add(_suggest(
      trip,
      'Add required travel documents',
      ReadinessCategory.documents,
      trip.startDate.subtract(const Duration(days: 7)),
    ));
  }
  return suggestions;
});

TripReadinessItem _suggest(
  Trip trip,
  String title,
  ReadinessCategory category,
  DateTime dueAt,
) {
  return TripReadinessItem(
    id: 'suggested-${category.name}',
    tripId: trip.id,
    title: title,
    category: category,
    dueAt: dueAt,
    source: 'suggested',
    createdAt: DateTime.now(),
  );
}

class _UnauthenticatedTripReadinessRepository
    implements TripReadinessRepository {
  const _UnauthenticatedTripReadinessRepository();

  @override
  Future<void> deleteItem(
      {required String tripId, required String itemId}) async {
    throw StateError('Authentication required to manage readiness.');
  }

  @override
  Future<void> deleteReminder({
    required String tripId,
    required String reminderId,
  }) async {
    throw StateError('Authentication required to manage reminders.');
  }

  @override
  Future<void> saveItem(TripReadinessItem item) async {
    throw StateError('Authentication required to manage readiness.');
  }

  @override
  Future<void> saveReminder(TripReminder reminder) async {
    throw StateError('Authentication required to manage reminders.');
  }

  @override
  Stream<List<TripReadinessItem>> watchItems(String tripId) {
    return Stream.value(const []);
  }

  @override
  Stream<List<TripReminder>> watchReminders(String tripId) {
    return Stream.value(const []);
  }
}
