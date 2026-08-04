import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/trip_activity.dart';
import '../../domain/repositories/trip_activity_repository.dart';

class FirestoreTripActivityRepository implements TripActivityRepository {
  FirestoreTripActivityRepository({
    FirebaseFirestore? firestore,
    required String userId,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _userId = userId;

  final FirebaseFirestore _firestore;
  final String _userId;

  CollectionReference<Map<String, dynamic>> _collection(String tripId) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('trips')
        .doc(tripId)
        .collection('activities');
  }

  TripActivity _fromMap(Map<String, dynamic> data) {
    final createdAtRaw = data['createdAt'];
    DateTime? createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    }

    final scheduledAtRaw = data['scheduledAt'];
    DateTime? scheduledAt;
    if (scheduledAtRaw is Timestamp) {
      scheduledAt = scheduledAtRaw.toDate();
    } else if (scheduledAtRaw is DateTime) {
      scheduledAt = scheduledAtRaw;
    }

    return TripActivity(
      id: data['id'] as String,
      tripId: data['tripId'] as String,
      title: data['title'] as String? ?? '',
      location: data['location'] as String?,
      notes: data['notes'] as String?,
      scheduledAt: scheduledAt,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> _toMap(TripActivity activity) {
    return {
      'id': activity.id,
      'tripId': activity.tripId,
      'title': activity.title,
      'location': activity.location,
      'notes': activity.notes,
      'scheduledAt': activity.scheduledAt == null
          ? null
          : Timestamp.fromDate(activity.scheduledAt!),
      'createdAt': activity.createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(activity.createdAt!),
    };
  }

  @override
  Stream<List<TripActivity>> watchActivities(String tripId) {
    return _collection(tripId)
        .orderBy('scheduledAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _fromMap(doc.data()))
              .toList(growable: false),
        );
  }

  @override
  Future<void> addActivity(TripActivity activity) async {
    await _collection(
      activity.tripId,
    ).doc(activity.id).set(_toMap(activity), SetOptions(merge: true));
  }

  @override
  Future<void> deleteActivity({
    required String tripId,
    required String activityId,
  }) async {
    await _collection(tripId).doc(activityId).delete();
  }
}
