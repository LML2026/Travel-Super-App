import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_super_app/app/app_routes.dart';
import 'package:travel_super_app/core/theme/app_theme.dart';
import 'package:travel_super_app/features/discovery/data/travel_discovery_service.dart';
import 'package:travel_super_app/features/discovery/presentation/providers/travel_discovery_provider.dart';
import 'package:travel_super_app/features/discovery/presentation/screens/travel_discovery_page.dart';
import 'package:travel_super_app/features/nearby/presentation/nearby_essentials_page.dart';
import 'package:travel_super_app/features/saved_items/data/saved_items_repository.dart';
import 'package:travel_super_app/features/saved_items/presentation/providers/saved_items_provider.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_repository.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_provider.dart';

void main() {
  testWidgets('Discover exposes Nearby Essentials and keeps search scope',
      (tester) async {
    final router = GoRouter(
      initialLocation: AppRoute.travelDiscovery.path,
      routes: [
        GoRoute(
          name: AppRoute.travelDiscovery.routeName,
          path: AppRoute.travelDiscovery.path,
          builder: (context, state) => const TravelDiscoveryPage(),
        ),
        GoRoute(
          name: AppRoute.nearbyEssentials.routeName,
          path: AppRoute.nearbyEssentials.path,
          builder: (context, state) => const NearbyEssentialsPage(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          travelDiscoveryServiceProvider.overrideWithValue(
            const DemoTravelDiscoveryService(),
          ),
          savedItemsRepositoryProvider.overrideWithValue(
            MemorySavedItemsRepository(),
          ),
          tripRepositoryProvider.overrideWithValue(_FakeTripRepository()),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Search Everything'), findsOneWidget);
    expect(
      find.text(
        'Flights, hotels, transport, activities and restaurants in one trip-aware flow.',
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Nearby Essentials'),
      180,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Nearby Essentials'), findsOneWidget);
    expect(find.textContaining('Find toilets, supermarkets'), findsOneWidget);

    await tester.tap(find.text('Nearby Essentials'));
    await tester.pumpAndSettle();

    expect(find.text('What are you looking for?'), findsOneWidget);
    expect(find.text('Toilets'), findsOneWidget);
    expect(find.text('Supermarkets'), findsOneWidget);
  });
}

class _FakeTripRepository implements TripRepository {
  @override
  Future<void> createTrip(Trip trip) async {}

  @override
  Future<void> deleteTrip(String id) async {}

  @override
  Future<Trip?> get(String id) async => null;

  @override
  Future<List<Trip>> getAll() async => const <Trip>[];

  @override
  Future<void> updateTrip(Trip trip) async {}

  @override
  Stream<List<Trip>> watchTrips() => Stream.value(const <Trip>[]);
}
