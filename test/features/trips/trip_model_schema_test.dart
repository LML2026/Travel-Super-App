import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/trips/data/models/trip_model.dart';

void main() {
  test('TripModel serialization includes status and title fields', () {
    final trip = TripModel(
      id: 'trip-1',
      title: 'Paris Getaway',
      destination: 'Paris',
      startDate: DateTime(2026, 8, 20),
      endDate: DateTime(2026, 8, 25),
      budget: 1500,
      notes: 'Anniversary trip',
    );

    final json = trip.toJson();

    expect(json['title'], 'Paris Getaway');
    expect(json['destination'], 'Paris');
  });
}
