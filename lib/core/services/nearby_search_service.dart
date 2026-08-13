import 'dart:convert';

import '../nearby_search_bridge.dart';

class NearbyPlace {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String googleMapsUrl;

  const NearbyPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.googleMapsUrl,
  });

  factory NearbyPlace.fromMap(Map<String, dynamic> map) {
    return NearbyPlace(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      googleMapsUrl: map['googleMapsUrl'] as String? ?? '',
    );
  }
}

class NearbySearchService {
  const NearbySearchService._();

  static Future<List<NearbyPlace>> search({
    required double latitude,
    required double longitude,
    required String placeType,
  }) async {
    final source = await nearbySearchJson(latitude, longitude, placeType);

    final decoded = jsonDecode(source) as List<dynamic>;

    return decoded
        .map((item) => NearbyPlace.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static Future<bool> openDirections(NearbyPlace place) {
    final queryParameters = <String, String>{
      'api': '1',
      'destination': '${place.latitude},${place.longitude}',
      if (place.id.isNotEmpty) 'destination_place_id': place.id,
    };
    final url = Uri.https('www.google.com', '/maps/dir/', queryParameters);

    return openDirectionsUrl(url.toString());
  }
}
