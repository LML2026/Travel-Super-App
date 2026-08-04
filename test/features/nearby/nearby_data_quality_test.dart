import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/nearby/models/nearby_service_result.dart';
import 'package:travel_super_app/features/nearby/models/nearby_service_type.dart';
import 'package:travel_super_app/features/nearby/services/nearby_distance_ranker.dart';

void main() {
  const ranker = NearbyDistanceRanker();

  NearbyServiceResult buildResult({
    required String id,
    required double latitude,
    required double longitude,
    double? distanceMeters,
    bool? isOpenNow,
    OpenStatusSource openStatusSource = OpenStatusSource.unknown,
    bool? wheelchairAccessible,
    bool? hasAccessibleToilet,
    bool? hasBabyChanging,
  }) {
    return NearbyServiceResult(
      id: id,
      name: 'Place $id',
      serviceType: NearbyServiceType.toilet,
      categoryLabel: 'Toilets',
      address: 'Address $id',
      latitude: latitude,
      longitude: longitude,
      source: NearbyDataSource.google,
      distanceMeters: distanceMeters,
      isOpenNow: isOpenNow,
      openStatusSource: openStatusSource,
      wheelchairAccessible: wheelchairAccessible,
      hasAccessibleToilet: hasAccessibleToilet,
      hasBabyChanging: hasBabyChanging,
    );
  }

  test('computes distance and exposes km helper', () {
    final result = buildResult(id: 'a', latitude: 51.5010, longitude: -0.1420);

    final withDistance = ranker
        .withComputedDistance(
          results: <NearbyServiceResult>[result],
          userLatitude: 51.5007,
          userLongitude: -0.1246,
        )
        .first;

    expect(withDistance.distanceMeters, isNotNull);
    expect(withDistance.distanceMeters!, greaterThan(1000));
    expect(
      withDistance.distanceKm,
      closeTo(withDistance.distanceMeters! / 1000, 0.0001),
    );
  });

  test('sorts nearest first and keeps unknown distance last', () {
    final nearby = buildResult(
      id: 'nearby',
      latitude: 51.5008,
      longitude: -0.1248,
      distanceMeters: 30,
    );
    final far = buildResult(
      id: 'far',
      latitude: 51.5074,
      longitude: -0.1278,
      distanceMeters: 900,
    );
    final unknown = buildResult(
      id: 'unknown',
      latitude: 51.5010,
      longitude: -0.1420,
      distanceMeters: null,
    );

    final sorted = ranker.sortNearestFirst(<NearbyServiceResult>[
      far,
      unknown,
      nearby,
    ]);

    expect(sorted.map((result) => result.id).toList(), <String>[
      'nearby',
      'far',
      'unknown',
    ]);
  });

  test(
    'keeps open status source unknown when provider does not supply data',
    () {
      final result = buildResult(
        id: 'unknown-open',
        latitude: 51.5007,
        longitude: -0.1246,
        isOpenNow: null,
        openStatusSource: OpenStatusSource.unknown,
        wheelchairAccessible: true,
        hasAccessibleToilet: true,
        hasBabyChanging: false,
      );

      expect(result.isOpenNow, isNull);
      expect(result.openStatusSource, OpenStatusSource.unknown);
      expect(result.wheelchairAccessible, isTrue);
      expect(result.hasAccessibleToilet, isTrue);
      expect(result.hasBabyChanging, isFalse);
    },
  );
}
