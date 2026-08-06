import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/flight_formatter.dart';
import '../models/saved_flight.dart';
import '../providers/flight_provider.dart';

class SavedFlightDetailsPage extends ConsumerWidget {
  const SavedFlightDetailsPage({
    super.key,
    required this.flight,
  });

  final SavedFlight flight;

  String _getFullDateTime(String isoDateTime) {
    try {
      final parts = isoDateTime.split('T');
      final date = parts[0];
      final time = parts[1].substring(0, 5);
      return '$date $time';
    } catch (_) {
      return isoDateTime;
    }
  }

  String _getStopsText() {
    return flight.stops == 0
        ? '🟢 Direct Flight'
        : '🟠 ${flight.stops} Stop${flight.stops > 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedDuration = formatDuration(flight.duration);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Flight Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: const Color(0xFF1976D2).withValues(alpha: 0.1),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (flight.airlineLogo.isNotEmpty)
                        Image.network(
                          flight.airlineLogo,
                          width: 60,
                          height: 60,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.flight, size: 60),
                        )
                      else
                        const Icon(Icons.flight, size: 60),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              flight.airline,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Flight ${flight.flightNumber}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Saved Price',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${flight.currency} ${flight.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailSection(
                    title: 'Flight Timeline',
                    child: Column(
                      children: [
                        _TimelineItem(
                          airport: flight.origin,
                          time: _getFullDateTime(flight.departureAt),
                          label: 'Departure',
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              Container(
                                  width: 2,
                                  height: 40,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 8),
                              Text(
                                formattedDuration,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                  width: 2,
                                  height: 40,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        _TimelineItem(
                          airport: flight.destination,
                          time: _getFullDateTime(flight.arrivalAt),
                          label: 'Arrival',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _DetailSection(
                    title: 'Flight Details',
                    child: Column(
                      children: [
                        _DetailsRow(
                            label: 'Duration', value: formattedDuration),
                        _DetailsRow(label: 'Stops', value: _getStopsText()),
                        _DetailsRow(
                            label: 'Cabin Class', value: flight.cabinClass),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await ref.read(
                                removeSavedFlightProvider(flight.id).future);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        '${flight.flightNumber} removed from saved flights')),
                              );
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Remove'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Booking ${flight.flightNumber} - Coming soon!')),
                            );
                          },
                          icon: const Icon(Icons.flight_takeoff),
                          label: const Text('Book Flight'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.airport,
    required this.time,
    required this.label,
  });

  final String airport;
  final String time;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1976D2),
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  airport,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsRow extends StatelessWidget {
  const _DetailsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
