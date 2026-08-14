import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:itarevo/core/services/trip_map_projection.dart';
import 'package:itarevo/core/storage/trip_storage_service.dart';
import 'package:itarevo/features/trips/models/itinerary/itinerary_item.dart';
import 'package:itarevo/features/trips/models/trip.dart';

void main() {
  group('trip currency', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    for (final currency in const ['GBP', 'EUR', 'USD']) {
      test('$currency survives SharedPreferences persistence', () async {
        final storage = TripStorageService();
        await storage.saveTrips([_trip(currency)]);

        final reopened = await storage.loadTrips();

        expect(reopened.single.currency, currency);
        expect(reopened.single.budget, 1250);
      });
    }

    test(
      'changing currency preserves the numeric budget when reopened',
      () async {
        final storage = TripStorageService();
        await storage.saveTrips([_trip('GBP')]);
        final original = (await storage.loadTrips()).single;

        await storage.saveTrips([original.copyWith(currency: 'EUR')]);
        final reopened = (await storage.loadTrips()).single;

        expect(reopened.currency, 'EUR');
        expect(reopened.budget, 1250);
      },
    );
  });

  group('multi-day trip map projection', () {
    test('includes every valid mapped item across all days', () {
      final items = [
        _item('day-1-a', day: 1, latitude: 51.50, longitude: -0.12),
        _item('day-1-b', day: 1, latitude: 51.51, longitude: -0.13),
        _item('day-2-a', day: 2, latitude: 51.52, longitude: -0.14),
        _item('day-3-a', day: 3, latitude: 51.53, longitude: -0.15),
      ];

      final projection = TripMapProjection.fromItems(items);

      expect(projection.mappedItems.map((item) => item.id), [
        'day-1-a',
        'day-1-b',
        'day-2-a',
        'day-3-a',
      ]);
    });

    test('assigns distinct marker keys to duplicate legacy item IDs', () {
      final first = _item(
        'duplicate',
        day: 1,
        latitude: 51.50,
        longitude: -0.12,
      );
      final second = _item(
        'duplicate',
        day: 2,
        latitude: 51.52,
        longitude: -0.14,
      );
      final projection = TripMapProjection.fromItems([first, second]);

      expect(projection.mappedItems, hasLength(2));
      expect(
        TripMapProjection.markerKey(projection.mappedItems[0], 0),
        isNot(TripMapProjection.markerKey(projection.mappedItems[1], 1)),
      );
    });

    test('never creates a route pair across day boundaries', () {
      final projection = TripMapProjection.fromItems([
        _item('day-1-a', day: 1, latitude: 51.50, longitude: -0.12),
        _item('day-1-b', day: 1, latitude: 51.51, longitude: -0.13),
        _item('day-2-a', day: 2, latitude: 51.52, longitude: -0.14),
        _item('day-2-b', day: 2, latitude: 51.53, longitude: -0.15),
      ]);

      expect(
        projection.routePairs.map(
          (pair) => '${pair.origin.id}->${pair.destination.id}',
        ),
        ['day-1-a->day-1-b', 'day-2-a->day-2-b'],
      );
    });

    test('respects optimized order within a day', () {
      final projection = TripMapProjection.fromItems([
        _item(
          'chronologically-first',
          day: 1,
          time: '09:00',
          orderIndex: 2,
          latitude: 51.50,
          longitude: -0.12,
        ),
        _item(
          'optimized-first',
          day: 1,
          time: '11:00',
          orderIndex: 0,
          latitude: 51.51,
          longitude: -0.13,
        ),
        _item(
          'optimized-second',
          day: 1,
          time: '10:00',
          orderIndex: 1,
          latitude: 51.52,
          longitude: -0.14,
        ),
      ]);

      expect(projection.mappedItems.map((item) => item.id), [
        'optimized-first',
        'optimized-second',
        'chronologically-first',
      ]);
    });

    test('excludes unmapped items only from map markers', () {
      final mapped = _item('mapped', day: 1, latitude: 51.50, longitude: -0.12);
      final unmapped = _item('unmapped', day: 1);

      final projection = TripMapProjection.fromItems([mapped, unmapped]);

      expect(projection.orderedItems, hasLength(2));
      expect(projection.orderedItems.map((item) => item.id), [
        'mapped',
        'unmapped',
      ]);
      expect(projection.mappedItems.map((item) => item.id), ['mapped']);
      expect(projection.routePairs, isEmpty);
    });

    test('filters invalid coordinates without losing itinerary items', () {
      final projection = TripMapProjection.fromItems([
        _item('valid', day: 1, latitude: 51.50, longitude: -0.12),
        _item('invalid', day: 2, latitude: 95, longitude: -0.13),
      ]);

      expect(projection.orderedItems, hasLength(2));
      expect(projection.mappedItems.map((item) => item.id), ['valid']);
    });
  });
}

Trip _trip(String currency) => Trip(
  id: 'trip',
  destination: 'London',
  departureDate: DateTime(2026, 9, 1),
  returnDate: DateTime(2026, 9, 5),
  travellers: 2,
  notes: '',
  budget: 1250,
  currency: currency,
);

ItineraryItem _item(
  String id, {
  required int day,
  String? time,
  int? orderIndex,
  double? latitude,
  double? longitude,
}) => ItineraryItem(
  id: id,
  tripId: 'trip',
  title: id,
  date: DateTime(2026, 9, day),
  time: time,
  location: '',
  category: 'Attraction',
  notes: '',
  currency: 'GBP',
  isBooked: false,
  latitude: latitude,
  longitude: longitude,
  orderIndex: orderIndex,
);
