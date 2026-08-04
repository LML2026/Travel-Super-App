import 'package:geolocator/geolocator.dart';

import '../models/live_location.dart';

abstract interface class LiveLocationService {
  Future<LiveLocation> getCurrentLocation();

  Stream<LiveLocation> watchCurrentLocation();
}

class GeolocatorLiveLocationService implements LiveLocationService {
  const GeolocatorLiveLocationService();

  @override
  Future<LiveLocation> getCurrentLocation() async {
    final position = await _getPosition();
    return _fromPosition(position);
  }

  @override
  Stream<LiveLocation> watchCurrentLocation() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 25,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .map(_fromPosition);
  }

  Future<Position> _getPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw StateError('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw StateError('Location permission denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw StateError('Location permission permanently denied.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  LiveLocation _fromPosition(Position position) {
    return LiveLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
    );
  }
}