import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flight.dart';
import '../models/saved_flight.dart';
import '../providers/flight_provider.dart';
import '../../../core/utils/flight_formatter.dart';

class FlightDetailsPage extends ConsumerWidget {
  final Flight flight;

  const FlightDetailsPage({
    super.key,
    required this.flight,
  });

  String _getFullDateTime(String isoDateTime) {
    try {
      final parts = isoDateTime.split('T');
      final date = parts[0];
      final time = parts[1].substring(0, 5);
      return '$date $time';
    } catch (e) {
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
    final isSavedAsync = ref.watch(isFlightSavedProvider(flight.id));
    final formattedDuration = formatDuration(flight.duration);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section with airline info
            Container(
              color: const Color(0xFF1976D2).withValues(alpha: 0.1),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Airline logo and name
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
                  
                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Price',
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
                  // Flight timeline
                  _DetailSection(
                    title: 'Flight Timeline',
                    child: Column(
                      children: [
                        _TimelineItem(
                          airport: flight.origin,
                          time: _getFullDateTime(flight.departureAt),
                          label: 'Departure',
                          isFirst: true,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              Container(
                                width: 2,
                                height: 40,
                                color: Colors.grey.shade300,
                              ),
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
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        _TimelineItem(
                          airport: flight.destination,
                          time: _getFullDateTime(flight.arrivalAt),
                          label: 'Arrival',
                          isFirst: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Flight details grid
                  _DetailSection(
                    title: 'Flight Details',
                    child: Column(
                      children: [
                        _DetailsRow(
                          label: 'Duration',
                          value: formattedDuration,
                        ),
                        _DetailsRow(
                          label: 'Stops',
                          value: _getStopsText(),
                        ),
                        _DetailsRow(
                          label: 'Cabin Class',
                          value: flight.stops == 0 ? 'Economy' : 'Mixed',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Route information
                  _DetailSection(
                    title: 'Route',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    flight.origin,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'From',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_forward, size: 32, color: Color(0xFF1976D2)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    flight.destination,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'To',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      // Save button
                      Expanded(
                        child: isSavedAsync.when(
                          data: (isSaved) => OutlinedButton.icon(
                            onPressed: () {
                              if (isSaved) {
                                ref.read(getSavedFlightIdProvider(flight.id).future).then((saveId) {
                                  if (saveId != null) {
                                    ref.read(removeSavedFlightProvider(saveId).future);
                                  }
                                });
                              } else {
                                final savedFlight = SavedFlight(
                                  id: '',
                                  flightId: flight.id,
                                  airline: flight.airline,
                                  airlineLogo: flight.airlineLogo,
                                  flightNumber: flight.flightNumber,
                                  origin: flight.origin,
                                  destination: flight.destination,
                                  departureAt: flight.departureAt,
                                  arrivalAt: flight.arrivalAt,
                                  duration: flight.duration,
                                  stops: flight.stops,
                                  amount: flight.amount,
                                  currency: flight.currency,
                                  cabinClass: 'economy',
                                  savedAt: DateTime.now(),
                                );
                                ref.read(saveFlightProvider(savedFlight).future);
                              }
                            },
                            icon: Icon(
                              isSaved ? Icons.favorite : Icons.favorite_border,
                              color: isSaved ? Colors.red : null,
                            ),
                            label: Text(isSaved ? 'Saved' : 'Save Flight'),
                          ),
                          loading: () => OutlinedButton.icon(
                            onPressed: null,
                            icon: const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            label: const Text('Loading...'),
                          ),
                          error: (_, __) => OutlinedButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.error),
                            label: const Text('Error'),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Book button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Booking ${flight.flightNumber} - Coming soon!'),
                              ),
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
  final String title;
  final Widget child;

  const _DetailSection({
    required this.title,
    required this.child,
  });

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
  final String airport;
  final String time;
  final String label;
  final bool isFirst;

  const _TimelineItem({
    required this.airport,
    required this.time,
    required this.label,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        children: [
          Column(
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
            ],
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
  final String label;
  final String value;

  const _DetailsRow({
    required this.label,
    required this.value,
  });

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
