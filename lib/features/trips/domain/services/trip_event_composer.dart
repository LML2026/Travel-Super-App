import '../../../../core/models/booking.dart';
import '../../../flights/models/saved_flight.dart';
import '../../../hotels/models/saved_hotel.dart';
import '../../../taxi/domain/entities/taxi_saved_ride.dart';
import '../../../trip_readiness/domain/entities/trip_readiness_item.dart';
import '../entities/trip.dart';
import '../entities/trip_activity.dart';

enum TripEventType {
  flight,
  hotel,
  transport,
  activity,
  restaurant,
  readiness,
  itinerary,
}

class TripEvent {
  const TripEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.startTime,
    this.endTime,
    this.location,
    this.status,
    this.provider,
    this.subtitle,
    this.booking,
    this.activity,
    this.reminder,
    this.source = 'trip',
  });

  final String id;
  final TripEventType type;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final String? location;
  final String? status;
  final String? provider;
  final String? subtitle;
  final Booking? booking;
  final TripActivity? activity;
  final TripReminder? reminder;
  final String source;

  bool get isBooking => booking != null;
}

class TripEventComposer {
  const TripEventComposer();

  List<TripEvent> compose({
    required Trip trip,
    List<Booking> bookings = const [],
    List<TripActivity> activities = const [],
    List<TaxiSavedRide> rides = const [],
    List<TripReminder> reminders = const [],
    SavedFlight? linkedFlight,
    SavedHotel? linkedHotel,
    bool includeReadiness = false,
  }) {
    final confirmedBookings = bookings
        .where((booking) => booking.status == BookingStatus.confirmed)
        .toList(growable: false);
    final events = <TripEvent>[
      ...confirmedBookings.map(_eventFromBooking).whereType<TripEvent>(),
      ...activities.map((activity) => _eventFromActivity(trip, activity)),
      ...rides
          .where(
              (ride) => !_hasMatchingTransportBooking(ride, confirmedBookings))
          .map(_eventFromRide),
      ..._linkedFlightEvents(
        linkedFlight,
        hasConfirmedFlight: _hasMatchingFlightBooking(
          linkedFlight,
          confirmedBookings,
        ),
      ),
      ..._hotelEvents(
        trip: trip,
        linkedHotel: linkedHotel,
        hasConfirmedHotel: _hasMatchingHotelBooking(
          linkedHotel,
          confirmedBookings,
        ),
      ),
      if (includeReadiness)
        ...reminders.map(_eventFromReminder).whereType<TripEvent>(),
    ];

    return _dedupe(events)..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  TripEvent? _eventFromBooking(Booking booking) {
    final metadata = booking.metadata;
    final startTime = _parseDate(metadata['startTime']) ?? booking.createdAt;
    final endTime = _parseDate(metadata['endTime']);
    final title = (metadata['title'] as String?) ?? _bookingTitle(booking);
    final provider = (metadata['provider'] as String?) ??
        (metadata['providerName'] as String?) ??
        (metadata['airline'] as String?) ??
        (metadata['hotelName'] as String?);
    final location = (metadata['location'] as String?) ??
        (metadata['pickup'] as String?) ??
        (metadata['destination'] as String?) ??
        (metadata['arrival'] as String?) ??
        (metadata['city'] as String?);

    return TripEvent(
      id: 'booking-${booking.id}',
      type: _bookingEventType(booking),
      title: title,
      subtitle: _bookingSubtitle(booking),
      startTime: startTime,
      endTime: endTime,
      location: location,
      status: booking.status.name,
      provider: provider,
      booking: booking,
      source: 'booking',
    );
  }

  TripEvent _eventFromActivity(Trip trip, TripActivity activity) {
    return TripEvent(
      id: 'activity-${activity.id}',
      type: _activityEventType(activity),
      title: activity.title,
      subtitle: activity.notes,
      startTime: activity.scheduledAt ?? activity.createdAt ?? trip.startDate,
      location: activity.location ?? trip.destination,
      status: activity.status ?? 'Planned',
      activity: activity,
      source: 'activity',
    );
  }

  TripEvent _eventFromRide(TaxiSavedRide ride) {
    return TripEvent(
      id: 'ride-${ride.id}',
      type: TripEventType.transport,
      title: '${ride.provider} ride',
      subtitle: '${ride.pickupAddress} -> ${ride.destinationAddress}',
      startTime: ride.scheduledAt ?? ride.createdAt ?? DateTime.now(),
      location: ride.pickupAddress,
      status: ride.status,
      provider: ride.provider,
      source: 'transport',
    );
  }

  TripEvent? _eventFromReminder(TripReminder reminder) {
    if (reminder.isCompleted) {
      return null;
    }
    return TripEvent(
      id: 'reminder-${reminder.id}',
      type: TripEventType.readiness,
      title: reminder.title,
      subtitle: reminder.notes,
      startTime: reminder.dueAt,
      status: reminder.sourceType,
      reminder: reminder,
      source: 'readiness',
    );
  }

  List<TripEvent> _linkedFlightEvents(
    SavedFlight? flight, {
    required bool hasConfirmedFlight,
  }) {
    if (flight == null || hasConfirmedFlight) {
      return const [];
    }
    final departure = _parseDate(flight.departureAt);
    final arrival = _parseDate(flight.arrivalAt);
    return [
      TripEvent(
        id: 'linked-flight-${flight.id}-departure',
        type: TripEventType.flight,
        title: '${flight.airline} ${flight.flightNumber}',
        subtitle: '${flight.origin} -> ${flight.destination}',
        startTime: departure ?? flight.savedAt,
        endTime: arrival,
        location: flight.origin,
        status: 'Linked flight',
        provider: flight.airline,
        source: 'linkedFlight',
      ),
      if (arrival != null)
        TripEvent(
          id: 'linked-flight-${flight.id}-arrival',
          type: TripEventType.flight,
          title: 'Arrive ${flight.destination}',
          subtitle: flight.duration,
          startTime: arrival,
          location: flight.destination,
          status: flight.cabinClass,
          provider: flight.airline,
          source: 'linkedFlight',
        ),
    ];
  }

  List<TripEvent> _hotelEvents({
    required Trip trip,
    required SavedHotel? linkedHotel,
    required bool hasConfirmedHotel,
  }) {
    if (hasConfirmedHotel) {
      return const [];
    }
    final hotelName = linkedHotel?.name ?? 'Hotel';
    final address = linkedHotel == null
        ? trip.destination
        : linkedHotel.address.isNotEmpty
            ? linkedHotel.address
            : linkedHotel.city;
    return [
      TripEvent(
        id: '${trip.id}-hotel-check-in',
        type: TripEventType.hotel,
        title: 'Check in: $hotelName',
        subtitle: address,
        startTime: DateTime(
          trip.startDate.year,
          trip.startDate.month,
          trip.startDate.day,
          15,
        ),
        location: linkedHotel?.city ?? trip.destination,
        status:
            linkedHotel == null ? 'Planned' : '${linkedHotel.nights} nights',
        provider: linkedHotel?.name,
        source: linkedHotel == null ? 'tripBoundary' : 'linkedHotel',
      ),
      TripEvent(
        id: '${trip.id}-hotel-check-out',
        type: TripEventType.hotel,
        title: 'Check out: $hotelName',
        subtitle: address,
        startTime: DateTime(
          trip.endDate.year,
          trip.endDate.month,
          trip.endDate.day,
          11,
        ),
        location: linkedHotel?.city ?? trip.destination,
        status: 'Stay complete',
        provider: linkedHotel?.name,
        source: linkedHotel == null ? 'tripBoundary' : 'linkedHotel',
      ),
    ];
  }

  List<TripEvent> _dedupe(List<TripEvent> events) {
    final seen = <String>{};
    final deduped = <TripEvent>[];
    for (final event in events) {
      final key = [
        event.type.name,
        event.title.trim().toLowerCase(),
        event.location?.trim().toLowerCase() ?? '',
        event.startTime.toIso8601String(),
      ].join('|');
      if (seen.add(key)) {
        deduped.add(event);
      }
    }
    return deduped;
  }

  bool _hasMatchingFlightBooking(
    SavedFlight? flight,
    List<Booking> bookings,
  ) {
    if (flight == null) return false;
    final flightBookings = bookings
        .where((booking) => booking.type == BookingType.flight)
        .toList();
    return flightBookings.any((booking) {
          final metadata = booking.metadata;
          return metadata['flightId'] == flight.flightId ||
              metadata['flightNumber'] == flight.flightNumber;
        }) ||
        (flightBookings.length == 1 &&
            flightBookings.single.metadata['flightId'] == null &&
            flightBookings.single.metadata['flightNumber'] == null);
  }

  bool _hasMatchingHotelBooking(
    SavedHotel? hotel,
    List<Booking> bookings,
  ) {
    if (hotel == null) return false;
    final hotelBookings =
        bookings.where((booking) => booking.type == BookingType.hotel).toList();
    return hotelBookings.any((booking) {
          final metadata = booking.metadata;
          return metadata['hotelId'] == hotel.hotelId ||
              metadata['hotelName'] == hotel.name ||
              metadata['name'] == hotel.name;
        }) ||
        (hotelBookings.length == 1 &&
            hotelBookings.single.metadata['hotelId'] == null &&
            hotelBookings.single.metadata['hotelName'] == null &&
            hotelBookings.single.metadata['name'] == null);
  }

  bool _hasMatchingTransportBooking(
    TaxiSavedRide ride,
    List<Booking> bookings,
  ) {
    final transportBookings = bookings
        .where((booking) => booking.type == BookingType.transport)
        .toList();
    return transportBookings.any((booking) {
          final metadata = booking.metadata;
          return metadata['rideId'] == ride.id ||
              (metadata['pickup'] == ride.pickupAddress &&
                  metadata['destination'] == ride.destinationAddress);
        }) ||
        (transportBookings.length == 1 &&
            transportBookings.single.metadata['rideId'] == null &&
            transportBookings.single.metadata['pickup'] == null);
  }

  TripEventType _bookingEventType(Booking booking) {
    switch (booking.type) {
      case BookingType.flight:
        return TripEventType.flight;
      case BookingType.hotel:
        return TripEventType.hotel;
      case BookingType.transport:
        return TripEventType.transport;
    }
  }

  TripEventType _activityEventType(TripActivity activity) {
    final text = '${activity.title} ${activity.status ?? ''}'.toLowerCase();
    if (text.contains('restaurant') ||
        text.contains('dinner') ||
        text.contains('lunch') ||
        text.contains('table')) {
      return TripEventType.restaurant;
    }
    return TripEventType.activity;
  }

  String _bookingTitle(Booking booking) {
    switch (booking.type) {
      case BookingType.flight:
        return 'Flight booking';
      case BookingType.hotel:
        return 'Hotel booking';
      case BookingType.transport:
        return 'Transport booking';
    }
  }

  String _bookingSubtitle(Booking booking) {
    final metadata = booking.metadata;
    final provider = metadata['provider'] ?? metadata['providerName'];
    final route = [
      metadata['origin'] ?? metadata['pickup'],
      metadata['destination'] ?? metadata['arrival'],
    ].whereType<String>().where((value) => value.isNotEmpty).join(' -> ');
    if (route.isNotEmpty && provider != null) {
      return '$provider · $route';
    }
    if (route.isNotEmpty) return route;
    if (provider != null) return provider.toString();
    return '${booking.currency} ${booking.amount.toStringAsFixed(2)}';
  }

  DateTime? _parseDate(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
