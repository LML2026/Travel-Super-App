import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../trips/domain/entities/trip.dart';
import '../../../trips/presentation/providers/trip_provider.dart';
import '../providers/taxi_hub_provider.dart';

class SavedRidesPage extends ConsumerWidget {
  const SavedRidesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved rides')),
      body: tripsAsync.when(
        data: (trips) {
          if (trips.isEmpty) {
            return const Center(
              child: Text(
                'No trips found. Create a trip to save transport rides.',
                textAlign: TextAlign.center,
              ),
            );
          }

          final selectedTripId = ref.watch(taxiTripSelectionProvider);
          final effectiveTripId = selectedTripId ?? trips.first.id;

          if (selectedTripId == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(taxiTripSelectionProvider.notifier).state =
                  trips.first.id;
            });
          }

          final ridesAsync = ref.watch(
            taxiSavedRidesForTripProvider(effectiveTripId),
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: DropdownButtonFormField<String>(
                  initialValue: effectiveTripId,
                  decoration: const InputDecoration(
                    labelText: 'Trip',
                    border: OutlineInputBorder(),
                  ),
                  items: trips
                      .map(
                        (Trip trip) => DropdownMenuItem<String>(
                          value: trip.id,
                          child: Text('${trip.title} (${trip.destination})'),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    ref.read(taxiTripSelectionProvider.notifier).state = value;
                  },
                ),
              ),
              Expanded(
                child: ridesAsync.when(
                  data: (rides) {
                    if (rides.isEmpty) {
                      return const Center(
                        child: Text(
                          'No saved rides yet for this trip.',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: rides.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final ride = rides[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.route_outlined),
                            title: Text(
                              '${ride.pickupAddress} -> ${ride.destinationAddress}',
                            ),
                            subtitle: Text(
                              '${ride.provider} | ${ride.currency} ${ride.estimatedFare.toStringAsFixed(2)}',
                            ),
                            trailing: Text(
                              ride.scheduledAt == null
                                  ? 'ASAP'
                                  : '${ride.scheduledAt}',
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Could not load saved rides: $error'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Could not load trips: $error'),
          ),
        ),
      ),
    );
  }
}
