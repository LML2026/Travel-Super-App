import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/trip.dart';
import '../providers/trip_provider.dart';
import 'create_trip_page.dart';

class EditTripPage extends ConsumerWidget {
  const EditTripPage({
    super.key,
    required this.tripId,
    this.initialTrip,
  });

  final String tripId;
  final Trip? initialTrip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialTrip != null) {
      return CreateTripPage(initialTrip: initialTrip);
    }

    final tripAsync = ref.watch(selectedTripProvider(tripId));

    return tripAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Edit Trip')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Edit Trip')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load trip: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (trip) {
        if (trip == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Trip')),
            body: const Center(child: Text('Trip not found.')),
          );
        }

        return CreateTripPage(initialTrip: trip);
      },
    );
  }
}
