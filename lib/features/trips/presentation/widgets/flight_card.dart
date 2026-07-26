import 'package:flutter/material.dart';

import 'dashboard_section.dart';

class FlightCard extends StatelessWidget {
  const FlightCard({
    super.key,
    this.flightNumber,
    this.route,
    this.timeRange,
  });

  final String? flightNumber;
  final String? route;
  final String? timeRange;

  @override
  Widget build(BuildContext context) {
    final hasFlight = flightNumber != null && route != null;

    return DashboardSection(
      icon: Icons.flight_takeoff,
      title: 'Flights',
      child: hasFlight
          ? Column(
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
          : const Text('No linked flight yet.'),
    );
  }
}
