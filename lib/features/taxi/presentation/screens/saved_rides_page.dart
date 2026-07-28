import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/taxi_hub_provider.dart';

class SavedRidesPage extends ConsumerWidget {
  const SavedRidesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rides = ref.watch(savedRideRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved rides')),
      body: rides.isEmpty
          ? const Center(
              child: Text(
                'No saved rides yet.\nBook a ride and save it to your itinerary.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rides.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final ride = rides[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.route_outlined),
                    title: Text('${ride.pickupAddress} -> ${ride.destinationAddress}'),
                    subtitle: Text(
                      ride.pickupTime == null
                          ? 'ASAP | ${ride.passengers} passenger(s)'
                          : '${ride.pickupTime} | ${ride.passengers} passenger(s)',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
