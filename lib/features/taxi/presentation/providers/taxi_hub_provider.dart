import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/airport_transfer_provider.dart';
import '../../data/providers/local_taxi_provider.dart';
import '../../data/providers/uber_taxi_provider.dart';
import '../../domain/entities/taxi_ride_option.dart';
import '../../domain/entities/taxi_ride_request.dart';
import '../../domain/providers/taxi_provider.dart';

final taxiProvidersProvider = Provider<List<TaxiProvider>>((ref) {
  return const <TaxiProvider>[
    LocalTaxiProvider(),
    AirportTransferProvider(),
  ];
});

final taxiPrimaryProvider = Provider<TaxiProvider>((ref) {
  return UberTaxiProvider();
});

final taxiRideOptionsProvider =
    FutureProvider.family<List<TaxiRideOption>, TaxiRideRequest>(
        (ref, request) async {
  final providers = <TaxiProvider>[
    ref.read(taxiPrimaryProvider),
    ...ref.read(taxiProvidersProvider),
  ];

  final options = <TaxiRideOption>[];
  for (var i = 0; i < providers.length; i++) {
    final provider = providers[i];
    if (!await provider.isAvailable()) {
      continue;
    }

    // Stage 1: static comparison values to support a quick provider hub.
    options.add(
      TaxiRideOption(
        providerName: provider.name,
        estimatedFare: 18 + (i * 6) + (request.passengers * 1.5),
        currency: 'GBP',
        estimatedPickupMinutes: 4 + (i * 3),
        description: request.pickupTime == null
            ? 'Fast pickup from nearby drivers'
            : 'Scheduled pickup for your selected time',
      ),
    );
  }

  options.sort((a, b) => a.estimatedFare.compareTo(b.estimatedFare));
  return options;
});

final savedRideRequestsProvider =
    StateProvider<List<TaxiRideRequest>>((ref) => <TaxiRideRequest>[]);

final selectedTaxiProviderNameProvider = StateProvider<String?>((ref) => null);
