import 'package:flutter_test/flutter_test.dart';
import 'package:itarevo/core/journey_intelligence/analyzers/booking_flag_analyzer.dart';
import 'package:itarevo/core/journey_intelligence/analyzers/budget_estimate_analyzer.dart';
import 'package:itarevo/core/journey_intelligence/analyzers/itinerary_summary_analyzer.dart';
import 'package:itarevo/core/journey_intelligence/analyzers/missing_coordinate_analyzer.dart';
import 'package:itarevo/core/journey_intelligence/analyzers/next_scheduled_item_analyzer.dart';
import 'package:itarevo/core/journey_intelligence/analyzers/trip_status_analyzer.dart';
import 'package:itarevo/core/journey_intelligence/journey_analyzer.dart';
import 'package:itarevo/core/journey_intelligence/journey_context.dart';
import 'package:itarevo/core/journey_intelligence/journey_context_builder.dart';
import 'package:itarevo/core/journey_intelligence/journey_clock.dart';
import 'package:itarevo/core/journey_intelligence/journey_insight.dart';
import 'package:itarevo/features/trips/models/itinerary/itinerary_item.dart';
import 'package:itarevo/features/trips/models/trip.dart';

void main() {
  final clock = DateTime(2026, 9, 16, 12);

  group('JourneyContextBuilder', () {
    test('creates an immutable snapshot using existing ordering semantics', () {
      final source = [
        _item('later', time: '11:00', orderIndex: 1),
        _item('earlier', time: '09:00', orderIndex: 0),
      ];
      final context = _context(items: source);

      source.clear();

      expect(context.clock, clock);
      expect(context.orderedItems.map((item) => item.id), ['earlier', 'later']);
      expect(
        () => context.orderedItems.add(_item('new')),
        throwsUnsupportedError,
      );
    });

    test('derives mapped, missing, booked, and known-cost facts', () {
      final context = _context(
        items: [
          _item(
            'mapped',
            latitude: 41,
            longitude: 12,
            isBooked: true,
            cost: 10,
          ),
          _item('missing-latitude', longitude: 12, cost: 15),
          _item('missing-longitude'),
        ],
      );

      expect(context.mappedCount, 1);
      expect(context.missingCoordinateCount, 2);
      expect(context.bookedCount, 1);
      expect(context.knownEstimatedCost, 25);
      expect(context.hasKnownEstimatedCost, isTrue);
      expect(context.isEstimatedCostComplete, isFalse);
    });

    test('derives a next scheduled item from the injected clock', () {
      final context = _context(
        items: [
          _item('past', time: '09:00'),
          _item('next', time: '14:00'),
        ],
      );

      expect(context.nextScheduledItem?.id, 'next');
    });

    test(
      'suppresses next scheduled item when time evidence is insufficient',
      () {
        final context = _context(items: [_item('untimed', time: null)]);

        expect(context.nextScheduledItem, isNull);
      },
    );

    test('suppresses next scheduled item with malformed time evidence', () {
      final context = _context(items: [_item('malformed', time: '25:61')]);

      expect(context.nextScheduledItem, isNull);
    });

    test('requires trusted itinerary-local clock evidence for next item', () {
      final trip = Trip(
        id: 'trip',
        destination: 'Rome',
        departureDate: DateTime(2026, 9, 15),
        returnDate: DateTime(2026, 9, 20),
        travellers: 2,
        notes: '',
        budget: 100,
        currency: 'EUR',
      );
      final item = _item('next', time: '14:00');

      for (final source in [
        JourneyClockSource.deviceLocal,
        JourneyClockSource.unknown,
      ]) {
        expect(
          JourneyContextBuilder.build(
            trip: trip,
            items: [item],
            clock: clock,
            clockSource: source,
          ).nextScheduledItem,
          isNull,
        );
      }
      expect(
        JourneyContextBuilder.build(
          trip: trip,
          items: [item],
          clock: clock,
          clockSource: JourneyClockSource.explicitTripLocal,
        ).nextScheduledItem?.id,
        'next',
      );
    });
  });

  group('deterministic analyzers', () {
    test(
      'reports each trusted trip date-range status without completion claim',
      () {
        expect(
          _messages(
            _analyze(_context(clock: DateTime(2026, 9, 1))),
          ).contains(JourneyInsightMessage.tripUpcoming),
          isTrue,
        );
        expect(
          _messages(
            _analyze(_context()),
          ).contains(JourneyInsightMessage.tripActive),
          isTrue,
        );
        final completed = _analyze(_context(clock: DateTime(2026, 10, 1)));
        expect(
          _messages(completed),
          contains(JourneyInsightMessage.tripDateRangeComplete),
        );
        expect(
          completed.any(
            (insight) =>
                insight.message == JourneyInsightMessage.nextScheduledStop,
          ),
          isFalse,
        );
      },
    );

    test('reports planned stop count and first valid scheduled stop', () {
      final insights = ItinerarySummaryAnalyzer().analyze(
        _context(
          items: [
            _item('untimed', time: null),
            _item('timed', time: '09:00'),
          ],
        ),
      );

      final count = _byMessage(
        insights,
        JourneyInsightMessage.plannedStopCount,
      );
      final first = _byMessage(
        insights,
        JourneyInsightMessage.firstScheduledStop,
      );
      expect(count.supportingData['count'], 2);
      expect(first.supportingData['itemId'], 'timed');
      expect(first.confidence, JourneyInsightConfidence.high);
    });

    test('handles an empty itinerary without a first-stop claim', () {
      final insights = ItinerarySummaryAnalyzer().analyze(
        _context(items: const []),
      );

      expect(
        _byMessage(
          insights,
          JourneyInsightMessage.plannedStopCount,
        ).supportingData['count'],
        0,
      );
      expect(
        insights.any(
          (insight) =>
              insight.message == JourneyInsightMessage.firstScheduledStop,
        ),
        isFalse,
      );
    });

    test(
      'emits a next scheduled item only with reliable schedule evidence',
      () {
        final insights = NextScheduledItemAnalyzer().analyze(
          _context(
            items: [
              _item('past', time: '09:00'),
              _item('next', time: '14:00'),
            ],
          ),
        );

        final next = _byMessage(
          insights,
          JourneyInsightMessage.nextScheduledStop,
        );
        expect(next.supportingData['itemId'], 'next');
        expect(next.actions, [JourneyActionType.reviewStop]);
        expect(next.proactiveEligible, isFalse);
      },
    );

    test('emits one non-urgent missing-coordinate insight when needed', () {
      final insights = MissingCoordinateAnalyzer().analyze(
        _context(
          items: [_item('one'), _item('two', latitude: 41, longitude: 12)],
        ),
      );

      final insight = _byMessage(
        insights,
        JourneyInsightMessage.missingCoordinates,
      );
      expect(insight.supportingData['count'], 1);
      expect(insight.confidence, JourneyInsightConfidence.confirmed);
      expect(insight.severity, JourneyInsightSeverity.normal);
      expect(insight.actions, [
        JourneyActionType.openMap,
        JourneyActionType.editStop,
      ]);
      expect(insight.proactiveEligible, isFalse);
    });

    test(
      'does not emit missing-coordinate insight when all items are mapped',
      () {
        final insights = MissingCoordinateAnalyzer().analyze(
          _context(items: [_item('one', latitude: 41, longitude: 12)]),
        );

        expect(insights, isEmpty);
      },
    );

    test(
      'aggregates multiple missing coordinates into one confirmed insight',
      () {
        final insight = _byMessage(
          MissingCoordinateAnalyzer().analyze(
            _context(
              items: [
                _item('one'),
                _item('two'),
                _item('mapped', latitude: 41, longitude: 12),
              ],
            ),
          ),
          JourneyInsightMessage.missingCoordinates,
        );

        expect(insight.supportingData['count'], 2);
      },
    );

    test('reports only items marked booked and makes no reservation claim', () {
      final insights = BookingFlagAnalyzer().analyze(
        _context(items: [_item('booked', isBooked: true), _item('unbooked')]),
      );

      final booked = _byMessage(
        insights,
        JourneyInsightMessage.markedBookedCount,
      );
      expect(booked.supportingData['count'], 1);
      expect(booked.message, isNot(JourneyInsightMessage.tripActive));
      expect(booked.proactiveEligible, isFalse);
      expect(
        BookingFlagAnalyzer().analyze(_context(items: [_item('unbooked')])),
        isEmpty,
      );
    });

    test(
      'reports known estimates below or equal to budget without an overage claim',
      () {
        final below = BudgetEstimateAnalyzer().analyze(
          _context(items: [_item('cost', cost: 40)], budget: 100),
        );
        final equal = BudgetEstimateAnalyzer().analyze(
          _context(items: [_item('cost', cost: 100)], budget: 100),
        );

        expect(
          _messages(below),
          contains(JourneyInsightMessage.knownEstimatedCost),
        );
        expect(
          _messages(equal),
          contains(JourneyInsightMessage.knownEstimatedCost),
        );
        expect(
          _messages(equal),
          isNot(contains(JourneyInsightMessage.knownEstimatesOverBudget)),
        );
      },
    );

    test(
      'reports known estimate overage without changing budget or currency',
      () {
        final context = _context(
          items: [_item('cost', cost: 120)],
          budget: 100,
        );
        final insight = _byMessage(
          BudgetEstimateAnalyzer().analyze(context),
          JourneyInsightMessage.knownEstimatesOverBudget,
        );

        expect(insight.supportingData['currency'], 'EUR');
        expect(insight.supportingData['budget'], 100);
        expect(insight.supportingData['overBudget'], 20);
        expect(context.trip.budget, 100);
      },
    );

    test('does not claim an overage when the trip has no budget', () {
      final insights = BudgetEstimateAnalyzer().analyze(
        _context(items: [_item('cost', cost: 100)], budget: 0),
      );

      expect(
        _messages(insights),
        contains(JourneyInsightMessage.knownEstimatedCost),
      );
      expect(
        _messages(insights),
        isNot(contains(JourneyInsightMessage.knownEstimatesOverBudget)),
      );
    });

    test(
      'keeps partial known estimates explicitly incomplete and avoids zero-cost claims',
      () {
        final insight = _byMessage(
          BudgetEstimateAnalyzer().analyze(
            _context(items: [_item('known', cost: 25), _item('unknown')]),
          ),
          JourneyInsightMessage.knownEstimatedCost,
        );

        expect(insight.supportingData['knownEstimatedCost'], 25);
        expect(insight.supportingData['isComplete'], isFalse);
      },
    );

    test(
      'does not emit a budget estimate insight when no estimate is known',
      () {
        expect(
          BudgetEstimateAnalyzer().analyze(_context(items: [_item('unknown')])),
          isEmpty,
        );
      },
    );

    test(
      'is deterministic, uses no proactive eligibility, and emits no unsupported categories',
      () {
        final context = _context(
          items: [
            _item(
              'mapped',
              latitude: 41,
              longitude: 12,
              cost: 10,
              isBooked: true,
            ),
          ],
        );
        final first = _analyze(context);
        final second = _analyze(context);

        expect(
          first.map((insight) => insight.id),
          second.map((insight) => insight.id),
        );
        expect(first.every((insight) => !insight.proactiveEligible), isTrue);
        expect(
          first.every(
            (insight) =>
                insight.type != JourneyInsightType.attention ||
                insight.message == JourneyInsightMessage.missingCoordinates ||
                insight.message ==
                    JourneyInsightMessage.knownEstimatesOverBudget,
          ),
          isTrue,
        );
      },
    );
  });
}

