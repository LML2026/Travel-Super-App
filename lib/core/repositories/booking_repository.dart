import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../utils/app_logger.dart';

class BookingRepository {
  final FirebaseFirestore _firestore;

  BookingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> saveBooking(Booking booking) async {
    try {
      appLogger.i('BookingRepository: saving booking ${booking.id}');

      final docRef = _firestore
          .collection('users')
          .doc(booking.userId)
          .collection('trips')
          .doc(booking.tripId)
          .collection('bookings')
          .doc(booking.id);

      await docRef.set(booking.toJson());
      appLogger.i('BookingRepository: booking saved');
    } catch (e, st) {
      appLogger.e('BookingRepository: save failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Stream<List<Booking>> watchBookings(String userId, String tripId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('trips')
        .doc(tripId)
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromJson(doc.data()))
            .toList());
  }
}

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository();
});
