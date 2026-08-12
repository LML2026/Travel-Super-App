import 'package:flutter/material.dart';
import '../models/trip.dart';

class TripDetailsScreen extends StatelessWidget {
  final Trip trip;

  const TripDetailsScreen({
    super.key,
    required this.trip,
  });

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trip.destination),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            trip.destination,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _DetailTile(
            icon: Icons.flight_takeoff,
            label: 'Departure',
            value: _formatDate(trip.departureDate),
          ),
          _DetailTile(
            icon: Icons.flight_land,
            label: 'Return',
            value: _formatDate(trip.returnDate),
          ),
          _DetailTile(
            icon: Icons.people_outline,
            label: 'Travellers',
            value: trip.travellers.toString(),
          ),
          _DetailTile(
            icon: Icons.payments_outlined,
            label: 'Budget',
            value: '${trip.currency} ${trip.budget.toStringAsFixed(2)}',
          ),
          if (trip.notes.isNotEmpty)
            _DetailTile(
              icon: Icons.notes_outlined,
              label: 'Notes',
              value: trip.notes,
            ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
