import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  DateTime _readDate(dynamic raw) {
    if (raw is Timestamp) {
      return raw.toDate();
    }
    if (raw is DateTime) {
      return raw;
    }
    if (raw is String) {
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Future<void> createTrip(Trip trip) async {
    await _tripCollection.doc(trip.id).set({
      'destination': trip.destination,
      'departureDate': Timestamp.fromDate(trip.departureDate),
      'returnDate': Timestamp.fromDate(trip.returnDate),
      'budget': trip.budget,
      'currency': trip.currency,
      'travellers': trip.travellers,
      'notes': trip.notes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTrip(Trip trip) async {
    await _tripCollection.doc(trip.id).update({
      'destination': trip.destination,
      'departureDate': Timestamp.fromDate(trip.departureDate),
      'returnDate': Timestamp.fromDate(trip.returnDate),
      'budget': trip.budget,
      'currency': trip.currency,
      'travellers': trip.travellers,
      'notes': trip.notes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTrip(String id) async {
    await _tripCollection.doc(id).delete();
  }

  Stream<List<Trip>> watchTrips() {
    return _tripCollection
        .orderBy('departureDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return Trip(
          id: doc.id,
          destination: data['destination'] ?? '',
          departureDate:
              (data['departureDate'] as Timestamp).toDate(),
          returnDate:
              (data['returnDate'] as Timestamp).toDate(),
          budget: (data['budget'] as num).toDouble(),
          currency: data['currency'] ?? 'GBP',
          travellers: data['travellers'] ?? 1,
          notes: data['notes'] ?? '',
          createdAt: _readDate(data['createdAt']),
          updatedAt: _readDate(data['updatedAt']),
        );
      }).toList();
    });
  }

  Future<Trip?> getTrip(String id) async {
    final doc = await _tripCollection.doc(id).get();

    if (!doc.exists) return null;

    final data = doc.data()!;

    return Trip(
      id: doc.id,
      destination: data['destination'] ?? '',
      departureDate:
          (data['departureDate'] as Timestamp).toDate(),
      returnDate:
          (data['returnDate'] as Timestamp).toDate(),
      budget: (data['budget'] as num).toDouble(),
      currency: data['currency'] ?? 'GBP',
      travellers: data['travellers'] ?? 1,
      notes: data['notes'] ?? '',
      createdAt: _readDate(data['createdAt']),
      updatedAt: _readDate(data['updatedAt']),
    );
  }

  @override
  Future<void> create(Trip trip) async {
    await createTrip(trip);
  }

  @override
  Future<void> update(Trip trip) async {
    await updateTrip(trip);
  }

  @override
  Future<void> delete(String id) async {
    await deleteTrip(id);
  }

  @override
  Stream<List<Trip>> watchAll() {
    return watchTrips();
  }

  @override
  Future<Trip?> get(String id) async {
    return getTrip(id);
  }
}
