import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/trip.dart';

class TripService {
  TripService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _userId => _auth.currentUser?.uid;

  Future<void> createTrip(Trip trip) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('trips')
        .doc(trip.id)
        .set(trip.toCreateMap());
  }

  Stream<QuerySnapshot> getTrips() {
    final uid = _auth.currentUser!.uid;

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .orderBy('departureDate')
        .snapshots();
  }

  Stream<List<Trip>> watchTrips() {
    final userId = _userId;
    if (userId == null) {
      return Stream.value(const []);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('trips')
        .orderBy('departureDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Trip.fromFirestore(doc))
            .toList());
  }

  Future<void> saveTrip(Trip trip) async {
    await createTrip(trip);
  }

  Future<void> updateTrip(Trip trip) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('trips')
        .doc(trip.id)
        .set(trip.toUpdateMap(), SetOptions(merge: true));
  }

  Future<void> deleteTrip(String tripId) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('trips')
        .doc(tripId)
        .delete();
  }
}
