import 'dart:convert';
import '../models/saved_trip.dart';
import '../../../core/utils/app_logger.dart';
import 'trip_storage_backend.dart';
import 'trip_storage_backend_stub.dart'
    if (dart.library.io) 'trip_storage_backend_io.dart'
    if (dart.library.html) 'trip_storage_backend_web.dart';

class LocalStorageService {
  LocalStorageService({TripStorageBackend? backend})
      : _backend = backend ?? createTripStorageBackend();

  final TripStorageBackend _backend;

  /// Load all saved trips
  Future<List<SavedTrip>> loadTrips() async {
    try {
      final contents = await _backend.readTripsJson();

      if (contents == null || contents.isEmpty) {
        appLogger.i('📁 No saved trips file found');
        return [];
      }

      final jsonList = jsonDecode(contents) as List;
      final trips = jsonList.map((json) => SavedTrip.fromJson(json)).toList();

      appLogger.i('📁 Loaded ${trips.length} trips from local storage');
      return trips;
    } catch (e, st) {
      appLogger.e(
        '❌ Failed to load trips',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Save trips to disk
  Future<void> saveTrips(List<SavedTrip> trips) async {
    try {
      final jsonList = trips.map((t) => t.toJson()).toList();
      await _backend.writeTripsJson(jsonEncode(jsonList));

      appLogger.i('✅ Saved ${trips.length} trips to local storage');
    } catch (e, st) {
      appLogger.e(
        '❌ Failed to save trips',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Add a new trip
  Future<void> addTrip(SavedTrip trip) async {
    final trips = await loadTrips();
    trips.add(trip);
    await saveTrips(trips);
  }

  /// Delete a trip
  Future<void> deleteTrip(String tripId) async {
    final trips = await loadTrips();
    trips.removeWhere((t) => t.id == tripId);
    await saveTrips(trips);
  }

  /// Update a trip
  Future<void> updateTrip(SavedTrip trip) async {
    final trips = await loadTrips();
    final index = trips.indexWhere((t) => t.id == trip.id);

    if (index != -1) {
      trips[index] = trip;
      await saveTrips(trips);
    }
  }
}
