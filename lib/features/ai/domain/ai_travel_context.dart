import '../../../core/models/booking.dart';
import '../../expenses/domain/entities/expense.dart';
import '../../trips/domain/entities/trip.dart';
import '../../trips/domain/entities/trip_activity.dart';

/// Sanitized context for AI decisions. Document contents and credentials never enter it.
class AiTravelContext {
  const AiTravelContext({
    required this.trip,
    this.bookings = const [],
    this.activities = const [],
    this.eventSummaries = const [],
    this.savedPlaces = const [],
    this.weatherSummary,
    this.readinessSummary,
    this.spent = 0,
  });

  final Trip trip;
  final List<Booking> bookings;
  final List<TripActivity> activities;
  final List<String> eventSummaries;
  final List<String> savedPlaces;
  final String? weatherSummary;
  final String? readinessSummary;
  final double spent;

  double get confirmedBookingSpend => bookings
      .where((booking) => booking.status.name == 'confirmed')
      .fold<double>(0, (sum, booking) => sum + booking.amount);

  double get remainingBudget => (trip.budget - spent - confirmedBookingSpend)
      .clamp(0, trip.budget)
      .toDouble();

  Map<String, dynamic> toPromptData() => {
        'trip': {
          'id': trip.id,
          'destination': trip.destination,
          'startDate': trip.startDate.toIso8601String(),
          'endDate': trip.endDate.toIso8601String(),
          'travellers': trip.travellers,
          'budget': trip.budget,
          'currency': trip.currency,
        },
        'bookings': bookings
            .map((booking) => {
                  'type': booking.type.name,
                  'status': booking.status.name,
                  'amount': booking.amount,
                  'currency': booking.currency,
                })
            .toList(growable: false),
        'activities': activities
            .map((activity) => {
                  'title': activity.title,
                  'location': activity.location,
                  'scheduledAt': activity.scheduledAt?.toIso8601String(),
                  'status': activity.status,
                })
            .toList(growable: false),
        'upcomingEvents': eventSummaries,
        'savedPlaces': savedPlaces,
        'weather': weatherSummary,
        'readiness': readinessSummary,
        'spent': spent,
        'remainingBudget': remainingBudget,
      };

  String get fingerprint => [
        trip.id,
        trip.startDate.toIso8601String(),
        trip.endDate.toIso8601String(),
        trip.budget,
        bookings
            .map((booking) => '${booking.id}:${booking.status.name}')
            .join(','),
        activities
            .map((activity) => '${activity.id}:${activity.scheduledAt}')
            .join(','),
        eventSummaries.join(','),
        savedPlaces.join(','),
        weatherSummary ?? '',
        readinessSummary ?? '',
        spent,
      ].join('|');

  factory AiTravelContext.fromTripData({
    required Trip trip,
    List<Booking> bookings = const [],
    List<TripActivity> activities = const [],
    List<String> eventSummaries = const [],
    List<String> savedPlaces = const [],
    String? weatherSummary,
    String? readinessSummary,
    List<Expense> expenses = const [],
  }) {
    return AiTravelContext(
      trip: trip,
      bookings: bookings,
      activities: activities,
      eventSummaries: eventSummaries,
      savedPlaces: savedPlaces,
      weatherSummary: weatherSummary,
      readinessSummary: readinessSummary,
      spent: expenses.fold<double>(0, (sum, expense) => sum + expense.amount),
    );
  }
}
