import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/hotels/models/hotel.dart';
import 'package:travel_super_app/features/hotels/widgets/hotel_card.dart';

void main() {
  group('HotelCard Widget Tests', () {
    final testHotel = Hotel(
      id: 'h1',
      name: 'Luxury Paris Boutique',
      city: 'Paris',
      rating: 4.8,
      pricePerNight: 145.00,
      totalPrice: 435.00,
      beds: 2,
      image: '🏨',
      nights: 3,
    );

    testWidgets('HotelCard displays hotel information correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotelCard(hotel: testHotel),
          ),
        ),
      );

      // Verify hotel name
      expect(find.text('Luxury Paris Boutique'), findsOneWidget);

      // Verify city
      expect(find.text('Paris'), findsOneWidget);

      // Verify rating
      expect(find.text('4.8'), findsOneWidget);

      // Verify total price
      expect(find.text('\$435'), findsOneWidget);

      // Verify price per night
      expect(find.text('\$145/night'), findsOneWidget);
    });

    testWidgets('HotelCard displays bed information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotelCard(hotel: testHotel),
          ),
        ),
      );

      expect(find.text('2 beds'), findsOneWidget);
    });

    testWidgets('HotelCard displays night information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotelCard(hotel: testHotel),
          ),
        ),
      );

      expect(find.text('3 nights'), findsOneWidget);
    });

    testWidgets('HotelCard displays emoji icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotelCard(hotel: testHotel),
          ),
        ),
      );

      expect(find.text('🏨'), findsOneWidget);
    });

    testWidgets('HotelCard has a book button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotelCard(hotel: testHotel),
          ),
        ),
      );

      expect(find.text('Book Now'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('HotelCard book button shows snackbar on tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotelCard(hotel: testHotel),
          ),
        ),
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Luxury Paris Boutique - Booking coming soon!'), findsOneWidget);
    });

    testWidgets('HotelCard with single bed displays correctly',
        (WidgetTester tester) async {
      final singleBedHotel = Hotel(
        id: 'h2',
        name: 'Economy London Hotel',
        city: 'London',
        rating: 4.2,
        pricePerNight: 85.00,
        totalPrice: 255.00,
        beds: 1,
        image: '🏨',
        nights: 3,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotelCard(hotel: singleBedHotel),
          ),
        ),
      );

      expect(find.text('1 bed'), findsOneWidget);
      expect(find.text('Economy London Hotel'), findsOneWidget);
    });

    testWidgets('HotelCard displays star rating with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotelCard(hotel: testHotel),
          ),
        ),
      );

      // Verify star icon exists
      expect(find.byIcon(Icons.star), findsOneWidget);

      // Verify rating value
      expect(find.text('4.8'), findsOneWidget);
    });

    testWidgets('HotelCard displays all required icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotelCard(hotel: testHotel),
          ),
        ),
      );

      // Verify location icon
      expect(find.byIcon(Icons.location_on), findsOneWidget);

      // Verify bed icon
      expect(find.byIcon(Icons.bed), findsOneWidget);

      // Verify nights icon
      expect(find.byIcon(Icons.nights_stay), findsOneWidget);
    });

    testWidgets('HotelCard layout is responsive', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotelCard(hotel: testHotel),
          ),
        ),
      );

      expect(find.byType(HotelCard), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('HotelCard displays correct total price calculation',
        (WidgetTester tester) async {
      final customHotel = Hotel(
        id: 'h3',
        name: 'Test Hotel',
        city: 'Test City',
        rating: 4.5,
        pricePerNight: 100.00,
        totalPrice: 500.00, // 100 * 5 nights
        beds: 2,
        image: '🏨',
        nights: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotelCard(hotel: customHotel),
          ),
        ),
      );

      expect(find.text('\$500'), findsOneWidget);
      expect(find.text('\$100/night'), findsOneWidget);
      expect(find.text('5 nights'), findsOneWidget);
    });
  });
}
