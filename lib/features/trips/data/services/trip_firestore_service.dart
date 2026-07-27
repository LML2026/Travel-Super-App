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
    await _tripCollection.doc(trip.id).set(_toFirestoreMap(trip));
  }

  Future<void> updateTrip(TripModel trip) async {
    await _tripCollection.doc(trip.id).update(_toFirestoreMap(trip));
  }

  Future<void> deleteTrip(String id) async {
    await _tripCollection.doc(id).delete();
  }

  Future<TripModel?> getTrip(String id) async {
    final doc = await _tripCollection.doc(id).get();
    if (!doc.exists) {
      return null;
    }

    return TripModel.fromJson(_fromFirestoreMap(doc.id, doc.data() ?? const {}));
  }

  Future<List<TripModel>> getAllTrips() async {
    final snapshot = await _tripCollection.orderBy('startDate').get();
    return snapshot.docs
        .map((doc) => TripModel.fromJson(_fromFirestoreMap(doc.id, doc.data())))
        .toList();
  }

  Stream<List<TripModel>> watchTrips() {
    return _tripCollection
        .orderBy('startDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TripModel.fromJson(_fromFirestoreMap(doc.id, doc.data())))
              .toList(),
        );
  }

  Map<String, dynamic> _fromFirestoreMap(
    String id,
    Map<String, dynamic> source,
  ) {
    DateTime? toDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }
      if (value is DateTime) {
        return value;
      }
      if (value == null) {
        return null;
      }
      return DateTime.tryParse(value.toString());
    }

    return {
      'id': id,
      'title': source['title'],
      'destination': source['destination'],
      'startDate': toDate(source['startDate']) ?? toDate(source['departureDate']),
      'endDate': toDate(source['endDate']) ?? toDate(source['returnDate']),
      'budget': (source['budget'] as num?)?.toDouble() ?? 0.0,
      'notes': source['notes'],
      'imageUrl': source['imageUrl'],
      'currency': source['currency'] as String? ?? 'GBP',
      'travellers': (source['travellers'] as num?)?.toInt() ?? 1,
      'selectedFlightId': source['selectedFlightId'] ?? source['flightId'],
      'selectedHotelId': source['selectedHotelId'] ?? source['hotelId'],
      'weatherSnapshot': source['weatherSnapshot'] ?? source['weather'],
      'weatherSnapshotCapturedAt': toDate(source['weatherSnapshotCapturedAt']),
      'createdAt': toDate(source['createdAt']),
      'updatedAt': toDate(source['updatedAt']),
      'status': source['status'],
    };
  }

  Map<String, dynamic> _toFirestoreMap(TripModel trip) {
    final json = trip.toJson();
    DateTime? parse(dynamic value) {
      if (value == null) {
        return null;
      }
      if (value is DateTime) {
        return value;
      }
      return DateTime.tryParse(value.toString());
    }

    return {
      'title': json['title'],
      'destination': json['destination'],
      'startDate': Timestamp.fromDate(parse(json['startDate']) ?? trip.startDate),
      'endDate': Timestamp.fromDate(parse(json['endDate']) ?? trip.endDate),
      'departureDate': Timestamp.fromDate(parse(json['departureDate']) ?? trip.startDate),
      'returnDate': Timestamp.fromDate(parse(json['returnDate']) ?? trip.endDate),
      'budget': json['budget'],
      'notes': json['notes'],
      'imageUrl': json['imageUrl'],
      'currency': json['currency'],
      'travellers': json['travellers'],
      'selectedFlightId': json['selectedFlightId'],
      'selectedHotelId': json['selectedHotelId'],
      'weatherSnapshot': json['weatherSnapshot'],
      'weatherSnapshotCapturedAt': parse(json['weatherSnapshotCapturedAt']) == null
          ? null
          : Timestamp.fromDate(parse(json['weatherSnapshotCapturedAt'])!),
      'createdAt': parse(json['createdAt']) == null
          ? null
          : Timestamp.fromDate(parse(json['createdAt'])!),
      'updatedAt': parse(json['updatedAt']) == null
          ? null
          : Timestamp.fromDate(parse(json['updatedAt'])!),
      'status': json['status'],
    };
  }
}