JourneyContext _context({
  List<ItineraryItem>? items,
  DateTime? clock,
  double budget = 100,
}) {
  return JourneyContextBuilder.build(
    trip: Trip(
      id: 'trip',
      destination: 'Rome',
      departureDate: DateTime(2026, 9, 15),
      returnDate: DateTime(2026, 9, 20),
      travellers: 2,
      notes: '',
      budget: budget,
      currency: 'EUR',
    ),
    items: items ?? [_item('default', time: '14:00')],
    clock: clock ?? DateTime(2026, 9, 16, 12),
    clockSource: JourneyClockSource.testInjected,
  );
}

ItineraryItem _item(
  String id, {
  String? time = '14:00',
  double? latitude,
  double? longitude,
  bool isBooked = false,
  double? cost,
  int? orderIndex,
}) {
  return ItineraryItem(
    id: id,
    tripId: 'trip',
    title: id,
    date: DateTime(2026, 9, 16),
    time: time,
    location: '',
    category: 'Activity',
    notes: '',
    estimatedCost: cost,
    currency: 'EUR',
    isBooked: isBooked,
    latitude: latitude,
    longitude: longitude,
    orderIndex: orderIndex,
  );
}

List<JourneyInsight> _analyze(JourneyContext context) {
  const analyzers = <JourneyAnalyzer>[
    TripStatusAnalyzer(),
    ItinerarySummaryAnalyzer(),
    NextScheduledItemAnalyzer(),
    MissingCoordinateAnalyzer(),
    BookingFlagAnalyzer(),
    BudgetEstimateAnalyzer(),
  ];

  return analyzers.expand((analyzer) => analyzer.analyze(context)).toList();
}

JourneyInsight _byMessage(
  List<JourneyInsight> insights,
  JourneyInsightMessage message,
) => insights.singleWhere((insight) => insight.message == message);

Iterable<JourneyInsightMessage> _messages(List<JourneyInsight> insights) =>
    insights.map((insight) => insight.message);
