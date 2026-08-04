import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/taxi_saved_ride.dart';
import '../../domain/repositories/taxi_transport_repository.dart';

class FirestoreTaxiTransportRepository implements TaxiTransportRepository {
  FirestoreTaxiTransportRepository({
    required FirebaseFirestore firestore,
    required String userId,
  })  : _firestore = firestore,
        _userId = userId;

  final FirebaseFirestore _firestore;
  final String _userId;

  CollectionReference<Map<String, dynamic>> _transportCollection(String tripId) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('trips')
        .doc(tripId)
        .collection('transport');
  }

  Map<String, dynamic> _toMap(TaxiSavedRide ride) {
    return {
      'id': ride.id,
      'type': 'taxi',
      'tripId': ride.tripId,
      'provider': ride.provider,
      'pickupAddress': ride.pickupAddress,
      'destinationAddress': ride.destinationAddress,
      'pickupLatitude': ride.pickupLatitude,
      'pickupLongitude': ride.pickupLongitude,
      'destinationLatitude': ride.destinationLatitude,
      'destinationLongitude': ride.destinationLongitude,
      'scheduledAt': ride.scheduledAt == null
          ? null
          : Timestamp.fromDate(ride.scheduledAt!),
      'status': ride.status,
      'estimatedFare': ride.estimatedFare,
      'currency': ride.currency,
      'bookingReference': ride.bookingReference,
      'passengers': ride.passengers,
      'luggage': ride.luggage,
      'createdAt': ride.createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(ride.createdAt!),
    };
  }

  TaxiSavedRide _fromMap(Map<String, dynamic> data) {
    DateTime? parseDate(dynamic raw) {
      if (raw is Timestamp) {
        return raw.toDate();
      }
      if (raw is DateTime) {
        return raw;
      }
      return null;
    }

    return TaxiSavedRide(
      id: data['id'] as String,
      tripId: data['tripId'] as String,
      provider: data['provider'] as String? ?? 'Unknown',
      pickupAddress: data['pickupAddress'] as String? ?? '',
      destinationAddress: data['destinationAddress'] as String? ?? '',
      pickupLatitude: (data['pickupLatitude'] as num?)?.toDouble() ?? 0,
      pickupLongitude: (data['pickupLongitude'] as num?)?.toDouble() ?? 0,
      destinationLatitude: (data['destinationLatitude'] as num?)?.toDouble() ?? 0,
      destinationLongitude:
          (data['destinationLongitude'] as num?)?.toDouble() ?? 0,
      scheduledAt: parseDate(data['scheduledAt']),
      status: data['status'] as String? ?? 'planned',
      estimatedFare: (data['estimatedFare'] as num?)?.toDouble() ?? 0,
      currency: data['currency'] as String? ?? 'GBP',
      bookingReference: data['bookingReference'] as String?,
      passengers: (data['passengers'] as num?)?.toInt() ?? 1,
      luggage: (data['luggage'] as num?)?.toInt() ?? 0,
      createdAt: parseDate(data['createdAt']),
    );
  }

  @override
  Stream<List<TaxiSavedRide>> watchRidesForTrip(String tripId) {
    return _transportCollection(tripId)
        .where('type', isEqualTo: 'taxi')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _fromMap(doc.data()))
            .toList(growable: false));
  }

  @override
  Future<void> saveRide({
    required String tripId,
    required TaxiSavedRide ride,
  }) async {
    await _transportCollection(tripId)
        .doc(ride.id)
        .set(_toMap(ride), SetOptions(merge: true));
  }
}
