import '../../flights/models/flight.dart';
import '../../flights/services/flight_firestore_service.dart';
import '../../hotels/models/hotel.dart';
import '../../hotels/services/hotel_firestore_service.dart';
import '../domain/entities/trip.dart';
import '../domain/repositories/trip_repository.dart';

class TripBookingLinkService {
  const TripBookingLinkService({
    required TripRepository tripRepository,
    FlightFirestoreService? flightStore,
    HotelFirestoreService? hotelStore,
  })  : _tripRepository = tripRepository,
        _flightStore = flightStore,
        _hotelStore = hotelStore;

  final TripRepository _tripRepository;
  final FlightFirestoreService? _flightStore;
  final HotelFirestoreService? _hotelStore;

  Future<void> linkFlight({required Trip trip, required Flight flight}) async {
    final store = _flightStore ?? FlightFirestoreService();
    if (!await store.isFlightSaved(flight.id)) {
      await store.saveFlight(
        flightId: flight.id,
        airline: flight.airline,
        airlineLogo: flight.airlineLogo,
        flightNumber: flight.flightNumber,
        origin: flight.origin,
        destination: flight.destination,
        departureAt: flight.departureAt,
        arrivalAt: flight.arrivalAt,
        duration: flight.duration,
        stops: flight.stops,
        amount: flight.amount,
        currency: flight.currency,
        cabinClass: flight.cabinClass,
      );
    }
    if (trip.selectedFlightId == flight.id) return;
    await _tripRepository.updateTrip(
      trip.copyWith(selectedFlightId: flight.id, updatedAt: DateTime.now()),
    );
  }

  Future<void> linkHotel({required Trip trip, required Hotel hotel}) async {
    final store = _hotelStore ?? HotelFirestoreService();
    if (!await store.isHotelSaved(hotel.id)) {
      await store.saveHotel(
        hotelId: hotel.id,
        name: hotel.name,
        city: hotel.city,
        country: hotel.country,
        address: hotel.address,
        currency: hotel.currency,
        rating: hotel.rating,
        pricePerNight: hotel.pricePerNight,
        totalPrice: hotel.totalPrice,
        beds: hotel.beds,
        roomType: hotel.roomType,
        amenities: hotel.amenities,
        freeCancellation: hotel.freeCancellation,
        description: hotel.description,
        image: hotel.image,
        nights: hotel.nights,
      );
    }
    if (trip.selectedHotelId == hotel.id) return;
    await _tripRepository.updateTrip(
      trip.copyWith(selectedHotelId: hotel.id, updatedAt: DateTime.now()),
    );
  }
}
