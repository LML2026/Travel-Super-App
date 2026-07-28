import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/taxi_ride_request.dart';
import '../../domain/providers/taxi_provider.dart';

class AirportTransferProvider implements TaxiProvider {
  const AirportTransferProvider();

  @override
  String get name => 'Airport Transfer';

  @override
  Future<bool> isAvailable() async {
    return true;
  }

  @override
  Future<void> openBooking(TaxiRideRequest request) async {
    final uri = Uri.https('example-airport-transfer.com', '/book', {
      'pickup_address': request.pickupAddress,
      'dropoff_address': request.destinationAddress,
      'pickup_lat': request.pickupLatitude.toString(),
      'pickup_lng': request.pickupLongitude.toString(),
      'dropoff_lat': request.destinationLatitude.toString(),
      'dropoff_lng': request.destinationLongitude.toString(),
      'passengers': request.passengers.toString(),
      'luggage': request.luggage.toString(),
    });

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw StateError('Could not open airport transfer booking URL.');
    }
  }
}
