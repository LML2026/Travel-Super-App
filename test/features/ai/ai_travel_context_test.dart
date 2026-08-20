import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/core/models/booking.dart';
import 'package:travel_super_app/features/ai/domain/ai_companion_actions.dart';
import 'package:travel_super_app/features/ai/domain/ai_travel_context.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip_activity.dart';

Trip _trip() => Trip(
      id: 'trip-context',
      title: 'Context trip',
      destination: 'Paris',
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 4),
      budget: 1000,
      currency: 'GBP',
      travellers: 2,
    );

void main() {
  test('context contains useful trip data without document contents', () {
    final trip = _trip();
    final context = AiTravelContext.fromTripData(
      trip: trip,
      bookings: [
        Booking.flight(
          id: 'flight-1',
          tripId: trip.id,
          userId: 'user-1',
          amount: 300,
          currency: 'GBP',
          metadata: {'documentContents': 'must never be sent'},
        ).copyWith(status: BookingStatus.confirmed),
      ],
      activities: [
        TripActivity(
          id: 'activity-1',
          tripId: trip.id,
          title: 'Museum',
          location: 'Central Paris',
        ),
      ],
      eventSummaries: const ['Flight tomorrow at 09:00'],
      savedPlaces: const ['Local food hall'],
      weatherSummary: 'Sunny, 20°C',
      readinessSummary: '3/5 tasks complete',
    );

    final payload = context.toPromptData().toString();
    expect(payload, contains('Paris'));
    expect(payload, contains('Flight tomorrow'));
    expect(payload, isNot(contains('must never be sent')));
    expect(context.remainingBudget, 700);
  });

  test('quick actions are hidden without context and useful with a trip', () {
    expect(AiCompanionActionCatalog.forTrip(hasTrip: false), isEmpty);
    final actions = AiCompanionActionCatalog.forTrip(hasTrip: true);
    final labels = actions.map((action) => action.label).toSet();
    expect(
      labels,
      containsAll([
        'Today',
        'Next',
        'Nearby',
        'Route',
        'Bookings',
        'Readiness',
        'Translate',
      ]),
    );
  });
}
