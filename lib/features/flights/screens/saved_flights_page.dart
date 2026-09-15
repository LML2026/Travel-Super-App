import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/flight.dart';
import '../../../core/utils/flight_formatter.dart';
import '../models/saved_flight.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

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
          title: Text(context.ui('savedFlights')),
        ),
        body: Center(
          child: Text(context.ui('signInViewSavedFlights')),
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
        title: Text(context.ui('savedFlights')),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: savedFlightsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'Failed to load saved flights:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final documents = snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 64,
                    color: AppColors.textSubtle,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'No saved flights yet',
                    style: AppTextStyles.title,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your saved flights will appear here.',
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: documents.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
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
                            const SizedBox(width: AppSpacing.md),
                            // Airline name and flight number
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    flight.airline,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    flight.flightNumber,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            // Price
                            Text(
                              '${flight.currency} ${flight.amount.toStringAsFixed(2)}',
                              style: AppTextStyles.price,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            // Delete button
                            IconButton(
                              tooltip: context.ui('remove'),
                              onPressed: () async {
                                await document.reference.delete();
                              },
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Flight times
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  departureTime,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  flight.origin,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    formattedDuration,
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                  const Divider(thickness: 1),
                                  Text(
                                    stopsText,
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  arrivalTime,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  flight.destination,
                                  style: Theme.of(context).textTheme.bodySmall,
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
