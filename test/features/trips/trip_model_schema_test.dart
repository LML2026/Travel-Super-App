import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/trips/models/trip.dart';

void main() {
  test('toCreateMap and toUpdateMap include status field', () {
    final trip = Trip(
      id: 'trip-1',
      destination: 'Paris',
      startDate: DateTime(2026, 8, 20),
      endDate: DateTime(2026, 8, 25),
      budget: 1500,
      currency: 'GBP',
      travellers: 2,
      notes: 'Anniversary trip',
      createdAt: DateTime(2026, 7, 26),
      status: 'planned',
    );

    final createMap = trip.toCreateMap();
    final updateMap = trip.toUpdateMap();

    expect(createMap['status'], 'planned');
    expect(updateMap['status'], 'planned');
  });
}
