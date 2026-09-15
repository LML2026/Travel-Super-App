import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_super_app/app/app_routes.dart';
import 'package:travel_super_app/features/hotels/models/hotel.dart';
import 'package:travel_super_app/features/hotels/pages/hotel_details_page.dart';
import 'package:travel_super_app/features/hotels/providers/hotel_provider.dart';
import 'package:travel_super_app/features/hotels/widgets/hotel_card.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_provider.dart';

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
      amenities: const [
        'Free Wi-Fi',
        'Breakfast Included',
        'Free cancellation'
      ],
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
      expect(find.text('Demo hotel data'), findsOneWidget);
    });

    testWidgets('HotelCard displays bed information',
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

      expect(find.text('Breakfast Included'), findsOneWidget);
      expect(find.text('Free Wi-Fi'), findsOneWidget);
    });

    testWidgets('HotelCard displays View Details CTA',
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

      expect(find.text('View Details'), findsOneWidget);
      expect(find.text('Book Now'), findsNothing);
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

    testWidgets('HotelCard has Save and View Details actions',
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

      await tester.pump(const Duration(milliseconds: 50));
      final hasSaveButton = find.text('Save').evaluate().isNotEmpty;
      final hasLoading =
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

      expect(hasSaveButton || hasLoading, isTrue);
      expect(find.text('View Details'), findsOneWidget);
      expect(find.text('Book Now'), findsNothing);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('HotelCard View Details button navigates to details page',
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

      await tester.tap(find.text('View Details'));
      await tester.pumpAndSettle();

      expect(find.text('Hotel Details'), findsOneWidget);
    });

    testWidgets('HotelCard omits internal backend source label',
        (WidgetTester tester) async {
      final backendHotel = Hotel(
        id: 'backend-hotel',
        name: 'Backend Paris Hotel',
        image: 'https://example.com/hotel.jpg',
        city: 'Paris',
        rating: 4.6,
        address: 'Paris, France',
        price: 180,
        currency: 'GBP',
        amenities: const ['Free Wi-Fi'],
        dataSource: HotelDataSource.backend,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HotelCard(hotel: backendHotel),
            ),
          ),
        ),
      );

      expect(find.text('Backend hotel data'), findsNothing);
    });

    testWidgets('HotelCard keeps demo data disclosure',
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

      expect(find.text('Demo hotel data'), findsOneWidget);
    });

    testWidgets('HotelDetails exposes truthful actions only',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isHotelSavedProvider.overrideWith((ref, hotelId) async => false),
            tripsProvider.overrideWith((ref) => Stream.value(const [])),
          ],
          child: MaterialApp(
            home: HotelDetailsPage(hotel: testHotel),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Save Hotel'), findsOneWidget);
      expect(find.text('Add to trip'), findsOneWidget);
      expect(find.text('Book Now'), findsNothing);
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

    testWidgets('HotelCard displays star rating with icon',
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

      // Verify star icon exists
      expect(find.byIcon(Icons.star), findsOneWidget);

      // Verify rating value
      expect(find.text('4.8'), findsOneWidget);
    });

    testWidgets('HotelCard displays all required icons',
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

      // Verify visible action and rating icons
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('HotelCard layout is responsive', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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
