import 'google_maps_platform_service.dart';

class MapRouteService {
  const MapRouteService({GoogleMapsPlatformService? platformService})
      : _platformService = platformService ?? const GoogleMapsPlatformService();

  final GoogleMapsPlatformService _platformService;

  Future<GoogleRoute?> computeRoute({
    required String origin,
    required String destination,
    String travelMode = 'DRIVE',
  }) async {
    try {
      if (!await _platformService.isConfigured()) {
        return null;
      }
      final response = await _platformService.computeRoute(
        origin: origin,
        destination: destination,
        travelMode: travelMode,
      );
      return response == null ? null : GoogleRoute.fromNative(response);
    } catch (_) {
      return null;
    }
  }
}
