import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../models/trip_model.dart';

class FirestoreTripRepository implements TripRepository {
  FirestoreTripRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _tripCollection {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('trips');
  }

  @override
  Future<void> createTrip(Trip trip) async {
    final model = TripModel.fromEntity(trip);

    await _tripCollection.doc(trip.id).set(model.toFirestore());
  }

  @override
  Future<void> updateTrip(Trip trip) async {
    final model = TripModel.fromEntity(trip);

    await _tripCollection.doc(trip.id).update(model.toFirestore());
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    await _tripCollection.doc(tripId).delete();
  }

  @override
  Future<Trip?> getTrip(String tripId) async {
    final doc = await _tripCollection.doc(tripId).get();

    if (!doc.exists) {
      return null;
    }

    return TripModel.fromFirestore(doc);
  }

  @override
  Stream<List<Trip>> watchTrips() {
    return _tripCollection
        .orderBy('departureDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TripModel.fromFirestore(doc))
          .toList();
    });
  }
}
