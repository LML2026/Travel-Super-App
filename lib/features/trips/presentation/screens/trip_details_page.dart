import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/trip.dart';
import '../providers/trip_provider.dart';

class TripDetailsPage extends ConsumerWidget {
  const TripDetailsPage({
    super.key,
    required this.tripId,
  });

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(tripRepositoryProvider);

    return FutureBuilder<Trip?>(
      future: repository.getTrip(tripId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Trip')),
            body: Center(
              child: Text(snapshot.error.toString()),
            ),
          );
        }

        final trip = snapshot.data;

        if (trip == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Trip')),
            body: const Center(
              child: Text('Trip not found'),
            ),
          );
        }

        final formatter = DateFormat('dd MMM yyyy');

        return Scaffold(
          appBar: AppBar(
            title: Text(trip.destination),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [

              _InfoTile(
                icon: Icons.place,
                title: "Destination",
                value: trip.destination,
              ),

              _InfoTile(
                icon: Icons.calendar_today,
                title: "Departure",
                value: formatter.format(trip.departureDate),
              ),

              _InfoTile(
                icon: Icons.event,
                title: "Return",
                value: formatter.format(trip.returnDate),
              ),

              _InfoTile(
                icon: Icons.payments,
                title: "Budget",
                value:
                    "${trip.currency} ${trip.budget.toStringAsFixed(2)}",
              ),

              _InfoTile(
                icon: Icons.people,
                title: "Travellers",
                value: trip.travellers.toString(),
              ),

              _InfoTile(
                icon: Icons.notes,
                title: "Notes",
                value: trip.notes.isEmpty
                    ? "-"
                    : trip.notes,
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("Edit Trip"),
                onPressed: () {
                  // Edit page (next step)
                },
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text("Delete Trip"),
                onPressed: () {
                  // Delete confirmation (next step)
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
