import '../../../core/models/booking.dart';
import '../../expenses/domain/entities/expense.dart';
import '../../trips/domain/entities/trip.dart';
import '../../trips/domain/entities/trip_activity.dart';
import '../../trips/domain/entities/trip_document.dart';

enum LiveTripEventType {
  flight,
  hotel,
  transport,
  activity,
  restaurant,
  itinerary,
}

class LiveTripEvent {
  const LiveTripEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.startTime,
    this.endTime,
    this.location,
    this.status,
    this.provider,
    this.booking,
    this.activity,
  });

  final String id;
  final LiveTripEventType type;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final String? location;
  final String? status;
  final String? provider;
  final Booking? booking;
  final TripActivity? activity;

  bool get isBooking => booking != null;
}

class LiveTripMoneySummary {
  const LiveTripMoneySummary({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.currency,
  });

  final double budget;
  final double spent;
  final double remaining;
  final String currency;
}

class LiveTripState {
  const LiveTripState({
    required this.trip,
    required this.now,
    required this.dayNumber,
    required this.totalDays,
    required this.statusLabel,
    required this.events,
    required this.todayEvents,
    required this.upcomingEvents,
    required this.nextEvent,
    required this.relevantDocuments,
    required this.money,
    required this.reminders,
  });

  final Trip trip;
  final DateTime now;
  final int dayNumber;
  final int totalDays;
  final String statusLabel;
  final List<LiveTripEvent> events;
  final List<LiveTripEvent> todayEvents;
  final List<LiveTripEvent> upcomingEvents;
  final LiveTripEvent? nextEvent;
  final List<TripDocument> relevantDocuments;
  final LiveTripMoneySummary money;
  final List<String> reminders;
}

class LiveTripComposer {
  const LiveTripComposer();

  LiveTripState compose({
    required Trip trip,
    required DateTime now,
    List<Booking> bookings = const [],
    List<TripActivity> activities = const [],
    List<TripDocument> documents = const [],
    List<Expense> expenses = const [],
  }) {
    final events = [
      ...bookings.map(_eventFromBooking).whereType<LiveTripEvent>(),
      ...activities.map(_eventFromActivity).whereType<LiveTripEvent>(),
      ..._hotelBoundaryEvents(trip),
    ]..sort((a, b) => a.startTime.compareTo(b.startTime));

    final todayEvents = events
        .where((event) => _isSameDay(event.startTime, now))
        .toList(growable: false);
    final upcomingEvents = events
        .where((event) => !event.startTime.isBefore(now))
        .take(5)
        .toList(growable: false);
    final nextEvent = upcomingEvents.isEmpty ? null : upcomingEvents.first;
    final relevantDocuments = _relevantDocuments(
      documents: documents,
      nextEvent: nextEvent,
    );
    final spent =
        expenses.fold<double>(0, (sum, expense) => sum + expense.amount);

    return LiveTripState(
      trip: trip,
      now: now,
      dayNumber: _dayNumber(trip, now),
      totalDays: _totalDays(trip),
      statusLabel: _statusLabel(trip, now),
      events: events,
      todayEvents: todayEvents,
      upcomingEvents: upcomingEvents,
      nextEvent: nextEvent,
      relevantDocuments: relevantDocuments,
      money: LiveTripMoneySummary(
        budget: trip.budget,
        spent: spent,
        remaining: trip.budget - spent,
        currency: trip.currency,
      ),
      reminders: _reminders(
        trip: trip,
        now: now,
        nextEvent: nextEvent,
        documents: documents,
      ),
    );
  }

  LiveTripEvent? _eventFromBooking(Booking booking) {
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

    return LiveTripEvent(
      id: booking.id,
      type: _bookingEventType(booking),
      title: title,
      startTime: startTime,
      endTime: endTime,
      location: location,
      status: booking.status.name,
      provider: provider,
      booking: booking,
    );
  }

  LiveTripEvent? _eventFromActivity(TripActivity activity) {
    final startTime = activity.scheduledAt;
    if (startTime == null) {
      return null;
    }

    return LiveTripEvent(
      id: activity.id,
      type: _activityEventType(activity),
      title: activity.title,
      startTime: startTime,
      location: activity.location,
      status: activity.status,
      activity: activity,
    );
  }

