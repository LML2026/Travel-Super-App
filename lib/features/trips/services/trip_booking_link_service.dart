import '../../discovery/domain/travel_discovery_models.dart';
import '../../flights/models/flight.dart';
import '../../flights/services/flight_firestore_service.dart';
import '../../hotels/models/hotel.dart';
import '../../hotels/services/hotel_firestore_service.dart';
import '../../taxi/domain/entities/taxi_saved_ride.dart';
import '../../taxi/domain/repositories/taxi_transport_repository.dart';
import '../domain/entities/trip.dart';
import '../domain/repositories/trip_repository.dart';

enum TripBookingLinkStatus { linked, alreadyLinked, failed }

class TripBookingLinkResult {
  const TripBookingLinkResult._({
    required this.status,
    this.itemId,
    this.message,
  });

  const TripBookingLinkResult.linked({String? itemId})
      : this._(status: TripBookingLinkStatus.linked, itemId: itemId);

  const TripBookingLinkResult.alreadyLinked({String? itemId})
      : this._(status: TripBookingLinkStatus.alreadyLinked, itemId: itemId);

  const TripBookingLinkResult.failed(String message)
      : this._(status: TripBookingLinkStatus.failed, message: message);

  final TripBookingLinkStatus status;
  final String? itemId;
  final String? message;

  bool get isSuccess => status != TripBookingLinkStatus.failed;
  bool get wasAlreadyLinked => status == TripBookingLinkStatus.alreadyLinked;
}

class TripBookingLinkService {
  TripBookingLinkService({
    TripRepository? tripRepository,
    FlightFirestoreService? flightStore,
    HotelFirestoreService? hotelStore,
    TaxiTransportRepository? transportStore,
    Future<bool> Function(String flightId)? flightSavedLookup,
    Future<void> Function(Flight flight)? flightSaver,
    Future<bool> Function(String hotelId)? hotelSavedLookup,
    Future<void> Function(Hotel hotel)? hotelSaver,
  })  : _tripRepository = tripRepository,
        _flightSavedLookup = flightSavedLookup ??
            ((flightId) => (flightStore ?? FlightFirestoreService())
                .isFlightSaved(flightId)),
        _flightSaver = flightSaver ??
            ((flight) => (flightStore ?? FlightFirestoreService()).saveFlight(
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
                  source: flight.dataSource.name,
                )),
        _hotelSavedLookup = hotelSavedLookup ??
            ((hotelId) =>
                (hotelStore ?? HotelFirestoreService()).isHotelSaved(hotelId)),
        _hotelSaver = hotelSaver ??
            ((hotel) => (hotelStore ?? HotelFirestoreService()).saveHotel(
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
                  source: hotel.dataSource.name,
                )),
        _transportStore = transportStore;

  final TripRepository? _tripRepository;
  final Future<bool> Function(String flightId) _flightSavedLookup;
  final Future<void> Function(Flight flight) _flightSaver;
  final Future<bool> Function(String hotelId) _hotelSavedLookup;
  final Future<void> Function(Hotel hotel) _hotelSaver;
  final TaxiTransportRepository? _transportStore;

  Future<TripBookingLinkResult> linkFlight({
    required Trip trip,
    required Flight flight,
  }) async {
    if (trip.selectedFlightId == flight.id) {
      return TripBookingLinkResult.alreadyLinked(itemId: flight.id);
    }

    try {
      if (!await _flightSavedLookup(flight.id)) {
        await _flightSaver(flight);
      }
      await _tripRepositoryOrThrow.updateTrip(
        trip.copyWith(selectedFlightId: flight.id, updatedAt: DateTime.now()),
      );
      return TripBookingLinkResult.linked(itemId: flight.id);
    } catch (_) {
      return const TripBookingLinkResult.failed(
        'We could not link this flight. Please try again.',
      );
    }
  }

  Future<TripBookingLinkResult> linkHotel({
    required Trip trip,
    required Hotel hotel,
  }) async {
    if (trip.selectedHotelId == hotel.id) {
      return TripBookingLinkResult.alreadyLinked(itemId: hotel.id);
    }

    try {
      if (!await _hotelSavedLookup(hotel.id)) {
        await _hotelSaver(hotel);
      }
      await _tripRepositoryOrThrow.updateTrip(
        trip.copyWith(selectedHotelId: hotel.id, updatedAt: DateTime.now()),
      );
      return TripBookingLinkResult.linked(itemId: hotel.id);
    } catch (_) {
      return const TripBookingLinkResult.failed(
        'We could not link this hotel. Please try again.',
      );
    }
  }

  Future<TripBookingLinkResult> linkTransport({
    required TaxiSavedRide ride,
  }) async {
    final store = _transportStore;
    if (store == null) {
      return const TripBookingLinkResult.failed(
        'Transport linking is unavailable right now.',
      );
    }

    try {
      final existing = await store.watchRidesForTrip(ride.tripId).first;
      TaxiSavedRide? duplicate;
      for (final candidate in existing) {
        if (_sameRide(candidate, ride)) {
          duplicate = candidate;
          break;
        }
      }
      if (duplicate != null) {
        return TripBookingLinkResult.alreadyLinked(itemId: duplicate.id);
      }
      await store.saveRide(tripId: ride.tripId, ride: ride);
      return TripBookingLinkResult.linked(itemId: ride.id);
    } catch (_) {
      return const TripBookingLinkResult.failed(
        'We could not link this transport. Please try again.',
      );
    }
  }

