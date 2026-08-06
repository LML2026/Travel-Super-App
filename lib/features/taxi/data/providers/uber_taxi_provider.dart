import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/taxi_ride_request.dart';
import '../../domain/providers/taxi_provider.dart';

class UberTaxiProvider implements TaxiProvider {
  @override
  String get name => 'Uber';

  @override
  Future<bool> isAvailable() async {
    return true;
  }

  @override
  Future<void> openBooking(TaxiRideRequest request) async {
    final uri = Uri.https('m.uber.com', '/ul/', {
      'action': 'setPickup',
      'pickup[latitude]': request.pickupLatitude.toString(),
      'pickup[longitude]': request.pickupLongitude.toString(),
      'pickup[formatted_address]': request.pickupAddress,
      'dropoff[latitude]': request.destinationLatitude.toString(),
      'dropoff[longitude]': request.destinationLongitude.toString(),
      'dropoff[formatted_address]': request.destinationAddress,
    });

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw StateError('Could not open Uber booking URL.');
    }
  }
}
