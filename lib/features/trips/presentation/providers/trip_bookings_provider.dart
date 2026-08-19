import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/booking.dart';
import '../../../../core/repositories/booking_repository.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';

final tripBookingsProvider = StreamProvider.family<List<Booking>, String>((ref, tripId) {
  final user = ref.watch(immediateCurrentUserProvider);
  if (user == null) {
    return Stream.value(const []);
  }

  return ref.watch(bookingRepositoryProvider).watchBookings(user.uid, tripId);
});

final groupedTripBookingsProvider = Provider.family<Map<BookingType, List<Booking>>, String>((ref, tripId) {
  final bookings = ref.watch(tripBookingsProvider(tripId)).valueOrNull ?? const [];
  
  final grouped = <BookingType, List<Booking>>{};
  for (final booking in bookings) {
    grouped.putIfAbsent(booking.type, () => []).add(booking);
  }
  
  return grouped;
});
