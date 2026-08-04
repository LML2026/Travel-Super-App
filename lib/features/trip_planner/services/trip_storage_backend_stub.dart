import 'trip_storage_backend.dart';

class InMemoryTripStorageBackend implements TripStorageBackend {
  String? _json;

  @override
  Future<String?> readTripsJson() async => _json;

  @override
  Future<void> writeTripsJson(String json) async {
    _json = json;
  }
}

TripStorageBackend createTripStorageBackend() => InMemoryTripStorageBackend();