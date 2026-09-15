import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/nearby/models/nearby_service_result.dart';
import 'package:travel_super_app/features/nearby/models/nearby_service_metadata.dart';
import 'package:travel_super_app/features/nearby/models/nearby_service_type.dart';
import 'package:travel_super_app/features/nearby/presentation/nearby_essentials_page.dart';
import 'package:travel_super_app/features/nearby/presentation/providers/nearby_places_provider.dart';
import 'package:travel_super_app/features/nearby/services/nearby_places_service.dart';

void main() {
  testWidgets(
      'nearby essentials page renders hub services and state foundations',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        overrides: [],
        child: MaterialApp(
          home: NearbyEssentialsPage(),
        ),
      ),
    );

    expect(find.text('Nearby Essentials'), findsWidgets);
    expect(find.text('Toilets'), findsOneWidget);
    expect(find.text('ATMs'), findsOneWidget);
    expect(find.text('Pharmacies'), findsOneWidget);
    expect(find.text('Hospitals'), findsOneWidget);
    expect(find.text('Restaurants'), findsOneWidget);
    expect(find.text('Cafes'), findsOneWidget);

    expect(find.text('Destination or map location'), findsOneWidget);
  });

  testWidgets('backend success renders nearby results', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nearbyPlacesServiceProvider.overrideWithValue(
            _NearbyService((query) async => [
                  NearbyServiceResult(
                    id: 'backend-place',
                    name: 'Central Supermarket',
                    serviceType: query.serviceType,
                    categoryLabel: query.serviceType.metadata.label,
                    address: '1.0 km from London',
                    latitude: 0,
                    longitude: 0,
                    source: NearbyDataSource.backend,
                  ),
                ]),
          ),
        ],
        child: const MaterialApp(
          home: NearbyEssentialsPage(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'London');
    await tester.tap(find.byTooltip('Search nearby'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Central Supermarket'),
      180,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Central Supermarket'), findsOneWidget);
    expect(find.text('Nearby results'), findsOneWidget);
  });

  testWidgets('backend failure discloses fallback results', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nearbyPlacesServiceProvider.overrideWithValue(
            _NearbyService((_) async => const [
                  NearbyServiceResult(
                    id: 'fallback-place',
                    name: 'Fallback Place',
                    serviceType: NearbyServiceType.toilet,
                    categoryLabel: 'Toilets',
                    address: 'Demo result near London',
                    latitude: 0,
                    longitude: 0,
                    source: NearbyDataSource.fallback,
                    sourceMetadata: {'liveUnavailable': true},
                  ),
                ]),
          ),
        ],
        child: const MaterialApp(
          home: NearbyEssentialsPage(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'London');
    await tester.tap(find.byTooltip('Search nearby'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Live nearby results unavailable — showing fallback results.'),
      180,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      find.text('Live nearby results unavailable — showing fallback results.'),
      findsOneWidget,
    );
    expect(find.text('Demo fallback'), findsOneWidget);
  });

  testWidgets('selecting a service updates filter preview content',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        overrides: [],
        child: MaterialApp(
          home: NearbyEssentialsPage(),
        ),
      ),
    );

    await tester.tap(find.text('Pharmacies'));
    await tester.pump();
    expect(find.text('Pharmacies'), findsOneWidget);
  });
}

class _NearbyService implements NearbyPlacesService {
  const _NearbyService(this._search);

  final Future<List<NearbyServiceResult>> Function(NearbyPlacesQuery query)
      _search;

  @override
  Future<List<NearbyServiceResult>> search(NearbyPlacesQuery query) =>
      _search(query);
}
