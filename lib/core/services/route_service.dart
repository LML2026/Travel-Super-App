import 'dart:convert';

import '../route_bridge.dart';

enum TravelMode {
  walking('WALKING', 'walk'),
  driving('DRIVING', 'drive');

  final String apiValue;
  final String label;

  const TravelMode(this.apiValue, this.label);
}

class RoutePoint {
  final double latitude;
  final double longitude;

  const RoutePoint({required this.latitude, required this.longitude});

  factory RoutePoint.fromMap(Map<String, dynamic> map) {
    return RoutePoint(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }
}

class RouteResult {
  final int durationMinutes;
  final int distanceMetres;
  final List<RoutePoint> points;

  const RouteResult({
    required this.durationMinutes,
    required this.distanceMetres,
    required this.points,
  });

  factory RouteResult.fromMap(Map<String, dynamic> map) {
    final points = map['points'] as List<dynamic>? ?? const [];

    return RouteResult(
      durationMinutes: (map['durationMinutes'] as num).round(),
      distanceMetres: (map['distanceMetres'] as num).round(),
      points: points
          .map((point) => RoutePoint.fromMap(point as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class RouteService {
  const RouteService._();

  static final Map<String, RouteResult> _cache = {};
  static final Map<String, Future<RouteResult?>> _pending = {};

  static Future<RouteResult?> calculate({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required TravelMode travelMode,
  }) {
    final key = _cacheKey(
      originLatitude,
      originLongitude,
      destinationLatitude,
      destinationLongitude,
      travelMode,
    );
    final cached = _cache[key];

    if (cached != null) return Future.value(cached);

    return _pending.putIfAbsent(
      key,
      () => _loadRoute(
        key: key,
        originLatitude: originLatitude,
        originLongitude: originLongitude,
        destinationLatitude: destinationLatitude,
        destinationLongitude: destinationLongitude,
        travelMode: travelMode,
      ),
    );
  }

  static Future<RouteResult?> _loadRoute({
    required String key,
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required TravelMode travelMode,
  }) async {
    try {
      final source = await calculateRouteJson(
        originLatitude,
        originLongitude,
        destinationLatitude,
        destinationLongitude,
        travelMode.apiValue,
      );

      if (source == null || source.isEmpty) return null;

      final result = RouteResult.fromMap(
        jsonDecode(source) as Map<String, dynamic>,
      );

      _cache[key] = result;
      return result;
    } catch (_) {
      return null;
    } finally {
      _pending.remove(key);
    }
  }

  static String _cacheKey(
    double originLatitude,
    double originLongitude,
    double destinationLatitude,
    double destinationLongitude,
    TravelMode travelMode,
  ) {
    return '${travelMode.apiValue}|'
        '${originLatitude.toStringAsFixed(6)},'
        '${originLongitude.toStringAsFixed(6)}|'
        '${destinationLatitude.toStringAsFixed(6)},'
        '${destinationLongitude.toStringAsFixed(6)}';
  }
}
