import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/trip_model.dart';

class TripFirestoreService {
  TripFirestoreService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _tripCollection {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User is not signed in.');
    }

    return _firestore.collection('users').doc(user.uid).collection('trips');
  }

  Future<void> createTrip(TripModel trip) async {
    await _tripCollection.doc(trip.id).set(trip.toFirestore());
  }

  Future<void> updateTrip(TripModel trip) async {
    await _tripCollection.doc(trip.id).update(trip.toFirestore());
  }

  Future<void> deleteTrip(String id) async {
    await _tripCollection.doc(id).delete();
  }

  Future<TripModel?> getTrip(String id) async {
    final doc = await _tripCollection.doc(id).get();
    if (!doc.exists) {
      return null;
    }

    return TripModel.fromFirestore(doc);
  }

  Future<List<TripModel>> getAllTrips() async {
    final snapshot = await _tripCollection.orderBy('departureDate').get();
    return snapshot.docs.map(TripModel.fromFirestore).toList();
  }

  Stream<List<TripModel>> watchTrips() {
    return _tripCollection
        .orderBy('departureDate')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(TripModel.fromFirestore).toList());
  }
}
