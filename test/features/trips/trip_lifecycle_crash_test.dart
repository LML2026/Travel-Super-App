import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_super_app/app/route_groups/trip_routes.dart';
import 'package:travel_super_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip_activity.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_repository.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_activity_repository.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_provider.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_activity_provider.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_document_provider.dart';
import 'package:travel_super_app/features/flights/providers/flight_provider.dart';
import 'package:travel_super_app/features/hotels/providers/hotel_provider.dart';
import 'package:travel_super_app/features/weather/providers/weather_provider.dart';
import 'package:travel_super_app/features/weather/models/weather_data.dart';
import 'package:mocktail/mocktail.dart';

class MockTripRepository extends Mock implements TripRepository {}
class MockTripActivityRepository extends Mock implements TripActivityRepository {}

void main() {
  late MockTripRepository mockTripRepository;
  late MockTripActivityRepository mockActivityRepository;

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
    mockActivityRepository = MockTripActivityRepository();
  });

  testWidgets('Should not crash when tripActivitiesProvider updates while on Dashboard',
      (tester) async {
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
    );

    // Mock trip loading
    when(() => mockTripRepository.get('trip-123'))
        .thenAnswer((_) async => trip);
    when(() => mockTripRepository.watchTrips())
        .thenAnswer((_) => Stream.value([trip]));

    // Mock activities - start with empty
    final activityController = StreamController<List<TripActivity>>.broadcast();
    when(() => mockActivityRepository.watchActivities('trip-123'))
        .thenAnswer((_) => activityController.stream);

    final router = GoRouter(
      initialLocation: '/trips/trip-123',
      routes: buildTripRoutes(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripRepositoryProvider.overrideWithValue(mockTripRepository),
          tripActivityRepositoryProvider.overrideWithValue(mockActivityRepository),
          savedFlightsProvider.overrideWith((ref) => Stream.value([])),
          savedHotelsProvider.overrideWith((ref) => Stream.value([])),
          tripDocumentsProvider('trip-123').overrideWith((ref) => Stream.value([])),
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

    // Wait for resolver and page load
    await tester.pump(); // FutureBuilder starts
    await tester.pump(const Duration(milliseconds: 100)); // Future completes
    await tester.pump(); // Widget rebuilds with data

    // Send initial empty activities
    activityController.add([]);
    await tester.pump();

    await tester.pumpAndSettle();

    expect(find.text('Trip Dashboard'), findsOneWidget);

    // Ensure ActivitiesCard is visible
    final activitiesFinder = find.text('Activities');
    await tester.scrollUntilVisible(activitiesFinder, 500);

    expect(find.textContaining('No activities planned yet'), findsOneWidget);

    // Simulate activity update
    activityController.add([
      TripActivity(
        id: 'act-1',
        tripId: 'trip-123',
        title: 'Colosseum Visit',
        createdAt: DateTime.now(),
      ),
    ]);

    // Trigger rebuild
    await tester.pump();

    // If there's a crash, this will throw or show error widget
    final exception = tester.takeException();
    if (exception != null) {
        fail('Caught exception: $exception');
    }

    expect(find.text('Trip Dashboard'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.textContaining('Colosseum Visit'), findsOneWidget);

    await activityController.close();
  });
}
