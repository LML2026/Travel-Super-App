import 'package:flutter/material.dart';

import 'dashboard_section.dart';

class MapCard extends StatelessWidget {
  const MapCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardSection(
      icon: Icons.map_outlined,
      title: 'Map',
      child: Text('Trip map and routes will appear here.'),
    );
  }
}
