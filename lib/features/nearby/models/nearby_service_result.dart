import '../../../core/providers/travel_provider_contracts.dart';
import 'nearby_service_type.dart';

class NearbyServiceResult {
  const NearbyServiceResult({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.categoryLabel,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.dataSource,
    this.distanceMeters,
    this.rating,
    this.openNow,
    this.metadata = const <String, Object?>{},
  });

  final String id;
  final String name;
  final NearbyServiceType serviceType;
  final String categoryLabel;
  final String address;
  final double latitude;
  final double longitude;
  final int? distanceMeters;
  final double? rating;
  final bool? openNow;
  final Map<String, Object?> metadata;
  final TravelDataSource dataSource;
}