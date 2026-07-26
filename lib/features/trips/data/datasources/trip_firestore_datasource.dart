import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/trip_model.dart';

class TripFirestoreDatasource {
  TripFirestoreDatasource({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw Exception('User not authenticated');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _trips {
    return _firestore.collection('users').doc(_uid).collection('trips');
  }

  Future<void> createTrip(TripModel trip) {
    return _trips.doc(trip.id).set(trip.toFirestore());
  }

  Future<void> updateTrip(TripModel trip) {
    return _trips.doc(trip.id).set(trip.toFirestore(), SetOptions(merge: true));
  }

  Future<void> deleteTrip(String id) {
    return _trips.doc(id).delete();
  }

  Stream<List<TripModel>> watchTrips() {
    return _trips.orderBy('departureDate').snapshots().map(
          (snapshot) => snapshot.docs.map(TripModel.fromFirestore).toList(),
        );
  }

  Future<TripModel?> getTrip(String id) async {
    final doc = await _trips.doc(id).get();
    if (!doc.exists) {
      return null;
    }
    return TripModel.fromFirestore(doc);
  }
}
