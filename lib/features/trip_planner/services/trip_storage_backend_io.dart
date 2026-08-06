import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'trip_storage_backend.dart';

class IoTripStorageBackend implements TripStorageBackend {
  static const String _tripsFileName = 'saved_trips.json';

  Future<File> _getTripsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_tripsFileName');
  }

  @override
  Future<String?> readTripsJson() async {
    final file = await _getTripsFile();
    if (!await file.exists()) {
      return null;
    }
    return file.readAsString();
  }

  @override
  Future<void> writeTripsJson(String json) async {
    final file = await _getTripsFile();
    await file.writeAsString(json);
  }
}

TripStorageBackend createTripStorageBackend() => IoTripStorageBackend();
