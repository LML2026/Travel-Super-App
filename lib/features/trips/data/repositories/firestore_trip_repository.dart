import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/trip_model.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';

class FirestoreTripRepository implements TripRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  FirestoreTripRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _tripCollection {
    final uid = auth.currentUser!.uid;

    return firestore
        .collection('users')
        .doc(uid)
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
    await _tripCollection.doc(trip.id).set(model.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    await _tripCollection.doc(tripId).delete();
  }

  @override
  Stream<List<Trip>> watchTrips() {
    return _tripCollection
        .orderBy('departureDate')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(TripModel.fromFirestore).toList());
  }

  @override
  Future<Trip?> getTrip(String tripId) async {
    final doc = await _tripCollection.doc(tripId).get();

    if (!doc.exists) return null;

    return TripModel.fromFirestore(doc);
  }

}
