import 'package:flutter/material.dart';

import 'dashboard_section.dart';

class FlightCard extends StatelessWidget {
  const FlightCard({
    super.key,
    this.flightNumber,
    this.route,
    this.timeRange,
    this.onOpenFlights,
    this.onViewFlightDetails,
    this.onLinkFlight,
    this.onUnlinkFlight,
  });

  final String? flightNumber;
  final String? route;
  final String? timeRange;
  final VoidCallback? onOpenFlights;
  final VoidCallback? onViewFlightDetails;
  final VoidCallback? onLinkFlight;
  final VoidCallback? onUnlinkFlight;

  @override
  Widget build(BuildContext context) {
    final hasFlight = flightNumber != null && route != null;

    return DashboardSection(
      icon: Icons.flight_takeoff,
      title: 'Flights',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasFlight)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flightNumber!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(route!),
                if (timeRange != null) Text(timeRange!),
              ],
            )
          else
            const Text('No linked flight yet.'),
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
                  onPressed: onViewFlightDetails,
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
}
