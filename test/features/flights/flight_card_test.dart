import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/flights/models/flight.dart';
import 'package:travel_super_app/features/flights/widgets/flight_card.dart';

void main() {
  group('FlightCard Widget Tests', () {
    final testFlight = Flight(
      id: 'flight-1',
      airline: 'British Airways',
      airlineLogo: 'https://images.kiwi.com/airlines/64/BA.png',
      flightNumber: 'BA123',
      origin: 'LHR',
      destination: 'CDG',
      departureAt: '2026-08-20T08:00:00',
      arrivalAt: '2026-08-20T12:35:00',
      duration: 'PT4H35M',
      stops: 0,
      amount: 245.50,
      currency: 'GBP',
    );

    testWidgets('FlightCard displays flight information correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlightCard(flight: testFlight),
          ),
        ),
      );

      // Verify airline name is displayed
      expect(find.text('British Airways'), findsOneWidget);

      // Verify price is displayed (format: "GBP 245.50")
      expect(find.text('GBP 245.50'), findsOneWidget);

      // Verify origin/destination
      expect(find.text('LHR'), findsOneWidget);
      expect(find.text('CDG'), findsOneWidget);

      // Verify direct flight indicator (with emoji)
      expect(find.text('🟢 Direct'), findsOneWidget);
    });

    testWidgets('FlightCard shows stop information for connecting flights',
        (WidgetTester tester) async {
      final connectingFlight = Flight(
        id: 'flight-2',
        airline: 'Lufthansa',
        airlineLogo: 'https://images.kiwi.com/airlines/64/LH.png',
        flightNumber: 'LH456',
        origin: 'LHR',
        destination: 'BER',
        departureAt: '2026-08-20T10:00:00',
        arrivalAt: '2026-08-20T18:00:00',
        duration: 'PT8H00M',
        stops: 1,
        amount: 180.00,
        currency: 'GBP',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlightCard(flight: connectingFlight),
          ),
        ),
      );

      // Verify connecting flight info
      expect(find.text('Lufthansa'), findsOneWidget);
      expect(find.text('🟠 1 Stop'), findsOneWidget);
      expect(find.text('GBP 180.00'), findsOneWidget);
    });

    testWidgets('FlightCard displays airline logo', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlightCard(flight: testFlight),
          ),
        ),
      );

      // Verify Image widget exists (logo)
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('FlightCard has a book button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlightCard(flight: testFlight),
          ),
        ),
      );

      // Verify book button exists
      expect(find.text('Book Flight'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('FlightCard book button shows snackbar on tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlightCard(flight: testFlight),
          ),
        ),
      );

      // Tap the book button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify snackbar shows booking message with flight number
      expect(find.text('Booking BA123 - Coming soon!'), findsOneWidget);
    });

    testWidgets('FlightCard displays multiple stops correctly',
        (WidgetTester tester) async {
      final multiStopFlight = Flight(
        id: 'flight-3',
        airline: 'Turkish Airlines',
        airlineLogo: 'https://images.kiwi.com/airlines/64/TK.png',
        flightNumber: 'TK789',
        origin: 'LHR',
        destination: 'IST',
        departureAt: '2026-08-20T06:00:00',
        arrivalAt: '2026-08-20T22:00:00',
        duration: 'PT16H00M',
        stops: 2,
        amount: 150.00,
        currency: 'GBP',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlightCard(flight: multiStopFlight),
          ),
        ),
      );

      expect(find.text('🟠 2 Stops'), findsOneWidget);
      expect(find.text('GBP 150.00'), findsOneWidget);
    });

    testWidgets('FlightCard layout is responsive', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1200, 2400);
      tester.binding.window.devicePixelRatioTestValue = 3.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlightCard(flight: testFlight),
          ),
        ),
      );

      // Verify widget renders without overflow
      expect(find.byType(FlightCard), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });
  });
}
