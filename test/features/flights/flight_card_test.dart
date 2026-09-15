import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_super_app/app/app_routes.dart';
import 'package:travel_super_app/features/flights/models/flight.dart';
import 'package:travel_super_app/features/flights/pages/flight_details_page.dart';
import 'package:travel_super_app/features/flights/providers/flight_provider.dart';
import 'package:travel_super_app/features/flights/widgets/flight_card.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_provider.dart';

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

    testWidgets('FlightCard displays airline logo',
        (WidgetTester tester) async {
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

    testWidgets('FlightCard has a View Details CTA and no Book Flight CTA',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlightCard(flight: testFlight),
          ),
        ),
      );

      expect(find.text('View Details'), findsOneWidget);
      expect(find.text('Book Flight'), findsNothing);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('FlightCard View Details CTA opens flight details route',
        (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: FlightCard(flight: testFlight),
            ),
          ),
          GoRoute(
            name: AppRoute.flightDetails.routeName,
            path: AppRoute.flightDetails.path,
            builder: (context, state) => const Scaffold(
              body: Text('Details opened'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.tap(find.text('View Details'));
      await tester.pumpAndSettle();

      expect(find.text('Details opened'), findsOneWidget);
    });

    testWidgets('FlightCard omits internal backend fallback source label',
        (WidgetTester tester) async {
      final backendFlight = Flight(
        id: 'flight-backend',
        airline: 'British Airways',
        airlineLogo: '',
        flightNumber: 'BA123',
        origin: 'LHR',
        destination: 'CDG',
        departureAt: '2026-08-20T08:00:00',
        arrivalAt: '2026-08-20T12:35:00',
        duration: 'PT4H35M',
        stops: 0,
        amount: 245.50,
        currency: 'GBP',
        dataSource: FlightDataSource.backend,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlightCard(flight: backendFlight),
          ),
        ),
      );

      expect(find.text('Backend fallback data'), findsNothing);
    });

    testWidgets('FlightDetails exposes truthful actions only',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isFlightSavedProvider.overrideWith((ref, flightId) async => false),
            tripsProvider.overrideWith((ref) => Stream.value(const [])),
          ],
          child: MaterialApp(
            home: FlightDetailsPage(flight: testFlight),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Save Flight'), findsOneWidget);
      expect(find.text('Add to trip'), findsOneWidget);
      expect(find.text('Book Flight'), findsNothing);
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
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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