  Future<TripBookingLinkResult> linkDiscoveryResult({
    required Trip trip,
    required TravelDiscoveryResult result,
  }) async {
    switch (result.category) {
      case DiscoveryCategory.flights:
        return linkFlight(trip: trip, flight: _flightFromDiscovery(result));
      case DiscoveryCategory.hotels:
        return linkHotel(trip: trip, hotel: _hotelFromDiscovery(result));
      case DiscoveryCategory.transport:
        return linkTransport(ride: _rideFromDiscovery(trip, result));
      case DiscoveryCategory.activities:
      case DiscoveryCategory.restaurants:
        return const TripBookingLinkResult.failed(
          'Activities and restaurants use the trip activity path.',
        );
    }
  }

  TripRepository get _tripRepositoryOrThrow =>
      _tripRepository ?? (throw StateError('Trip repository is required.'));

  bool _sameRide(TaxiSavedRide existing, TaxiSavedRide candidate) {
    return existing.provider == candidate.provider &&
        existing.pickupAddress == candidate.pickupAddress &&
        existing.destinationAddress == candidate.destinationAddress &&
        existing.scheduledAt == candidate.scheduledAt;
  }

  Flight _flightFromDiscovery(TravelDiscoveryResult result) {
    final metadata = result.metadata;
    return Flight(
      id: result.id,
      airline: _string(metadata['airline'], fallback: result.provider),
      airlineLogo: _string(metadata['airlineLogo']),
      flightNumber: _string(metadata['flightNumber'], fallback: result.id),
      origin: _string(metadata['departure'], fallback: result.location),
      destination: _string(metadata['arrival'], fallback: result.location),
      departureAt: result.startTime.toIso8601String(),
      arrivalAt: result.endTime.toIso8601String(),
      duration: result.duration,
      stops: _number(metadata['stops']).toInt(),
      amount: result.price,
      currency: result.currency,
      cabinClass: _string(metadata['cabinClass'], fallback: 'economy'),
      dataSource: _flightSource(result.provider),
    );
  }

  Hotel _hotelFromDiscovery(TravelDiscoveryResult result) {
    final metadata = result.metadata;
    final nights =
        result.endTime.difference(result.startTime).inDays.clamp(1, 30).toInt();
    return Hotel(
      id: result.id,
      name: _string(metadata['hotelName'], fallback: result.title),
      image: _string(metadata['image']),
      rating: result.rating,
      address: result.location,
      city: _string(metadata['city'], fallback: result.location),
      price: nights == 0 ? result.price : result.price / nights,
      currency: result.currency,
      amenities: _list(metadata['amenities']),
      totalPrice: result.price,
      roomType: _string(metadata['roomType'], fallback: 'Standard Room'),
      nights: nights,
      dataSource: _hotelSource(result.provider),
    );
  }

  TaxiSavedRide _rideFromDiscovery(
    Trip trip,
    TravelDiscoveryResult result,
  ) {
    final metadata = result.metadata;
    final ride = TaxiSavedRide(
      id: result.id,
      tripId: trip.id,
      provider: result.provider,
      pickupAddress: _string(metadata['pickup'], fallback: result.location),
      destinationAddress:
          _string(metadata['destination'], fallback: trip.destination),
      pickupLatitude: _number(metadata['pickupLatitude']),
      pickupLongitude: _number(metadata['pickupLongitude']),
      destinationLatitude: _number(metadata['destinationLatitude']),
      destinationLongitude: _number(metadata['destinationLongitude']),
      scheduledAt: result.startTime,
      status: 'planned',
      estimatedFare: result.price,
      currency: result.currency,
      passengers: trip.travellers,
      luggage: 0,
      createdAt: DateTime.now(),
    );
    return ride;
  }

  FlightDataSource _flightSource(String provider) {
    final value = provider.toLowerCase();
    if (value.contains('duffel')) return FlightDataSource.duffelTest;
    if (value.contains('demo')) return FlightDataSource.demo;
    return FlightDataSource.backend;
  }

  HotelDataSource _hotelSource(String provider) {
    final value = provider.toLowerCase();
    if (value.contains('duffel')) return HotelDataSource.duffelStays;
    if (value.contains('demo')) return HotelDataSource.demo;
    return HotelDataSource.backend;
  }

  String _string(Object? value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  double _number(Object? value) => value is num ? value.toDouble() : 0;

  List<String> _list(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList(growable: false);
    }
    if (value is String && value.isNotEmpty) {
      return value
          .split(',')
          .map((item) => item.trim())
          .toList(growable: false);
    }
    return const [];
  }
}
