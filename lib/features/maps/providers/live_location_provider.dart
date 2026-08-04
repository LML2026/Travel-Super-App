import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/live_location.dart';
import '../services/live_location_service.dart';

final liveLocationServiceProvider = Provider<LiveLocationService>(
  (ref) => const GeolocatorLiveLocationService(),
);

final liveLocationProvider = FutureProvider<LiveLocation>((ref) async {
  return ref.watch(liveLocationServiceProvider).getCurrentLocation();
});
