import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/app_routes.dart';
import '../../domain/providers/taxi_provider.dart';
import '../providers/taxi_hub_provider.dart';

class TaxiBookingDetailsPage extends ConsumerWidget {
  const TaxiBookingDetailsPage({
    required this.args,
    super.key,
  });

  final TaxiBookingRouteArgs args;

  TaxiProvider? _resolveProvider(List<TaxiProvider> providers, String name) {
    for (final provider in providers) {
      if (provider.name == name) {
        return provider;
      }
    }
    return null;
  }

  Future<void> _openRouteOnMap(BuildContext context) async {
    final query =
        '${args.request.pickupAddress} to ${args.request.destinationAddress}';
    final uri = Uri.https('www.google.com', '/maps/dir/', {'api': '1', 'query': query});

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open map preview.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = <TaxiProvider>[
      ref.watch(taxiPrimaryProvider),
      ...ref.watch(taxiProvidersProvider),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Booking details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    args.option.providerName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Estimated fare: ${args.option.currency} ${args.option.estimatedFare.toStringAsFixed(2)}',
                  ),
                  Text('Pickup ETA: ${args.option.estimatedPickupMinutes} min'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Journey'),
                  const SizedBox(height: 8),
                  Text('Pickup: ${args.request.pickupAddress}'),
                  Text('Destination: ${args.request.destinationAddress}'),
                  Text('Passengers: ${args.request.passengers}'),
                  Text('Luggage: ${args.request.luggage}'),
                  Text(
                    'When: ${args.request.pickupTime?.toString() ?? 'ASAP'}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              final provider = _resolveProvider(providers, args.option.providerName);
              if (provider == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Provider is not available.')),
                );
                return;
              }

              try {
                await provider.openBooking(args.request);
                if (context.mounted) {
                  ref.read(selectedTaxiProviderNameProvider.notifier).state = provider.name;
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open provider: $error')),
                  );
                }
              }
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open provider booking'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _openRouteOnMap(context),
            icon: const Icon(Icons.map_outlined),
            label: const Text('View route on map'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              final current = ref.read(savedRideRequestsProvider);
              ref.read(savedRideRequestsProvider.notifier).state = [
                ...current,
                args.request,
              ];

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ride saved to trip itinerary list.')),
              );
            },
            icon: const Icon(Icons.bookmark_add_outlined),
            label: const Text('Save ride to itinerary'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fare prepared for expense recording (Stage 2).'),
                ),
              );
            },
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('Record fare as expense'),
          ),
        ],
      ),
    );
  }
}
