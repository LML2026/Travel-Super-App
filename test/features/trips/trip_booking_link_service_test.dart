import 'package:flutter_test/flutter_test.dart';

import 'package:travel_super_app/features/discovery/domain/travel_discovery_models.dart';
import 'package:travel_super_app/features/flights/models/flight.dart';
import 'package:travel_super_app/features/hotels/models/hotel.dart';
import 'package:travel_super_app/features/taxi/domain/entities/taxi_saved_ride.dart';
import 'package:travel_super_app/features/taxi/domain/repositories/taxi_transport_repository.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_repository.dart';
import 'package:travel_super_app/features/trips/services/trip_booking_link_service.dart';

void main() {
  test('linking the same flight twice saves it once and reports already linked',
      () async {
    final repository = _TripRepository();
    final saved = <String>{};
    var saveCalls = 0;
    final service = TripBookingLinkService(
      tripRepository: repository,
      flightSavedLookup: (id) async => saved.contains(id),
      flightSaver: (flight) async {
        saveCalls++;
        saved.add(flight.id);
      },
    );
    final flight = _flight();

    final first = await service.linkFlight(trip: _trip(), flight: flight);
    final second = await service.linkFlight(
      trip: _trip().copyWith(selectedFlightId: flight.id),
      flight: flight,
    );

    expect(first.status, TripBookingLinkStatus.linked);
    expect(second.status, TripBookingLinkStatus.alreadyLinked);
    expect(saveCalls, 1);
    expect(repository.updatedTrips, hasLength(1));
  });

  test('linking the same hotel twice is duplicate-safe', () async {
    final repository = _TripRepository();
    final service = TripBookingLinkService(
      tripRepository: repository,
      hotelSavedLookup: (_) async => true,
      hotelSaver: (_) async => fail('saved hotel should not be written'),
    );
    final hotel = _hotel();

    final first = await service.linkHotel(trip: _trip(), hotel: hotel);
    final second = await service.linkHotel(
      trip: _trip().copyWith(selectedHotelId: hotel.id),
      hotel: hotel,
    );

    expect(first.status, TripBookingLinkStatus.linked);
    expect(second.status, TripBookingLinkStatus.alreadyLinked);
    expect(repository.updatedTrips.single.selectedHotelId, hotel.id);
  });

  test('Discovery demo results preserve demo source when linked', () async {
    Flight? savedFlight;
    final service = TripBookingLinkService(
      tripRepository: _TripRepository(),
      flightSavedLookup: (_) async => false,
      flightSaver: (flight) async => savedFlight = flight,
    );

    final result = TravelDiscoveryResult(
      id: 'demo-flight-1',
      category: DiscoveryCategory.flights,
      title: 'Demo flight',
      subtitle: 'Demo route',
      provider: 'ITAREVO Demo Flights',
      location: 'LHR -> CDG',
      startTime: DateTime(2026, 9, 1, 8),
      endTime: DateTime(2026, 9, 1, 10),
      duration: '2h',
      price: 100,
      currency: 'GBP',
      rating: 4,
      details: 'Demo only',
      metadata: const {
        'airline': 'Demo Air',
        'flightNumber': 'DA100',
        'departure': 'LHR',
        'arrival': 'CDG',
      },
    );

    final link = await service.linkDiscoveryResult(
      trip: _trip(),
      result: result,
    );

    expect(link.status, TripBookingLinkStatus.linked);
    expect(savedFlight?.dataSource, FlightDataSource.demo);
  });

  test('transport linking deduplicates the same planned ride', () async {
    final repository = _TaxiRepository();
    final service = TripBookingLinkService(transportStore: repository);
    final ride = _ride();

    final first = await service.linkTransport(ride: ride);
    final second = await service.linkTransport(ride: ride);

    expect(first.status, TripBookingLinkStatus.linked);
    expect(second.status, TripBookingLinkStatus.alreadyLinked);
    expect(repository.saved, hasLength(1));
  });

  test('link failures return a safe failed result', () async {
    final service = TripBookingLinkService(
      tripRepository: _TripRepository(),
      flightSavedLookup: (_) async => false,
      flightSaver: (_) async => throw StateError('provider unavailable'),
    );

    final result = await service.linkFlight(trip: _trip(), flight: _flight());

    expect(result.status, TripBookingLinkStatus.failed);
    expect(result.message, contains('could not link this flight'));
  });
}

Trip _trip() => Trip(
      id: 'trip-1',
      title: 'Paris',
      destination: 'Paris',
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 4),
      budget: 1200,
    );

Flight _flight() => const Flight(
      id: 'flight-1',
      airline: 'Demo Air',
      airlineLogo: '',
      flightNumber: 'DA100',
      origin: 'LHR',
      destination: 'CDG',
      departureAt: '2026-09-01T08:00:00',
      arrivalAt: '2026-09-01T10:00:00',
      duration: '2h',
      stops: 0,
      amount: 100,
      currency: 'GBP',
      cabinClass: 'economy',
    );

Hotel _hotel() => const Hotel(
      id: 'hotel-1',
      name: 'Demo Hotel',
      image: '',
      rating: 4.2,
      address: 'Paris centre',
      city: 'Paris',
      price: 120,
      currency: 'GBP',
      amenities: ['Wi-Fi'],
      totalPrice: 360,
      nights: 3,
    );

TaxiSavedRide _ride() => TaxiSavedRide(
      id: 'ride-1',
      tripId: 'trip-1',
      provider: 'Demo Taxi',
      pickupAddress: 'CDG',
      destinationAddress: 'Paris centre',
      pickupLatitude: 0,
      pickupLongitude: 0,
      destinationLatitude: 0,
      destinationLongitude: 0,
      scheduledAt: DateTime(2026, 9, 1, 11),
      status: 'planned',
      estimatedFare: 30,
      currency: 'GBP',
      passengers: 1,
      luggage: 1,
    );

class _TripRepository implements TripRepository {
  final updatedTrips = <Trip>[];

  @override
  Future<void> createTrip(Trip trip) async {}

  @override
  Future<void> deleteTrip(String id) async {}

  @override
  Future<Trip?> get(String id) async => _trip();

  @override
  Future<List<Trip>> getAll() async => [_trip()];

  @override
  Future<void> updateTrip(Trip trip) async => updatedTrips.add(trip);

  @override
  Stream<List<Trip>> watchTrips() => Stream.value([_trip()]);
}

class _TaxiRepository implements TaxiTransportRepository {
  final saved = <TaxiSavedRide>[];

  @override
  Future<void> saveRide(
      {required String tripId, required TaxiSavedRide ride}) async {
    saved.removeWhere((item) => item.id == ride.id);
    saved.add(ride);
  }

  @override
  Stream<List<TaxiSavedRide>> watchRidesForTrip(String tripId) {
    return Stream.value(saved.where((ride) => ride.tripId == tripId).toList());
  }
}
