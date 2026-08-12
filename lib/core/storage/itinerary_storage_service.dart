import 'package:shared_preferences/shared_preferences.dart';

import '../../features/trips/models/itinerary/itinerary_item.dart';

class ItineraryStorageService {
  String _keyForTrip(String tripId) => 'itarevo_itinerary_$tripId';

  Future<List<ItineraryItem>> loadItems(String tripId) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_keyForTrip(tripId)) ?? [];

    return items.map(ItineraryItem.fromJson).toList();
  }

  Future<void> saveItems(
    String tripId,
    List<ItineraryItem> items,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = items.map((item) => item.toJson()).toList();

    await prefs.setStringList(_keyForTrip(tripId), encoded);
  }

  Future<void> clearItems(String tripId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyForTrip(tripId));
  }
}
