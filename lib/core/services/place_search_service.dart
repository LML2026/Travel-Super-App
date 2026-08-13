import 'dart:convert';

import '../place_picker_bridge.dart';

class PlaceSelection {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const PlaceSelection({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceSelection.fromMap(
    Map<String, dynamic> map,
  ) {
    return PlaceSelection(
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }
}

class PlaceSearchService {
  const PlaceSearchService._();

  static Future<PlaceSelection?> pickPlace() async {
    final source = await pickPlaceJson();

    if (source == null || source.isEmpty) {
      return null;
    }

    final map =
        jsonDecode(source) as Map<String, dynamic>;

    return PlaceSelection.fromMap(map);
  }
}