  List<LiveTripEvent> _hotelBoundaryEvents(Trip trip) {
    return [
      LiveTripEvent(
        id: '${trip.id}-check-in',
        type: LiveTripEventType.hotel,
        title: 'Hotel check-in window',
        startTime: DateTime(
          trip.startDate.year,
          trip.startDate.month,
          trip.startDate.day,
          15,
        ),
        location: trip.destination,
        status: 'Planned',
      ),
      LiveTripEvent(
        id: '${trip.id}-check-out',
        type: LiveTripEventType.hotel,
        title: 'Hotel check-out',
        startTime: DateTime(
          trip.endDate.year,
          trip.endDate.month,
          trip.endDate.day,
          11,
        ),
        location: trip.destination,
        status: 'Planned',
      ),
    ];
  }

  List<TripDocument> _relevantDocuments({
    required List<TripDocument> documents,
    required LiveTripEvent? nextEvent,
  }) {
    if (nextEvent == null) {
      return documents.take(3).toList(growable: false);
    }

    final terms = [
      nextEvent.type.name,
      nextEvent.title,
      nextEvent.provider,
      nextEvent.location,
    ]
        .whereType<String>()
        .expand((value) => value.toLowerCase().split(RegExp(r'[^a-z0-9]+')))
        .where((value) => value.length > 2)
        .toSet();

    final matched = documents.where((document) {
      final haystack = [
        document.title,
        document.type,
        document.reference,
        document.notes,
      ].whereType<String>().join(' ').toLowerCase();
      return terms.any(haystack.contains);
    }).toList(growable: false);

    if (matched.isNotEmpty) {
      return matched.take(3).toList(growable: false);
    }
    return documents.take(3).toList(growable: false);
  }

  List<String> _reminders({
    required Trip trip,
    required DateTime now,
    required LiveTripEvent? nextEvent,
    required List<TripDocument> documents,
  }) {
    final reminders = <String>[];
    if (nextEvent != null) {
      final until = nextEvent.startTime.difference(now);
      if (until.inHours <= 24 && until.inMinutes >= 0) {
        reminders.add('${nextEvent.title} is coming up ${_relative(until)}.');
      }
      if (nextEvent.isBooking && documents.isEmpty) {
        reminders
            .add('Add the confirmation or ticket document for this booking.');
      }
    }
    if (_isSameDay(now, trip.startDate)) {
      reminders.add('Check hotel and transport details before arrival.');
    }
    if (_isSameDay(now, trip.endDate)) {
      reminders.add('Review check-out, transport and final expenses today.');
    }
    if (reminders.isEmpty) {
      reminders.add('No urgent reminders from saved trip data.');
    }
    return reminders;
  }

  LiveTripEventType _bookingEventType(Booking booking) {
    switch (booking.type) {
      case BookingType.flight:
        return LiveTripEventType.flight;
      case BookingType.hotel:
        return LiveTripEventType.hotel;
      case BookingType.transport:
        return LiveTripEventType.transport;
    }
  }

  LiveTripEventType _activityEventType(TripActivity activity) {
    final text = '${activity.title} ${activity.status ?? ''}'.toLowerCase();
    if (text.contains('restaurant') ||
        text.contains('dinner') ||
        text.contains('lunch') ||
        text.contains('table')) {
      return LiveTripEventType.restaurant;
    }
    return LiveTripEventType.activity;
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

  int _dayNumber(Trip trip, DateTime now) {
    if (now.isBefore(_dateOnly(trip.startDate))) {
      return 0;
    }
    if (now.isAfter(_endOfDay(trip.endDate))) {
      return _totalDays(trip);
    }
    return now.difference(_dateOnly(trip.startDate)).inDays + 1;
  }

  int _totalDays(Trip trip) {
    return _dateOnly(trip.endDate)
            .difference(_dateOnly(trip.startDate))
            .inDays +
        1;
  }

  String _statusLabel(Trip trip, DateTime now) {
    if (now.isBefore(_dateOnly(trip.startDate))) {
      return 'Starts in ${_relative(trip.startDate.difference(now))}';
    }
    if (now.isAfter(_endOfDay(trip.endDate))) {
      return 'Trip completed';
    }
    return 'In progress';
  }

  DateTime? _parseDate(Object? value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime _endOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day, 23, 59, 59);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _relative(Duration duration) {
    if (duration.inDays.abs() >= 1) {
      return 'in ${duration.inDays.abs()} day${duration.inDays.abs() == 1 ? '' : 's'}';
    }
    if (duration.inHours.abs() >= 1) {
      return 'in ${duration.inHours.abs()} hour${duration.inHours.abs() == 1 ? '' : 's'}';
    }
    return 'in ${duration.inMinutes.abs()} min';
  }
}
