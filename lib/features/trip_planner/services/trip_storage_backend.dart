abstract class TripStorageBackend {
  Future<String?> readTripsJson();
  Future<void> writeTripsJson(String json);
}