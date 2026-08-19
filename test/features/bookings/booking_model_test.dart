import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/core/models/booking.dart';

void main() {
  group('Booking Model', () {
    test('flight booking serialization', () {
      final booking = Booking.flight(
        id: '123',
        tripId: 'trip_1',
        userId: 'user_1',
        amount: 299.99,
        currency: 'USD',
        metadata: {
          'airline': 'Test Air',
          'flightNumber': 'TA123',
        },
      );

      final json = booking.toJson();
      expect(json['id'], '123');
      expect(json['type'], 'flight');
      expect(json['amount'], 299.99);
      expect(json['metadata']['airline'], 'Test Air');

      final fromJson = Booking.fromJson(json);
      expect(fromJson, booking);
    });

    test('hotel booking serialization', () {
      final booking = Booking.hotel(
        id: 'h1',
        tripId: 'trip_1',
        userId: 'user_1',
        amount: 450.0,
        currency: 'EUR',
        metadata: {
          'hotelName': 'Grand Hotel',
          'city': 'Paris',
        },
      );

      final json = booking.toJson();
      expect(json['type'], 'hotel');
      expect(json['metadata']['hotelName'], 'Grand Hotel');

      final fromJson = Booking.fromJson(json);
      expect(fromJson, booking);
    });
  });
}
