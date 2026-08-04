import 'nearby_service_filter.dart';
import 'nearby_service_type.dart';

class NearbyServiceQuery {
  const NearbyServiceQuery({
    required this.serviceType,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 500,
    this.filter = const NearbyServiceFilter(),
  });

  final NearbyServiceType serviceType;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final NearbyServiceFilter filter;
}