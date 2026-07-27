import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../models/trip_model.dart';

class FirestoreTripRepository implements TripRepository {
  FirestoreTripRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('trips');

  @override
  Stream<List<Trip>> watchTrips() {
    return _collection.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => TripModel.fromJson(doc.data()))
          .toList(),
    );
  }

  @override
  Future<List<Trip>> getAll() async {
    final snapshot = await _collection.get();

    return snapshot.docs
        .map((doc) => TripModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<Trip?> get(String id) async {
    final doc = await _collection.doc(id).get();

    if (!doc.exists) return null;

    return TripModel.fromJson(doc.data()!);
  }

  @override
  Future<void> createTrip(Trip trip) async {
    final model = TripModel.fromEntity(trip);

    await _collection.doc(model.id).set(model.toJson());
  }

  @override
  Future<void> updateTrip(Trip trip) async {
    final model = TripModel.fromEntity(trip);

    await _collection.doc(model.id).update(model.toJson());
  }

  @override
  Future<void> deleteTrip(String id) async {
    await _collection.doc(id).delete();
  }
}
