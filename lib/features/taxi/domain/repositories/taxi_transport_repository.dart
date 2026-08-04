import '../entities/taxi_saved_ride.dart';

abstract interface class TaxiTransportRepository {
  Stream<List<TaxiSavedRide>> watchRidesForTrip(String tripId);

  Future<void> saveRide({
    required String tripId,
    required TaxiSavedRide ride,
  });
}
