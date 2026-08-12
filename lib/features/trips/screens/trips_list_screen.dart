import 'package:flutter/material.dart';
import '../models/trip.dart';
import 'create_trip_screen.dart';
import 'trip_details_screen.dart';

class TripsListScreen extends StatefulWidget {
  const TripsListScreen({super.key});

  @override
  State<TripsListScreen> createState() => _TripsListScreenState();
}

class _TripsListScreenState extends State<TripsListScreen> {
  final List<Trip> _trips = [];

  Future<void> _createTrip() async {
    final trip = await Navigator.of(context).push<Trip>(
      MaterialPageRoute(
        builder: (_) => const CreateTripScreen(),
      ),
    );

    if (trip != null) {
      setState(() {
        _trips.add(trip);
      });
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTrip,
        icon: const Icon(Icons.add),
        label: const Text('New Trip'),
      ),
      body: _trips.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.luggage_outlined, size: 72),
                    const SizedBox(height: 20),
                    const Text(
                      'No trips yet',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your first trip and ITAREVO will keep everything organised.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _createTrip,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Trip'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _trips.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final trip = _trips[index];

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(18),
                    leading: const CircleAvatar(
                      child: Icon(Icons.flight_takeoff),
                    ),
                    title: Text(
                      trip.destination,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${_formatDate(trip.departureDate)} - ${_formatDate(trip.returnDate)}'
                        '\n${trip.travellers} traveller(s) • ${trip.currency} ${trip.budget.toStringAsFixed(2)}',
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TripDetailsScreen(trip: trip),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}


