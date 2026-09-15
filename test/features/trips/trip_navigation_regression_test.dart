import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_super_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:travel_super_app/features/expenses/presentation/providers/expense_provider.dart';
import 'package:travel_super_app/features/flights/providers/flight_provider.dart';
import 'package:travel_super_app/features/hotels/providers/hotel_provider.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_repository.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_provider.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_document_provider.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_activity_provider.dart';
import 'package:travel_super_app/features/trips/presentation/screens/trip_list_page.dart';
import 'package:travel_super_app/features/trips/presentation/screens/trip_dashboard_page.dart';
import 'package:travel_super_app/features/weather/models/weather_data.dart';
import 'package:travel_super_app/features/weather/providers/weather_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockTripRepository extends Mock implements TripRepository {}

void main() {
  late MockTripRepository mockTripRepository;

  setUpAll(() {
    registerFallbackValue(
      Trip(
        id: '1',
        title: 'Test',
        destination: 'Test',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        budget: 0,
      ),
    );
  });

  setUp(() {
    mockTripRepository = MockTripRepository();
  });

  testWidgets('Navigation from TripList to Dashboard and Add Activity via GoRouter',
      (tester) async {
    // Set a larger surface size to ensure all components are visible or scrollable without hit-test warnings
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
    });

    final trip = Trip(
      id: 'trip-123',
      title: 'Rome Trip',
      destination: 'Rome',
      startDate: DateTime(2026, 8, 20),
      endDate: DateTime(2026, 8, 25),
      budget: 1500,
      currency: 'EUR',
      travellers: 1,
    );

    when(() => mockTripRepository.watchTrips())
        .thenAnswer((_) => Stream.value([trip]));
    when(() => mockTripRepository.get('trip-123'))
        .thenAnswer((_) async => trip);

    final router = GoRouter(
      initialLocation: '/trips',
      routes: [
        GoRoute(
          path: '/trips',
          name: 'trips',
          builder: (context, state) => const TripListPage(),
        ),
        GoRoute(
          path: '/trips/:id',
          name: 'tripDetails',
          builder: (context, state) => TripDashboardPage(trip: trip),
        ),
        GoRoute(
          path: '/trips/:id/activities',
          name: 'tripActivities',
          builder: (context, state) => const Scaffold(body: Text('Activities Page')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripRepositoryProvider.overrideWithValue(mockTripRepository),
          savedFlightsProvider.overrideWith((ref) => Stream.value([])),
          savedHotelsProvider.overrideWith((ref) => Stream.value([])),
          tripExpensesProvider('trip-123').overrideWith((ref) => Stream.value([])),
          tripDocumentsProvider('trip-123').overrideWith((ref) => Stream.value([])),
          tripActivitiesProvider('trip-123').overrideWith((ref) => Stream.value([])),
          weatherProvider('Rome').overrideWith((ref) async => const WeatherData(
            city: 'Rome', country: 'Italy', tempC: 30, tempF: 86,
            description: 'Sunny', iconCode: '01d', humidity: 40, windKph: 10, condition: 'sunny'
          )),
          immediateCurrentUserProvider.overrideWithValue(null),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify we are on Trip List
    expect(find.text('My Trips'), findsOneWidget);

    // 2. Tap Trip Card to go to Dashboard
    await tester.tap(find.text('Rome'));
    await tester.pumpAndSettle();

    // 3. Verify we are on Dashboard
    expect(find.text('Trip Dashboard'), findsOneWidget);

    // 4. Tap Add Activity
    final addButton = find.text('Add Activity');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);

    await tester.pumpAndSettle();

    // 5. Verify we reached Activities Page without crash
    expect(find.text('Activities Page'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
