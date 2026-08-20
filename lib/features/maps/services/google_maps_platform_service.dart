import 'package:flutter/services.dart';

class GoogleMapsPlatformService {
  const GoogleMapsPlatformService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('itarevo.google_maps');

  final MethodChannel _channel;

  Future<bool> isConfigured() async {
    try {
      return await _channel.invokeMethod<bool>('isConfigured') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> searchPlaces({
    required String query,
    Set<String> categories = const <String>{},
    int limit = 20,
  }) async {
    final response = await _channel.invokeMethod<List<dynamic>>(
      'searchPlaces',
      <String, Object?>{
        'query': query,
        'categories': categories.toList(growable: false),
        'limit': limit,
      },
    );

    return response
            ?.whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false) ??
        const <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>?> computeRoute({
    required String origin,
    required String destination,
    String travelMode = 'DRIVE',
  }) async {
    final response = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'computeRoute',
      <String, Object?>{
        'origin': origin,
        'destination': destination,
        'travelMode': travelMode,
      },
    );

    return response == null ? null : Map<String, dynamic>.from(response);
  }
}

class GoogleRoute {
  const GoogleRoute({
    required this.distanceMeters,
    required this.duration,
    this.encodedPolyline,
  });

  final int distanceMeters;
  final Duration duration;
  final String? encodedPolyline;

  factory GoogleRoute.fromNative(Map<String, dynamic> json) {
    final rawDuration = json['durationSeconds'];
    final seconds = rawDuration is num ? rawDuration.round() : 0;

    return GoogleRoute(
      distanceMeters: (json['distanceMeters'] as num?)?.round() ?? 0,
      duration: Duration(seconds: seconds),
      encodedPolyline: json['encodedPolyline'] as String?,
    );
  }
}
