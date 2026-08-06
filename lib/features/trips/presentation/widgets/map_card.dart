import 'package:flutter/material.dart';

import '../../domain/entities/trip.dart';
import 'dashboard_section.dart';

class MapCard extends StatelessWidget {
  const MapCard({
    super.key,
    this.trip,
  });

  final Trip? trip;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      icon: Icons.map_outlined,
      title: 'Map',
      child: Text(
        trip != null
            ? 'Map for ${trip!.destination} trip.'
            : 'Trip map and routes will appear here.',
      ),
    );
  }
}
