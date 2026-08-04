import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';

class TransportHubPage extends StatelessWidget {
  const TransportHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Hub'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TransportTile(
            icon: Icons.local_taxi,
            title: 'Taxi',
            subtitle: 'Book rides with provider deep-link handoff',
            onTap: () => context.pushTaxi(),
          ),
          _TransportTile(
            icon: Icons.directions_car,
            title: 'Ride Sharing',
            subtitle: 'Compare app-based ride options',
            onTap: () => _showComingSoon(context, 'Ride Sharing'),
          ),
          _TransportTile(
            icon: Icons.airport_shuttle,
            title: 'Airport Transfer',
            subtitle: 'Pre-book fixed airport transfer',
            onTap: () => _showComingSoon(context, 'Airport Transfer'),
          ),
          _TransportTile(
            icon: Icons.train,
            title: 'Train',
            subtitle: 'Plan rail journeys and schedules',
            onTap: () => _showComingSoon(context, 'Train'),
          ),
          _TransportTile(
            icon: Icons.directions_bus,
            title: 'Bus',
            subtitle: 'Find local and intercity routes',
            onTap: () => _showComingSoon(context, 'Bus'),
          ),
          _TransportTile(
            icon: Icons.directions_boat,
            title: 'Ferry',
            subtitle: 'Browse crossings and booking links',
            onTap: () => _showComingSoon(context, 'Ferry'),
          ),
          _TransportTile(
            icon: Icons.pedal_bike,
            title: 'Bike',
            subtitle: 'Find nearby bike hire options',
            onTap: () => _showComingSoon(context, 'Bike'),
          ),
          _TransportTile(
            icon: Icons.electric_scooter,
            title: 'Scooter',
            subtitle: 'Find shared scooter zones',
            onTap: () => _showComingSoon(context, 'Scooter'),
          ),
          _TransportTile(
            icon: Icons.directions_walk,
            title: 'Walking',
            subtitle: 'Open walking route guidance',
            onTap: () => _showComingSoon(context, 'Walking'),
          ),
        ],
      ),
    );
  }

  static void _showComingSoon(BuildContext context, String mode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$mode integration is coming soon.')),
    );
  }
}

class _TransportTile extends StatelessWidget {
  const _TransportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
