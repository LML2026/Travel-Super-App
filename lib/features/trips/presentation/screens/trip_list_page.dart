import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/trip.dart';
import '../providers/trip_provider.dart';
import 'create_trip_page.dart';

class TripListPage extends ConsumerWidget {
  const TripListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateTripPage(),
            ),
          );
        },
      ),
      body: tripsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (error, stack) => Center(
          child: Text(error.toString()),
        ),

        data: (trips) {
          if (trips.isEmpty) {
            return const _EmptyTripsView();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              return TripCard(
                trip: trips[index],
              );
            },
          );
        },
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.trip,
  });

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.flight_takeoff),
        ),
        title: Text(
          trip.destination,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 8),

            Text(
              "${formatter.format(trip.departureDate)}"
              " → "
              "${formatter.format(trip.returnDate)}",
            ),

            const SizedBox(height: 6),

            Text(
              "Budget: ${trip.currency} ${trip.budget.toStringAsFixed(2)}",
            ),

            Text(
              "Travellers: ${trip.travellers}",
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Trip Details page (next step)
        },
      ),
    );
  }
}

class _EmptyTripsView extends StatelessWidget {
  const _EmptyTripsView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(
            Icons.luggage,
            size: 80,
            color: Colors.grey,
          ),

          SizedBox(height: 20),

          Text(
            "No trips yet",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          Text(
            "Tap + to create your first trip.",
          ),
        ],
      ),
    );
  }
}
