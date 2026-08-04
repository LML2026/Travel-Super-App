import 'nearby_service_type.dart';

enum NearbyDataSource {
  google,
  osm,
  here,
  fallback,
}

enum OpenStatusSource {
  provider,
  scheduleInference,
  unknown,
}

class NearbyServiceResult {
  const NearbyServiceResult({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.categoryLabel,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.source,
    this.sourceMetadata = const <String, Object?>{},
    this.distanceMeters,
    this.rating,
    this.isOpenNow,
    this.openingHours,
    this.openStatusSource = OpenStatusSource.unknown,
    this.wheelchairAccessible,
    this.hasAccessibleToilet,
    this.hasBabyChanging,
    this.metadata = const <String, Object?>{},
  });

  final String id;
  final String name;
  final NearbyServiceType serviceType;
  final String categoryLabel;
  final String address;
  final double latitude;
  final double longitude;
  final NearbyDataSource source;
  final Map<String, Object?> sourceMetadata;
  final double? distanceMeters;
  final double? rating;
  final bool? isOpenNow;
  final String? openingHours;
  final OpenStatusSource openStatusSource;
  final bool? wheelchairAccessible;
  final bool? hasAccessibleToilet;
  final bool? hasBabyChanging;
  final Map<String, Object?> metadata;

  double? get distanceKm =>
      distanceMeters == null ? null : distanceMeters! / 1000;
}