class NearbyPlace {
  const NearbyPlace({
    required this.name,
    required this.distanceKm,
    required this.type,
  });

  final String name;
  final double distanceKm;
  final String type;

  factory NearbyPlace.fromJson(Map<String, dynamic> json) {
    return NearbyPlace(
      name: json['name']?.toString() ?? '',
      distanceKm: double.tryParse(json['distanceKm']?.toString() ?? '') ?? 0,
      type: json['type']?.toString() ?? '',
    );
  }
}
