import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/trip.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveTrip(Trip trip) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await _db
        .collection('users')
        .doc(uid)
        .collection('trips')
        .add(trip.toMap());
  }

  Stream<List<Trip>> getTrips() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return _db
        .collection('users')
        .doc(uid)
        .collection('trips')
        .orderBy('departure')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Trip.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Future<void> deleteTrip(String tripId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await _db
        .collection('users')
        .doc(uid)
        .collection('trips')
        .doc(tripId)
        .delete();
  }
}
