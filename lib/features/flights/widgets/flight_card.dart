import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../app/app_routes.dart';
import '../models/flight.dart';
import '../models/saved_flight.dart';
import '../providers/flight_provider.dart';
import '../../../core/utils/flight_formatter.dart';

class FlightCard extends ConsumerStatefulWidget {
  final Flight flight;
  final VoidCallback? onBookPressed;

  const FlightCard({
    super.key,
    required this.flight,
    this.onBookPressed,
  });

  @override
  ConsumerState<FlightCard> createState() => _FlightCardState();
}

class _FlightCardState extends ConsumerState<FlightCard> {
  String _getTimeOnly(String isoDateTime) {
    try {
      return isoDateTime.split('T')[1].substring(0, 5);
    } catch (e) {
      return '--:--';
    }
  }

  String _getStopsText() {
    return widget.flight.stops == 0 
        ? '🟢 Direct' 
        : '🟠 ${widget.flight.stops} Stop${widget.flight.stops > 1 ? 's' : ''}';
  }

  void _navigateToDetails() {
    context.pushFlightDetails(widget.flight);
  }

  Future<void> _saveFlight(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to save flights.'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('saved_flights')
          .doc(widget.flight.id)
          .set({
        'id': widget.flight.id,
        'airline': widget.flight.airline,
        'airlineLogo': widget.flight.airlineLogo,
        'flightNumber': widget.flight.flightNumber,
        'origin': widget.flight.origin,
        'destination': widget.flight.destination,
        'departureAt': widget.flight.departureAt,
        'arrivalAt': widget.flight.arrivalAt,
        'duration': widget.flight.duration,
        'stops': widget.flight.stops,
        'amount': widget.flight.amount,
        'currency': widget.flight.currency,
        'savedAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Flight saved'),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save flight: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final departureTime = _getTimeOnly(widget.flight.departureAt);
    final arrivalTime = _getTimeOnly(widget.flight.arrivalAt);
    final formattedDuration = formatDuration(widget.flight.duration);
    final stopsText = _getStopsText();

    return GestureDetector(
      onTap: _navigateToDetails,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header: Airline, Logo, Price, Heart
              Row(
                children: [
                  // Logo
                  if (widget.flight.airlineLogo.isNotEmpty)
                    Image.network(
                      widget.flight.airlineLogo,
                      width: 40,
                      height: 40,
                      errorBuilder: (_, __, ___) => 
                          const Icon(Icons.flight, size: 40),
                    )
                  else
                    const Icon(Icons.flight, size: 40),
                  
                  const SizedBox(width: 12),
                  
                  // Airline name and flight number
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.flight.airline,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.flight.flightNumber,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Price
                  Text(
                    '${widget.flight.currency} ${widget.flight.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Heart button
                  IconButton(
                    tooltip: 'Save flight',
                    onPressed: () => _saveFlight(context),
                    icon: const Icon(Icons.favorite_border),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Route airports
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.flight.origin,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    widget.flight.destination,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Timeline with times
              Row(
                children: [
                  // Departure time
                  Column(
                    children: [
                      Text(
                        departureTime,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Timeline arrow
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          formattedDuration,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        CustomPaint(
                          painter: _TimelinePainter(),
                          size: const Size(double.infinity, 20),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Arrival time
                  Column(
                    children: [
                      Text(
                        arrivalTime,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Duration, stops, and details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Duration',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDuration,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stops',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stopsText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Book button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onBookPressed ?? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Booking ${widget.flight.flightNumber} - Coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.flight_takeoff),
                  label: const Text('Book Flight'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the flight timeline arrow
class _TimelinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final center = size.height / 2;
    
    // Draw line
    canvas.drawLine(
      Offset(0, center),
      Offset(size.width - 12, center),
      paint,
    );

    // Draw arrow
    final arrowSize = 8.0;
    canvas.drawLine(
      Offset(size.width - arrowSize, center - arrowSize / 2),
      Offset(size.width, center),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - arrowSize, center + arrowSize / 2),
      Offset(size.width, center),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
