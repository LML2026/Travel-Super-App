import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/core/models/booking.dart';
import 'package:travel_super_app/features/expenses/domain/entities/expense.dart';
import 'package:travel_super_app/features/live_trip/domain/live_trip_models.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip_activity.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip_document.dart';

void main() {
  group('LiveTripComposer', () {
    test('builds active trip context with next event and today timeline', () {
      final now = DateTime(2026, 9, 3, 9);
      final state = const LiveTripComposer().compose(
        trip: _trip(),
        now: now,
        bookings: [
          _booking(
            id: 'flight-1',
            type: BookingType.flight,
            startTime: DateTime(2026, 9, 3, 14),
            title: 'Flight to Rome',
            location: 'Paris CDG',
            provider: 'ITAREVO Air',
          ),
        ],
        activities: [
          const TripActivity(
            id: 'restaurant-1',
            tripId: 'trip-1',
            title: 'Local dinner table',
            location: 'Trastevere',
            status: 'Restaurant planned',
            scheduledAt: null,
          ),
          TripActivity(
            id: 'activity-1',
            tripId: 'trip-1',
            title: 'Museum visit',
            location: 'City centre',
            status: 'Booked',
            scheduledAt: DateTime(2026, 9, 3, 17),
          ),
        ],
        documents: [
          TripDocument(
            id: 'doc-1',
            tripId: 'trip-1',
            title: 'Flight ticket',
            type: 'flight',
            reference: 'IT123',
            createdAt: DateTime(2026, 8, 1),
          ),
        ],
        expenses: [
          Expense(
            id: 'expense-1',
            tripId: 'trip-1',
            title: 'Lunch',
            amount: 35,
            currency: 'GBP',
            category: 'Food',
            date: now,
            notes: '',
          ),
        ],
      );

      expect(state.statusLabel, 'In progress');
      expect(state.dayNumber, 3);
      expect(state.totalDays, 5);
      expect(state.nextEvent?.title, 'Flight to Rome');
      expect(state.todayEvents.map((event) => event.title),
          contains('Museum visit'));
      expect(state.relevantDocuments.single.title, 'Flight ticket');
      expect(state.money.spent, 35);
      expect(state.money.remaining, 965);
      expect(state.reminders.first, contains('Flight to Rome'));
    });

    test('uses hotel boundary events when no explicit next booking exists', () {
      final state = const LiveTripComposer().compose(
        trip: _trip(),
        now: DateTime(2026, 9, 1, 12),
      );

      expect(state.nextEvent?.title, 'Check in: Hotel');
      expect(state.nextEvent?.type, LiveTripEventType.hotel);
    });

    test('marks future trips before start date', () {
      final state = const LiveTripComposer().compose(
        trip: _trip(),
        now: DateTime(2026, 8, 30, 10),
      );

      expect(state.dayNumber, 0);
      expect(state.statusLabel, contains('Starts in'));
    });
  });
}

Trip _trip() {
  return Trip(
    id: 'trip-1',
    title: 'Rome',
    destination: 'Rome',
    startDate: DateTime(2026, 9, 1),
    endDate: DateTime(2026, 9, 5),
    budget: 1000,
    currency: 'GBP',
    travellers: 2,
  );
}

Booking _booking({
  required String id,
  required BookingType type,
  required DateTime startTime,
  required String title,
  required String location,
  required String provider,
}) {
  return Booking(
    id: id,
    tripId: 'trip-1',
    userId: 'user-1',
    type: type,
    status: BookingStatus.confirmed,
    amount: 120,
    currency: 'GBP',
    createdAt: DateTime(2026, 8, 1),
    metadata: {
      'title': title,
      'location': location,
      'provider': provider,
      'startTime': startTime.toIso8601String(),
    },
  );
}
