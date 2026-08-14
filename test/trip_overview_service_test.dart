import 'package:flutter_test/flutter_test.dart';
import 'package:itarevo/core/services/trip_overview_service.dart';
import 'package:itarevo/features/trips/models/itinerary/itinerary_item.dart';
import 'package:itarevo/features/trips/models/trip.dart';

void main() {
  test('derives plan, booked, estimated cost, and budget values', () {
    final summary = TripOverviewService.build(
      trip: _trip(budget: 1000),
      items: [
        _item('a', estimatedCost: 200, isBooked: true),
        _item('b', estimatedCost: 150),
        _item('c'),
      ],
      now: DateTime(2026, 9, 1),
    );

    expect(summary.planCount, 3);
    expect(summary.bookedCount, 1);
    expect(summary.estimatedCost, 350);
    expect(summary.hasEstimatedCost, isTrue);
    expect(summary.budgetProgress, 0.35);
    expect(summary.overBudget, 0);
  });

  test('calculates over-budget amount without changing values', () {
    final summary = TripOverviewService.build(
      trip: _trip(budget: 300),
      items: [_item('a', estimatedCost: 420)],
      now: DateTime(2026, 9, 1),
    );

    expect(summary.estimatedCost, 420);
    expect(summary.trip.budget, 300);
    expect(summary.budgetProgress, 1.4);
    expect(summary.overBudget, 120);
  });

  test('calculates inclusive trip duration and upcoming countdown', () {
    final summary = TripOverviewService.build(
      trip: _trip(),
      items: const [],
      now: DateTime(2026, 9, 10, 18),
    );

    expect(summary.durationDays, 6);
    expect(summary.status, TripOverviewStatus.upcoming);
    expect(summary.daysUntilStart, 5);
  });

  test('classifies active and completed trips from date boundaries', () {
    final active = TripOverviewService.build(
      trip: _trip(),
      items: const [],
      now: DateTime(2026, 9, 20, 23, 59),
    );
    final completed = TripOverviewService.build(
      trip: _trip(),
      items: const [],
      now: DateTime(2026, 9, 21),
    );

    expect(active.status, TripOverviewStatus.inProgress);
    expect(active.daysUntilStart, isNull);
    expect(completed.status, TripOverviewStatus.completed);
    expect(completed.nextPlan, isNull);
  });

  test('selects the next active plan using date and time', () {
    final summary = TripOverviewService.build(
      trip: _trip(),
      items: [
        _item('past', date: DateTime(2026, 9, 16), time: '09:00'),
        _item('next', date: DateTime(2026, 9, 16), time: '14:00'),
        _item('later', date: DateTime(2026, 9, 17), time: '10:00'),
      ],
      now: DateTime(2026, 9, 16, 12),
    );

    expect(summary.nextPlan?.id, 'next');
  });

  test('respects optimized ordering in itinerary day previews', () {
    final summary = TripOverviewService.build(
      trip: _trip(),
      items: [
        _item('early', time: '09:00', orderIndex: 2),
        _item('late', time: '11:00', orderIndex: 0),
        _item('middle', time: '10:00', orderIndex: 1),
      ],
      now: DateTime(2026, 9, 1),
    );

    expect(summary.days.single.items.map((item) => item.id), [
      'late',
      'middle',
      'early',
    ]);
    expect(summary.nextPlan?.id, 'early');
  });

  test('falls back to chronological order without complete order indexes', () {
    final summary = TripOverviewService.build(
      trip: _trip(),
      items: [
        _item('late', time: '11:00', orderIndex: 0),
        _item('early', time: '09:00'),
        _item('middle', time: '10:00', orderIndex: 1),
      ],
      now: DateTime(2026, 9, 1),
    );

    expect(summary.days.single.items.map((item) => item.id), [
      'early',
      'middle',
      'late',
    ]);
  });
}

Trip _trip({double budget = 1200}) => Trip(
  id: 'trip',
  destination: 'Rome',
  departureDate: DateTime(2026, 9, 15),
  returnDate: DateTime(2026, 9, 20),
  travellers: 2,
  notes: '',
  budget: budget,
  currency: 'EUR',
);

ItineraryItem _item(
  String id, {
  DateTime? date,
  String? time,
  double? estimatedCost,
  bool isBooked = false,
  int? orderIndex,
}) => ItineraryItem(
  id: id,
  tripId: 'trip',
  title: id,
  date: date ?? DateTime(2026, 9, 15),
  time: time,
  location: '',
  category: 'Activity',
  notes: '',
  estimatedCost: estimatedCost,
  currency: 'EUR',
  isBooked: isBooked,
  orderIndex: orderIndex,
);
