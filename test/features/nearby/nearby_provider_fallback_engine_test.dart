import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/nearby/models/nearby_service_result.dart';
import 'package:travel_super_app/features/nearby/models/nearby_service_type.dart';
import 'package:travel_super_app/features/nearby/services/nearby_provider_fallback_engine.dart';

void main() {
  const engine = NearbyProviderFallbackEngine();

  NearbyServiceResult buildResult({
    required String id,
    required NearbyServiceType serviceType,
    required NearbyDataSource source,
    required double distanceMeters,
    bool? isOpenNow,
    OpenStatusSource openStatusSource = OpenStatusSource.unknown,
    bool? wheelchairAccessible,
    bool? hasAccessibleToilet,
    bool? hasBabyChanging,
  }) {
    return NearbyServiceResult(
      id: id,
      name: 'Place $id',
      serviceType: serviceType,
      categoryLabel: serviceType.name,
      address: 'Address $id',
      latitude: 0,
      longitude: 0,
      source: source,
      distanceMeters: distanceMeters,
      isOpenNow: isOpenNow,
      openStatusSource: openStatusSource,
      wheelchairAccessible: wheelchairAccessible,
      hasAccessibleToilet: hasAccessibleToilet,
      hasBabyChanging: hasBabyChanging,
    );
  }

  test('toilet ranking prioritizes accessibility metadata', () {
    final primary = <NearbyServiceResult>[
      buildResult(
        id: 'primary-basic',
        serviceType: NearbyServiceType.toilet,
        source: NearbyDataSource.google,
        distanceMeters: 120.0,
      ),
    ];

    final fallback = <NearbyServiceResult>[
      buildResult(
        id: 'fallback-accessible',
        serviceType: NearbyServiceType.toilet,
        source: NearbyDataSource.osm,
        distanceMeters: 180.0,
        wheelchairAccessible: true,
        hasAccessibleToilet: true,
        hasBabyChanging: true,
      ),
    ];

    final merged = engine.mergeResults(
      serviceType: NearbyServiceType.toilet,
      primaryResults: primary,
      fallbackResults: fallback,
      primaryFailed: false,
    );

    expect(merged.first.id, 'fallback-accessible');
    expect(merged.first.source, NearbyDataSource.fallback);
    expect(merged.first.sourceMetadata['upstreamSource'], 'osm');
  });

  test('pharmacy ranking prefers provider-backed open-now truth', () {
    final primary = <NearbyServiceResult>[
      buildResult(
        id: 'provider-open',
        serviceType: NearbyServiceType.pharmacy,
        source: NearbyDataSource.google,
        distanceMeters: 600.0,
        isOpenNow: true,
        openStatusSource: OpenStatusSource.provider,
      ),
    ];

    final fallback = <NearbyServiceResult>[
      buildResult(
        id: 'inferred-open',
        serviceType: NearbyServiceType.pharmacy,
        source: NearbyDataSource.osm,
        distanceMeters: 400.0,
        isOpenNow: true,
        openStatusSource: OpenStatusSource.scheduleInference,
      ),
    ];

    final merged = engine.mergeResults(
      serviceType: NearbyServiceType.pharmacy,
      primaryResults: primary,
      fallbackResults: fallback,
      primaryFailed: false,
    );

    expect(merged.first.id, 'provider-open');
    expect(merged.first.source, NearbyDataSource.google);
    expect(merged.first.sourceMetadata['fallbackApplied'], false);
  });

  test('falls back cleanly when primary provider fails', () {
    final fallback = <NearbyServiceResult>[
      buildResult(
        id: 'fallback-only',
        serviceType: NearbyServiceType.pharmacy,
        source: NearbyDataSource.here,
        distanceMeters: 250.0,
        isOpenNow: true,
        openStatusSource: OpenStatusSource.scheduleInference,
      ),
    ];

    final merged = engine.mergeResults(
      serviceType: NearbyServiceType.pharmacy,
      primaryResults: const <NearbyServiceResult>[],
      fallbackResults: fallback,
      primaryFailed: true,
    );

    expect(merged, hasLength(1));
    expect(merged.first.id, 'fallback-only');
    expect(merged.first.source, NearbyDataSource.fallback);
    expect(merged.first.sourceMetadata['fallbackApplied'], true);
    expect(merged.first.sourceMetadata['upstreamSource'], 'here');
    expect(merged.first.sourceMetadata['fallbackReason'], 'primary_failed');
  });
}
