import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/booking.dart';
import '../../../../core/repositories/booking_repository.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import 'trip_data_scope_provider.dart';

final tripBookingsProvider =
    StreamProvider.family<List<Booking>, String>((ref, tripId) async* {
  final user = ref.watch(immediateCurrentUserProvider);
  if (user == null) {
    yield const [];
    return;
  }

  final scope = await ref.watch(tripDataScopeProvider(tripId).future);
  if (scope == null) {
    yield const [];
    return;
  }

  yield* ref
      .watch(bookingRepositoryProvider)
      .watchBookings(scope.ownerUserId, tripId);
});

final groupedTripBookingsProvider =
    Provider.family<Map<BookingType, List<Booking>>, String>((ref, tripId) {
  final bookings =
      ref.watch(tripBookingsProvider(tripId)).valueOrNull ?? const [];

  final grouped = <BookingType, List<Booking>>{};
  for (final booking in bookings) {
    grouped.putIfAbsent(booking.type, () => []).add(booking);
  }

  return grouped;
});
