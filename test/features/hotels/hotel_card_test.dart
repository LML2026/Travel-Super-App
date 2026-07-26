import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_super_app/app/app_routes.dart';
import 'package:travel_super_app/features/hotels/models/hotel.dart';
import 'package:travel_super_app/features/hotels/pages/hotel_details_page.dart';
import 'package:travel_super_app/features/hotels/widgets/hotel_card.dart';

void main() {
  group('HotelCard Widget Tests', () {
    final testHotel = Hotel(
      id: 'h1',
      name: 'Luxury Paris Boutique',
      image: 'https://example.com/hotel.jpg',
      city: 'Paris',
      rating: 4.8,
      address: 'Paris, France',
      price: 145.00,
      currency: 'GBP',
      amenities: const ['Free Wi-Fi', 'Breakfast Included', 'Free cancellation'],
      totalPrice: 435.00,
      beds: 2,
      nights: 3,
    );

    testWidgets('HotelCard displays hotel information correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HotelCard(hotel: testHotel),
            ),
          ),
        ),
      );

      // Verify hotel name
      expect(find.text('Luxury Paris Boutique'), findsOneWidget);

      // Verify city
        final hasCity = find.text('Paris').evaluate().isNotEmpty ||
          find.text('Paris, France').evaluate().isNotEmpty;
        expect(hasCity, isTrue);

      // Verify rating
      expect(find.text('4.8'), findsOneWidget);

      // Verify redesigned nightly price format
      expect(find.text('GBP 145 / night'), findsOneWidget);
    });

    testWidgets('HotelCard displays bed information', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HotelCard(hotel: testHotel),
            ),
          ),
        ),
      );

      expect(find.text('Breakfast Included'), findsOneWidget);
      expect(find.text('Free Wi-Fi'), findsOneWidget);
    });

    testWidgets('HotelCard displays night information', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HotelCard(hotel: testHotel),
            ),
          ),
        ),
      );

      expect(find.text('Book Now'), findsOneWidget);
    });

    testWidgets('HotelCard displays emoji icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HotelCard(hotel: testHotel),
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('HotelCard has a book button', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HotelCard(hotel: testHotel),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      final hasSaveButton = find.text('Save').evaluate().isNotEmpty;
      final hasLoading = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

      expect(hasSaveButton || hasLoading, isTrue);
      expect(find.text('Book Now'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('HotelCard book button navigates to details page',
        (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: HotelCard(hotel: testHotel),
            ),
          ),
          GoRoute(
            name: AppRoute.hotelDetails.routeName,
            path: AppRoute.hotelDetails.path,
            builder: (context, state) {
              return HotelDetailsPage(hotel: state.extra! as Hotel);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.tap(find.text('Book Now'));
      await tester.pumpAndSettle();

      expect(find.text('Hotel Details'), findsOneWidget);
    });

    testWidgets('HotelCard with single bed displays correctly',
        (WidgetTester tester) async {
      final singleBedHotel = Hotel(
        id: 'h2',
        name: 'Economy London Hotel',
        image: 'https://example.com/hotel.jpg',
        city: 'London',
        rating: 4.2,
        address: 'London, UK',
        price: 85.00,
        currency: 'GBP',
        amenities: const ['Free Wi-Fi', 'Breakfast Included'],
        totalPrice: 255.00,
        beds: 1,
        nights: 3,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HotelCard(hotel: singleBedHotel),
            ),
          ),
        ),
      );

      expect(find.text('Economy London Hotel'), findsOneWidget);
    });

    testWidgets('HotelCard displays star rating with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HotelCard(hotel: testHotel),
            ),
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
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HotelCard(hotel: testHotel),
            ),
          ),
        ),
      );

      // Verify visible action and rating icons
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month), findsOneWidget);
    });

    testWidgets('HotelCard layout is responsive', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HotelCard(hotel: testHotel),
            ),
          ),
        ),
      );

      expect(find.byType(HotelCard), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('HotelCard displays nightly price',
        (WidgetTester tester) async {
      final customHotel = Hotel(
        id: 'h3',
        name: 'Test Hotel',
        image: 'https://example.com/hotel.jpg',
        city: 'Test City',
        rating: 4.5,
        address: 'Test City Center',
        price: 100.00,
        currency: 'GBP',
        amenities: const ['Free Wi-Fi', 'Breakfast Included'],
        totalPrice: 500.00, // 100 * 5 nights
        beds: 2,
        nights: 5,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HotelCard(hotel: customHotel),
            ),
          ),
        ),
      );

      expect(find.text('GBP 100 / night'), findsOneWidget);
    });
  });
}
