import 'package:flutter_test/flutter_test.dart';
import 'package:itarevo/core/itinerary_ordering.dart';
import 'package:itarevo/core/services/itinerary_optimizer.dart';
import 'package:itarevo/core/services/route_service.dart';
import 'package:itarevo/features/trips/models/itinerary/itinerary_item.dart';

void main() {
  final dayOne = DateTime(2026, 8, 14);
  final dayTwo = DateTime(2026, 8, 15);

  test('loads older records without orderIndex', () {
    final map = _item('a', dayOne, time: '09:00').toMap()..remove('orderIndex');

    final restored = ItineraryItem.fromMap(map);

    expect(restored.orderIndex, isNull);
    expect(restored.id, 'a');
    expect(restored.time, '09:00');
  });

  test('uses deterministic greedy route-duration ordering', () async {
    final items = [
      _item('a', dayOne, latitude: 0, longitude: 0),
      _item('b', dayOne, latitude: 0, longitude: 1),
      _item('c', dayOne, latitude: 0, longitude: 2),
    ];
    final durations = <String, int>{'a|b': 10, 'a|c': 2, 'b|c': 5, 'c|b': 2};

    final result = await ItineraryOptimizer.optimizeDay(
      items: items,
      day: dayOne,
      travelMode: TravelMode.walking,
      routeLookup: (origin, destination, _) async {
        final duration = durations['${origin.id}|${destination.id}'];
        return duration == null ? null : _route(duration);
      },
    );

    expect(result, isNotNull);
    expect(result!.suggestedDayItems.map((item) => item.id), ['a', 'c', 'b']);
    expect(result.currentDurationMinutes, 15);
    expect(result.suggestedDurationMinutes, 4);
    expect(result.savingMinutes, 11);
  });

  test('does not optimize fewer than three mapped stops', () async {
    final result = await ItineraryOptimizer.optimizeDay(
      items: [
        _item('a', dayOne, latitude: 0, longitude: 0),
        _item('b', dayOne, latitude: 0, longitude: 1),
        _item('unmapped', dayOne),
      ],
      day: dayOne,
      travelMode: TravelMode.walking,
      routeLookup: (_, _, _) async => _route(1),
    );

    expect(result, isNull);
  });

  test('falls back deterministically when route lookup fails', () async {
    final result = await ItineraryOptimizer.optimizeDay(
      items: [
        _item('a', dayOne, latitude: 0, longitude: 0),
        _item('c', dayOne, latitude: 0, longitude: 0.02),
        _item('b', dayOne, latitude: 0, longitude: 0.01),
      ],
      day: dayOne,
      travelMode: TravelMode.walking,
      routeLookup: (_, _, _) async => null,
    );

    expect(result!.suggestedDayItems.map((item) => item.id), ['a', 'b', 'c']);
    expect(result.hasReliableDurations, isFalse);
    expect(result.savingMinutes, isNull);
  });

  test('keeps unmapped stops in their existing positions', () async {
    final result = await ItineraryOptimizer.optimizeDay(
      items: [
        _item('a', dayOne, latitude: 0, longitude: 0),
        _item('unmapped', dayOne),
        _item('c', dayOne, latitude: 0, longitude: 2),
        _item('b', dayOne, latitude: 0, longitude: 1),
      ],
      day: dayOne,
      travelMode: TravelMode.walking,
      routeLookup: (origin, destination, _) async {
        const durations = {'a|b': 1, 'a|c': 10, 'b|c': 1, 'c|b': 1};
        final duration = durations['${origin.id}|${destination.id}'];
        return duration == null ? null : _route(duration);
      },
    );

    expect(result!.suggestedDayItems.map((item) => item.id), [
      'a',
      'unmapped',
      'b',
      'c',
    ]);
    expect(result.suggestedDayItems[1].latitude, isNull);
  });

  test('only returns items from the selected day', () async {
    final otherDayItem = _item('other-day', dayTwo, latitude: 0, longitude: 3);
    final allItems = [
      _item('a', dayOne, latitude: 0, longitude: 0),
      _item('b', dayOne, latitude: 0, longitude: 1),
      _item('c', dayOne, latitude: 0, longitude: 2),
      otherDayItem,
    ];

    final result = await ItineraryOptimizer.optimizeDay(
      items: allItems,
      day: dayOne,
      travelMode: TravelMode.walking,
      routeLookup: (_, _, _) async => _route(1),
    );

    expect(result!.suggestedDayItems, hasLength(3));
    expect(
      result.suggestedDayItems.any((item) => item.id == otherDayItem.id),
      isFalse,
    );
    expect(allItems.last, same(otherDayItem));
  });

  test('preserves activity times while changing order', () async {
    final items = [
      _item('a', dayOne, time: '09:00', latitude: 0, longitude: 0),
      _item('b', dayOne, time: '10:00', latitude: 0, longitude: 1),
      _item('c', dayOne, time: '11:00', latitude: 0, longitude: 2),
    ];
    final originalTimes = {for (final item in items) item.id: item.time};

    final result = await ItineraryOptimizer.optimizeDay(
      items: items,
      day: dayOne,
      travelMode: TravelMode.walking,
      routeLookup: (origin, destination, _) async {
        const durations = {'a|b': 10, 'a|c': 1, 'c|b': 1, 'b|c': 10};
        return _route(durations['${origin.id}|${destination.id}'] ?? 20);
      },
    );

    for (final item in result!.suggestedDayItems) {
      expect(item.time, originalTimes[item.id]);
    }
  });

  test('persists and restores optimized ordering semantics', () {
    final optimized = [
      _item('a', dayOne, time: '09:00').copyWith(orderIndex: 0),
      _item('c', dayOne, time: '11:00').copyWith(orderIndex: 1),
      _item('b', dayOne, time: '10:00').copyWith(orderIndex: 2),
    ];
    final restored =
        optimized.map((item) => ItineraryItem.fromJson(item.toJson())).toList()
          ..shuffle();

    expect(orderItineraryItems(restored).map((item) => item.id), [
      'a',
      'c',
      'b',
    ]);
    expect(restored.every((item) => item.orderIndex != null), isTrue);
  });
}

ItineraryItem _item(
  String id,
  DateTime date, {
  String? time,
  double? latitude,
  double? longitude,
}) {
  return ItineraryItem(
    id: id,
    tripId: 'trip',
    title: id.toUpperCase(),
    date: date,
    time: time,
    location: '',
    category: 'Activity',
    notes: '',
    currency: 'GBP',
    isBooked: false,
    latitude: latitude,
    longitude: longitude,
  );
}

RouteResult _route(int durationMinutes) => RouteResult(
  durationMinutes: durationMinutes,
  distanceMetres: durationMinutes * 100,
  points: const [],
);
