import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../app/app_routes.dart';
import '../models/flight.dart';
import '../../../core/utils/flight_formatter.dart';
import '../models/saved_flight.dart';

class SavedFlightsPage extends StatelessWidget {
  const SavedFlightsPage({super.key});

  String _getTimeOnly(String isoDateTime) {
    try {
      return isoDateTime.split('T')[1].substring(0, 5);
    } catch (e) {
      return '--:--';
    }
  }

  String _getStopsText(int stops) {
    return stops == 0 ? '🟢 Direct' : '🟠 $stops Stop${stops > 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Saved Flights'),
        ),
        body: const Center(
          child: Text('Please sign in to view saved flights.'),
        ),
      );
    }

    final savedFlightsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_flights')
        .orderBy('savedAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Flights'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: savedFlightsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load saved flights:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final documents = snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No saved flights yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your saved flights will appear here.',
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: documents.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final document = documents[index];
              final data = document.data();

              final flight = Flight(
                id: data['id']?.toString() ?? '',
                airline: data['airline']?.toString() ?? '',
                airlineLogo: data['airlineLogo']?.toString() ?? '',
                flightNumber: data['flightNumber']?.toString() ?? '',
                origin: data['origin']?.toString() ?? '',
                destination: data['destination']?.toString() ?? '',
                departureAt: data['departureAt']?.toString() ?? '',
                arrivalAt: data['arrivalAt']?.toString() ?? '',
                duration: data['duration']?.toString() ?? '0',
                stops: int.tryParse(data['stops']?.toString() ?? '') ?? 0,
                amount:
                    double.tryParse(data['amount']?.toString() ?? '') ?? 0.0,
                currency: data['currency']?.toString() ?? 'EUR',
              );
              final savedFlight =
                  SavedFlight.fromJson({...data, 'id': document.id});

              final departureTime = _getTimeOnly(flight.departureAt);
              final arrivalTime = _getTimeOnly(flight.arrivalAt);
              final formattedDuration = formatDuration(flight.duration);
              final stopsText = _getStopsText(flight.stops);

              return GestureDetector(
                onTap: () {
                  context.pushSavedFlightDetails(savedFlight);
                },
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Header: Airline, Price, Delete
                        Row(
                          children: [
                            // Logo
                            if (flight.airlineLogo.isNotEmpty)
                              Image.network(
                                flight.airlineLogo,
                                width: 40,
                                height: 40,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.flight, size: 40),
                              )
                            else
                              const Icon(Icons.flight, size: 40),
                            const SizedBox(width: 12),
                            // Airline name and flight number
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    flight.airline,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    flight.flightNumber,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Price
                            Text(
                              '${flight.currency} ${flight.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Delete button
                            IconButton(
                              tooltip: 'Remove',
                              onPressed: () async {
                                await document.reference.delete();
                              },
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Flight times
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  departureTime,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  flight.origin,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    formattedDuration,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const Divider(thickness: 1),
                                  Text(
                                    stopsText,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  arrivalTime,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  flight.destination,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
