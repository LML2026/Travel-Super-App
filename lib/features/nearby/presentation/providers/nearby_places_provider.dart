import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/nearby_places_service.dart';

final nearbyPlacesServiceProvider = Provider<NearbyPlacesService>((ref) {
  return BackendNearbyPlacesService();
});
