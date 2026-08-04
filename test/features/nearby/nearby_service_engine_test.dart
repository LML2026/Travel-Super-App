import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/core/providers/travel_provider_contracts.dart';
import 'package:travel_super_app/features/nearby/models/nearby_service_filter.dart';
import 'package:travel_super_app/features/nearby/models/nearby_service_type.dart';
import 'package:travel_super_app/features/nearby/services/nearby_service_engine.dart';

void main() {
  const engine = NearbyServiceEngine();

  test('builds toilet maps prefill with typed filters', () {
    final prefill = engine.buildPlacesPrefill(
      serviceType: NearbyServiceType.toilet,
      filter: const NearbyServiceFilter(
        openNow: true,
        maxDistanceMeters: 500,
        freeOnly: true,
      ),
    );

    expect(prefill.title, 'Toilets');
    expect(prefill.query, contains('public toilets'));
    expect(prefill.query, contains('open now'));
    expect(prefill.query, contains('free'));
    expect(prefill.query, contains('within 500 m'));
    expect(prefill.categories, const <PlaceCategory>{PlaceCategory.toilet});
  });

  test('maps restaurant and pharmacy services to typed categories', () {
    expect(
      engine.categoriesFor(NearbyServiceType.restaurant),
      const <PlaceCategory>{PlaceCategory.restaurant},
    );
    expect(
      engine.categoriesFor(NearbyServiceType.pharmacy),
      const <PlaceCategory>{PlaceCategory.pharmacy},
    );
  });
}