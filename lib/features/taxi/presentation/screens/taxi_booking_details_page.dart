import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/app_routes.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../../core/models/booking.dart';
import '../../../trips/domain/entities/trip.dart';
import '../../../trips/presentation/providers/trip_provider.dart';
import '../providers/taxi_hub_provider.dart';
import '../../../../core/utils/user_facing_error.dart';

class TaxiBookingDetailsPage extends ConsumerWidget {
  const TaxiBookingDetailsPage({
    required this.args,
    super.key,
  });

  final TaxiBookingRouteArgs args;

  Future<String?> _selectTripId(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final trips = await ref.read(tripsProvider.future);
    if (trips.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Create a trip first to save taxi rides.'),
          ),
        );
      }
      return null;
    }

    final currentSelected = ref.read(taxiTripSelectionProvider);
    String selected = currentSelected ?? trips.first.id;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Select trip'),
              content: SizedBox(
                width: 360,
                child: DropdownButtonFormField<String>(
                  initialValue: selected,
                  items: trips
                      .map(
                        (Trip trip) => DropdownMenuItem<String>(
                          value: trip.id,
                          child: Text('${trip.title} (${trip.destination})'),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (next) {
                    if (next == null) {
                      return;
                    }
                    setDialogState(() {
                      selected = next;
                    });
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(selected),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      ref.read(taxiTripSelectionProvider.notifier).state = result;
    }

    return result;
  }

  Future<void> _openRouteOnMap(BuildContext context) async {
    final query =
        '${args.request.pickupAddress} to ${args.request.destinationAddress}';
    final uri =
        Uri.https('www.google.com', '/maps/dir/', {'api': '1', 'query': query});

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open map preview.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              final user = ref.read(immediateCurrentUserProvider);
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please log in to book.')),
                );
                return;
              }

              final trips = await ref.read(tripsProvider.future);
              final tripId = trips.isNotEmpty ? trips.first.id : 'mock-trip-id';

              ref.read(transportBookingProvider.notifier).book(
                    tripId: tripId,
                    userId: user.uid,
                    request: args.request,
                    option: args.option,
                  );

              if (context.mounted) {
                context.pushBookingStatus(BookingType.transport);
              }
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Book Transport'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _openRouteOnMap(context),
            icon: const Icon(Icons.map_outlined),
            label: const Text('View route on map'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final tripId = await _selectTripId(context, ref);
              if (tripId == null) {
                return;
              }

              try {
                await ref.read(taxiTransportActionsProvider).saveRideToTrip(
                      tripId: tripId,
                      provider: args.option.providerName,
                      request: args.request,
                      option: args.option,
                    );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Ride saved to trip transport itinerary and expense log.',
                      ),
                    ),
                  );
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(UserFacingError.message(
                        error,
                        fallback: 'We could not save this ride to your trip.',
                      )),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.bookmark_add_outlined),
            label: const Text('Save ride to itinerary'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Fare is added automatically when you save the ride to a trip.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('Expense auto-logging info'),
          ),
        ],
      ),
    );
  }
}
