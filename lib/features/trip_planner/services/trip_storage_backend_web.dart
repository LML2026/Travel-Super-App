import 'trip_storage_backend.dart';
import 'trip_storage_backend_stub.dart';

// Web fallback: keep trips for the active session to avoid plugin issues.
TripStorageBackend createTripStorageBackend() => InMemoryTripStorageBackend();