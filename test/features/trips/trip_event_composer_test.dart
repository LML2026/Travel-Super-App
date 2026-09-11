import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/core/models/booking.dart';
import 'package:travel_super_app/features/flights/models/saved_flight.dart';
import 'package:travel_super_app/features/hotels/models/saved_hotel.dart';
import 'package:travel_super_app/features/taxi/domain/entities/taxi_saved_ride.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip_activity.dart';
import 'package:travel_super_app/features/trips/domain/services/trip_event_composer.dart';

void main() {
  test('TripEventComposer orders bookings, activities and hotel boundaries',
      () {
    final trip = Trip(
      id: 'trip-1',
      title: 'Paris',
      destination: 'Paris',
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 3),
      budget: 1200,
    );

    final events = const TripEventComposer().compose(
      trip: trip,
      bookings: [
        Booking.flight(
          id: 'booking-flight',
          tripId: 'trip-1',
          userId: 'user-1',
          amount: 220,
          currency: 'GBP',
          metadata: {
            'title': 'Flight to Paris',
            'startTime': DateTime(2026, 9, 1, 8).toIso8601String(),
            'location': 'LHR',
          },
        ).copyWith(status: BookingStatus.confirmed),
      ],
      activities: [
        TripActivity(
          id: 'activity-1',
          tripId: 'trip-1',
          title: 'Dinner at Le Canal',
          location: 'Canal Saint-Martin',
          scheduledAt: DateTime(2026, 9, 1, 20),
          status: 'Restaurant planned',
        ),
      ],
    );

    expect(events.map((event) => event.title), [
      'Flight to Paris',
      'Check in: Hotel',
      'Dinner at Le Canal',
      'Check out: Hotel',
    ]);
    expect(events.first.type, TripEventType.flight);
    expect(events[2].type, TripEventType.restaurant);
  });

  test(
      'TripEventComposer avoids linked flight and hotel duplicates when confirmed booking exists',
      () {
    final trip = Trip(
      id: 'trip-1',
      title: 'Paris',
      destination: 'Paris',
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 3),
      budget: 1200,
    );

    final events = const TripEventComposer().compose(
      trip: trip,
      bookings: [
        Booking.flight(
          id: 'booking-flight',
          tripId: 'trip-1',
          userId: 'user-1',
          amount: 220,
          currency: 'GBP',
          metadata: {'title': 'Confirmed flight'},
        ).copyWith(status: BookingStatus.confirmed),
        Booking.hotel(
          id: 'booking-hotel',
          tripId: 'trip-1',
          userId: 'user-1',
          amount: 420,
          currency: 'GBP',
          metadata: {'title': 'Confirmed hotel'},
        ).copyWith(status: BookingStatus.confirmed),
      ],
      linkedFlight: SavedFlight(
        id: 'saved-flight',
        flightId: 'flight-1',
        airline: 'Demo Air',
        airlineLogo: '',
        flightNumber: 'DA100',
        origin: 'LHR',
        destination: 'CDG',
        departureAt: DateTime(2026, 9, 1, 8).toIso8601String(),
        arrivalAt: DateTime(2026, 9, 1, 10).toIso8601String(),
        duration: '2h',
        stops: 0,
        amount: 220,
        currency: 'GBP',
        cabinClass: 'economy',
        savedAt: DateTime(2026, 8, 1),
      ),
      linkedHotel: SavedHotel(
        id: 'saved-hotel',
        hotelId: 'hotel-1',
        name: 'Demo Hotel',
        city: 'Paris',
        rating: 4.5,
        pricePerNight: 160,
        totalPrice: 320,
        beds: 1,
        image: '',
        nights: 2,
        savedAt: DateTime(2026, 8, 1),
      ),
    );

    expect(events.map((event) => event.title), [
      'Confirmed flight',
      'Confirmed hotel',
    ]);
  });

  test('TripEventComposer keeps distinct linked and confirmed flights', () {
    final trip = Trip(
      id: 'trip-1',
      title: 'Paris',
      destination: 'Paris',
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 3),
      budget: 1200,
    );

    final events = const TripEventComposer().compose(
      trip: trip,
      bookings: [
        Booking.flight(
          id: 'booking-flight',
          tripId: 'trip-1',
          userId: 'user-1',
          amount: 220,
          currency: 'GBP',
          metadata: {'flightId': 'different-flight'},
        ).copyWith(status: BookingStatus.confirmed),
      ],
      linkedFlight: SavedFlight(
        id: 'saved-flight',
        flightId: 'linked-flight',
        airline: 'Demo Air',
        airlineLogo: '',
        flightNumber: 'DA100',
        origin: 'LHR',
        destination: 'CDG',
        departureAt: '2026-09-01T08:00:00',
        arrivalAt: '2026-09-01T10:00:00',
        duration: '2h',
        stops: 0,
        amount: 220,
        currency: 'GBP',
        cabinClass: 'economy',
        savedAt: DateTime(2026, 8, 1),
      ),
    );

    expect(events.where((event) => event.type == TripEventType.flight),
        hasLength(3));
  });

  test('TripEventComposer removes a duplicate transport representation', () {
    final trip = Trip(
      id: 'trip-1',
      title: 'Paris',
      destination: 'Paris',
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 3),
      budget: 1200,
    );
    final ride = TaxiSavedRide(
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

    final events = const TripEventComposer().compose(
      trip: trip,
      rides: [ride],
      bookings: [
        Booking.transport(
          id: 'booking-transport',
          tripId: 'trip-1',
          userId: 'user-1',
          amount: 30,
          currency: 'GBP',
          metadata: {
            'pickup': 'CDG',
            'destination': 'Paris centre',
          },
        ).copyWith(status: BookingStatus.confirmed),
      ],
    );

    final transportEvents =
        events.where((event) => event.type == TripEventType.transport);
    expect(transportEvents, hasLength(1));
    expect(transportEvents.single.booking, isNotNull);
  });
}
