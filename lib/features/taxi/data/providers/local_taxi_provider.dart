import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/taxi_ride_request.dart';
import '../../domain/providers/taxi_provider.dart';

class LocalTaxiProvider implements TaxiProvider {
  const LocalTaxiProvider();

  @override
  String get name => 'Local Taxi';

  @override
  Future<bool> isAvailable() async {
    return true;
  }

  @override
  Future<void> openBooking(TaxiRideRequest request) async {
    final body = StringBuffer()
      ..writeln('Taxi booking request')
      ..writeln('Pickup: ${request.pickupAddress}')
      ..writeln('Destination: ${request.destinationAddress}')
      ..writeln('Passengers: ${request.passengers}')
      ..writeln('Luggage: ${request.luggage}')
      ..writeln(
          'Pickup time: ${request.pickupTime?.toIso8601String() ?? 'ASAP'}');

    final smsUri = Uri(
      scheme: 'sms',
      path: '+10000000000',
      queryParameters: {'body': body.toString()},
    );

    if (!await launchUrl(smsUri, mode: LaunchMode.externalApplication)) {
      throw StateError('Could not open local taxi provider.');
    }
  }
}
