import 'dart:math' as math;

import '../models/nearby_service_result.dart';

class NearbyDistanceRanker {
  const NearbyDistanceRanker();

  List<NearbyServiceResult> withComputedDistance({
    required List<NearbyServiceResult> results,
    required double userLatitude,
    required double userLongitude,
  }) {
    return results
        .map(
          (result) => NearbyServiceResult(
            id: result.id,
            name: result.name,
            serviceType: result.serviceType,
            categoryLabel: result.categoryLabel,
            address: result.address,
            latitude: result.latitude,
            longitude: result.longitude,
            source: result.source,
            sourceMetadata: result.sourceMetadata,
            distanceMeters: distanceMeters(
              fromLatitude: userLatitude,
              fromLongitude: userLongitude,
              toLatitude: result.latitude,
              toLongitude: result.longitude,
            ),
            rating: result.rating,
            isOpenNow: result.isOpenNow,
            openingHours: result.openingHours,
            openStatusSource: result.openStatusSource,
            wheelchairAccessible: result.wheelchairAccessible,
            hasAccessibleToilet: result.hasAccessibleToilet,
            hasBabyChanging: result.hasBabyChanging,
            metadata: result.metadata,
          ),
        )
        .toList(growable: false);
  }

  List<NearbyServiceResult> sortNearestFirst(
    List<NearbyServiceResult> results,
  ) {
    final sorted = List<NearbyServiceResult>.from(results);
    sorted.sort((a, b) {
      final aDistance = a.distanceMeters;
      final bDistance = b.distanceMeters;
      if (aDistance == null && bDistance == null) {
        return 0;
      }
      if (aDistance == null) {
        return 1;
      }
      if (bDistance == null) {
        return -1;
      }
      return aDistance.compareTo(bDistance);
    });
    return sorted;
  }

  double distanceMeters({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  }) {
    const earthRadiusMeters = 6371000.0;

    final dLat = _toRadians(toLatitude - fromLatitude);
    final dLon = _toRadians(toLongitude - fromLongitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(fromLatitude)) *
            math.cos(_toRadians(toLatitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180.0);
}
