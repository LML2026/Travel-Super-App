import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/trips/models/trip.dart';
import 'package:travel_super_app/features/trips/widgets/trip_card.dart';

void main() {
  testWidgets('TripCard shows destination, budget and travellers', (tester) async {
    final trip = Trip(
      id: 'trip-1',
      destination: 'Paris',
      startDate: DateTime(2026, 9, 14),
      endDate: DateTime(2026, 9, 18),
      budget: 1250,
      currency: 'GBP',
      createdAt: DateTime(2026, 7, 26),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TripCard(
            trip: trip,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Paris'), findsOneWidget);
    expect(find.text('Budget £1,250'), findsOneWidget);
    expect(find.text('1 Traveller'), findsOneWidget);
    expect(find.text('View itinerary →'), findsOneWidget);
  });
}
