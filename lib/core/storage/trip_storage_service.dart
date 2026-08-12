import 'package:shared_preferences/shared_preferences.dart';
import '../../features/trips/models/trip.dart';

class TripStorageService {
  static const String _key = 'itarevo_trips';

  Future<List<Trip>> loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_key) ?? [];

    return items.map(Trip.fromJson).toList();
  }

  Future<void> saveTrips(List<Trip> trips) async {
    final prefs = await SharedPreferences.getInstance();
    final items = trips.map((trip) => trip.toJson()).toList();

    await prefs.setStringList(_key, items);
  }

  Future<void> clearTrips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
