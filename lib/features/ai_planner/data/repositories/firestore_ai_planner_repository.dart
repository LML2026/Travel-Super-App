import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/ai_planner_models.dart';
import '../../domain/ai_planner_repository.dart';

class FirestoreAiPlannerRepository
    implements AiPlannerRepository, AiPlannerPreferencesRepository {
  FirestoreAiPlannerRepository({
    FirebaseFirestore? firestore,
    required String userId,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _userId = userId;

  final FirebaseFirestore _firestore;
  final String _userId;

  CollectionReference<Map<String, dynamic>> _collection(String tripId) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('trips')
        .doc(tripId)
        .collection('aiPlannerPlans');
  }

  DocumentReference<Map<String, dynamic>> _preferencesDocument(String tripId) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('trips')
        .doc(tripId)
        .collection('aiPlannerPreferences')
        .doc('current');
  }

  @override
  Stream<List<AiPlannerPlan>> watchPlanHistory(String tripId) {
    return _collection(tripId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _fromMap(doc.data()))
              .toList(growable: false),
        );
  }

  @override
  Future<List<AiPlannerPlan>> getPlanHistory(String tripId) async {
    final snapshot =
        await _collection(tripId).orderBy('updatedAt', descending: true).get();
    return snapshot.docs
        .map((doc) => _fromMap(doc.data()))
        .toList(growable: false);
  }

  @override
  Future<void> savePlan(AiPlannerPlan plan) async {
    await _collection(plan.tripId)
        .doc(plan.id)
        .set(_toMap(plan), SetOptions(merge: true));
  }

  @override
  Future<AiPlannerPreferences?> getPreferences(String tripId) async {
    final snapshot = await _preferencesDocument(tripId).get();
    final data = snapshot.data();
    if (data == null) return null;
    return AiPlannerPreferences.fromJson(data);
  }

  @override
  Future<void> savePreferences(
    String tripId,
    AiPlannerPreferences preferences,
  ) {
    return _preferencesDocument(tripId).set({
      ...preferences.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  AiPlannerPlan _fromMap(Map<String, dynamic> data) {
    return AiPlannerPlan.fromJson({
      ...data,
      'generatedAt': _dateString(data['generatedAt']),
      'updatedAt': _dateString(data['updatedAt']),
    });
  }

  Map<String, dynamic> _toMap(AiPlannerPlan plan) {
    return {
      ...plan.toJson(),
      'generatedAt': Timestamp.fromDate(plan.generatedAt),
      'updatedAt': Timestamp.fromDate(plan.updatedAt ?? plan.generatedAt),
    };
  }

  String? _dateString(Object? value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    return value?.toString();
  }
}
