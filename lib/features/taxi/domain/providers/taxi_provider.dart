import '../entities/taxi_ride_request.dart';

abstract interface class TaxiProvider {
  String get name;

  Future<bool> isAvailable();

  Future<void> openBooking(TaxiRideRequest request);
}
