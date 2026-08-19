import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/trip_readiness_item.dart';
import '../../domain/repositories/trip_readiness_repository.dart';

class FirestoreTripReadinessRepository implements TripReadinessRepository {
  FirestoreTripReadinessRepository({
    FirebaseFirestore? firestore,
    required String userId,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _userId = userId;

  final FirebaseFirestore _firestore;
  final String _userId;

  CollectionReference<Map<String, dynamic>> _items(String tripId) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('trips')
        .doc(tripId)
        .collection('readinessItems');
  }

  CollectionReference<Map<String, dynamic>> _reminders(String tripId) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('trips')
        .doc(tripId)
        .collection('reminders');
  }

  @override
  Stream<List<TripReadinessItem>> watchItems(String tripId) {
    return _items(tripId).orderBy('createdAt').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => _itemFromMap(doc.data()))
              .toList(growable: false),
        );
  }

  @override
  Stream<List<TripReminder>> watchReminders(String tripId) {
    return _reminders(tripId).orderBy('dueAt').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => _reminderFromMap(doc.data()))
              .toList(growable: false),
        );
  }

  @override
  Future<void> saveItem(TripReadinessItem item) {
    return _items(item.tripId)
        .doc(item.id)
        .set(_itemToMap(item), SetOptions(merge: true));
  }

  @override
  Future<void> deleteItem({required String tripId, required String itemId}) {
    return _items(tripId).doc(itemId).delete();
  }

  @override
  Future<void> saveReminder(TripReminder reminder) {
    return _reminders(reminder.tripId)
        .doc(reminder.id)
        .set(_reminderToMap(reminder), SetOptions(merge: true));
  }

  @override
  Future<void> deleteReminder({
    required String tripId,
    required String reminderId,
  }) {
    return _reminders(tripId).doc(reminderId).delete();
  }

  TripReadinessItem _itemFromMap(Map<String, dynamic> data) {
    return TripReadinessItem(
      id: data['id'] as String,
      tripId: data['tripId'] as String,
      title: data['title'] as String? ?? '',
      category: ReadinessCategory.values.firstWhere(
        (category) => category.name == data['category'],
        orElse: () => ReadinessCategory.custom,
      ),
      isCompleted: data['isCompleted'] as bool? ?? false,
      dueAt: _date(data['dueAt']),
      notes: data['notes'] as String?,
      source: data['source'] as String? ?? 'custom',
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
    );
  }

  Map<String, dynamic> _itemToMap(TripReadinessItem item) {
    return {
      'id': item.id,
      'tripId': item.tripId,
      'title': item.title,
      'category': item.category.name,
      'isCompleted': item.isCompleted,
      'dueAt': item.dueAt == null ? null : Timestamp.fromDate(item.dueAt!),
      'notes': item.notes,
      'source': item.source,
      'createdAt': item.createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(item.createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  TripReminder _reminderFromMap(Map<String, dynamic> data) {
    return TripReminder(
      id: data['id'] as String,
      tripId: data['tripId'] as String,
      title: data['title'] as String? ?? '',
      dueAt: _date(data['dueAt']) ?? DateTime.now(),
      sourceId: data['sourceId'] as String?,
      sourceType: data['sourceType'] as String? ?? 'custom',
      notes: data['notes'] as String?,
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdAt: _date(data['createdAt']),
    );
  }

  Map<String, dynamic> _reminderToMap(TripReminder reminder) {
    return {
      'id': reminder.id,
      'tripId': reminder.tripId,
      'title': reminder.title,
      'dueAt': Timestamp.fromDate(reminder.dueAt),
      'sourceId': reminder.sourceId,
      'sourceType': reminder.sourceType,
      'notes': reminder.notes,
      'isCompleted': reminder.isCompleted,
      'createdAt': reminder.createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(reminder.createdAt!),
    };
  }

  DateTime? _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
