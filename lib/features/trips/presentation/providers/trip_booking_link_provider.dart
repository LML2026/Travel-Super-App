import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/trip.dart';
import '../../services/trip_booking_link_service.dart';
import '../../../flights/models/flight.dart';
import '../../../hotels/models/hotel.dart';
import 'trip_provider.dart';

final tripBookingLinkServiceProvider = Provider<TripBookingLinkService>((ref) {
  return TripBookingLinkService(
    tripRepository: ref.watch(tripRepositoryProvider),
  );
});

final tripBookingLinkActionsProvider = Provider<TripBookingLinkActions>((ref) {
  return TripBookingLinkActions(ref.watch(tripBookingLinkServiceProvider));
});

class TripBookingLinkActions {
  const TripBookingLinkActions(this._service);

  final TripBookingLinkService _service;

  Future<void> linkFlight({required Trip trip, required Flight flight}) {
    return _service.linkFlight(trip: trip, flight: flight);
  }

  Future<void> linkHotel({required Trip trip, required Hotel hotel}) {
    return _service.linkHotel(trip: trip, hotel: hotel);
  }
}
