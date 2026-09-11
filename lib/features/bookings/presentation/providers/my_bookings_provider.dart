import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/booking.dart';
import '../../../../core/repositories/booking_repository.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../trips/presentation/providers/trip_provider.dart';
import '../../../trips/domain/entities/trip.dart';

class MyBooking {
  const MyBooking({required this.booking, required this.trip});

  final Booking booking;
  final Trip trip;
}

final myBookingsProvider = FutureProvider<List<MyBooking>>((ref) async {
  final user = ref.watch(immediateCurrentUserProvider);
  if (user == null) return const [];

  final trips = await ref.watch(tripsProvider.future);
  final repository = ref.watch(bookingRepositoryProvider);
  final grouped = await Future.wait(
    trips.map((trip) async {
      final bookings = await repository.watchBookings(user.uid, trip.id).first;
      return bookings
          .map<MyBooking>((booking) => MyBooking(booking: booking, trip: trip))
          .toList(growable: false);
    }),
  );

  final result = grouped.expand((items) => items).toList(growable: false);
  result.sort((a, b) {
    final aDate = _bookingDate(a.booking);
    final bDate = _bookingDate(b.booking);
    return aDate.compareTo(bDate);
  });
  return result;
});

DateTime _bookingDate(Booking booking) {
  final raw = booking.metadata['startTime'] ??
      booking.metadata['departure'] ??
      booking.metadata['checkIn'];
  return raw is String
      ? DateTime.tryParse(raw) ?? booking.createdAt
      : booking.createdAt;
}
