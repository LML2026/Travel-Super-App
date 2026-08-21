import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../maps/models/places_prefill.dart';

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
            subtitle: 'Compare available ride options',
            onTap: () => context.pushTaxi(),
          ),
          _TransportTile(
            icon: Icons.airport_shuttle,
            title: 'Airport Transfer',
            subtitle: 'Plan an airport ride with the existing taxi flow',
            onTap: () => context.pushTaxi(),
          ),
          _TransportTile(
            icon: Icons.train,
            title: 'Train',
            subtitle: 'Not available in this release',
            onTap: null,
          ),
          _TransportTile(
            icon: Icons.directions_bus,
            title: 'Bus',
            subtitle: 'Not available in this release',
            onTap: null,
          ),
          _TransportTile(
            icon: Icons.directions_boat,
            title: 'Ferry',
            subtitle: 'Not available in this release',
            onTap: null,
          ),
          _TransportTile(
            icon: Icons.pedal_bike,
            title: 'Bike',
            subtitle: 'Not available in this release',
            onTap: null,
          ),
          _TransportTile(
            icon: Icons.electric_scooter,
            title: 'Scooter',
            subtitle: 'Not available in this release',
            onTap: null,
          ),
          _TransportTile(
            icon: Icons.directions_walk,
            title: 'Walking',
            subtitle: 'Open walking routes in Maps',
            onTap: () => context.pushMaps(
              prefill: const PlacesPrefill(
                query: 'Walking route',
                title: 'Walking route',
              ),
            ),
          ),
        ],
      ),
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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: onTap == null ? Colors.grey : null),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: onTap == null
            ? const Icon(Icons.remove_circle_outline)
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
