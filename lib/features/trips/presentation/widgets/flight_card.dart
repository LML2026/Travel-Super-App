import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../flights/models/saved_flight.dart';
import '../providers/trip_dashboard_provider.dart';
import 'dashboard_section.dart';

class FlightCard extends ConsumerWidget {
  const FlightCard({
    super.key,
    required this.tripId,
    this.onOpenFlights,
    this.onViewFlightDetails,
    this.onLinkFlight,
    this.onUnlinkFlight,
  });

  final String tripId;
  final VoidCallback? onOpenFlights;
  final ValueChanged<SavedFlight>? onViewFlightDetails;
  final VoidCallback? onLinkFlight;
  final VoidCallback? onUnlinkFlight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkedFlightAsync = ref.watch(tripFlightsProvider(tripId));
    final linkedFlight = linkedFlightAsync.valueOrNull;
    final hasFlight = linkedFlight != null;

    Widget details;
    if (linkedFlightAsync.isLoading) {
      details = const Text('Loading flight...');
    } else if (linkedFlightAsync.hasError) {
      details = const Text('Unable to load flight');
    } else if (linkedFlight == null) {
      details = const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No flight added yet.'),
          SizedBox(height: 2),
          Text('Tap to attach a flight.'),
        ],
      );
    } else {
      details = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${linkedFlight.airline} ${linkedFlight.flightNumber}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('${linkedFlight.origin} → ${linkedFlight.destination}'),
          Text(
            '${_formatFlightTime(linkedFlight.departureAt)} → ${_formatFlightTime(linkedFlight.arrivalAt)}',
          ),
        ],
      );
    }

    return DashboardSection(
      icon: Icons.flight_takeoff,
      title: 'Flights',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          details,
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: onOpenFlights,
                child: const Text('Open Flights'),
              ),
              if (hasFlight)
                OutlinedButton(
                  onPressed: () => onViewFlightDetails?.call(linkedFlight!),
                  child: const Text('View Details'),
                ),
              if (hasFlight)
                OutlinedButton(
                  onPressed: onUnlinkFlight,
                  child: const Text('Unlink'),
                )
              else
                FilledButton(
                  onPressed: onLinkFlight,
                  child: const Text('Link Flight'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatFlightTime(String dateTime) {
    final parsed = DateTime.tryParse(dateTime);
    if (parsed == null) {
      return dateTime;
    }

    return DateFormat('HH:mm').format(parsed);
  }
}
