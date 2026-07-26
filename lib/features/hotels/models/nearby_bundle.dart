import 'nearby_place.dart';

class NearbyBundle {
  const NearbyBundle({
    required this.city,
    required this.attractions,
    required this.restaurants,
    required this.transport,
  });

  final String city;
  final List<NearbyPlace> attractions;
  final List<NearbyPlace> restaurants;
  final List<NearbyPlace> transport;

  factory NearbyBundle.fromJson(Map<String, dynamic> json) {
    List<NearbyPlace> parseList(String key) {
      final raw = json[key];
      if (raw is! List) {
        return const [];
      }
      return raw
          .whereType<Map>()
          .map((e) => NearbyPlace.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return NearbyBundle(
      city: json['city']?.toString() ?? '',
      attractions: parseList('attractions'),
      restaurants: parseList('restaurants'),
      transport: parseList('transport'),
    );
  }
}
