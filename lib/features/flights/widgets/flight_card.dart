import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/flight.dart';
import '../../../core/utils/flight_formatter.dart';
import '../../../core/utils/user_facing_error.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

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

  String? get _sourceLabel {
    switch (widget.flight.dataSource) {
      case FlightDataSource.duffelTest:
        return 'Test data';
      case FlightDataSource.backend:
        return null;
      case FlightDataSource.demo:
        return 'Demo flight data';
    }
  }

  void _navigateToDetails() {
    context.pushFlightDetails(widget.flight);
  }

  Future<void> _saveFlight(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.ui('signInSaveFlights')),
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
        'flightId': widget.flight.id,
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
        'cabinClass': widget.flight.cabinClass,
        'source': widget.flight.dataSource.name,
        'savedAt': DateTime.now().toIso8601String(),
      });

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.ui('flightSaved')),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(UserFacingError.message(
            error,
            fallback: 'We could not save this flight. Please try again.',
          )),
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
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              if (_sourceLabel case final label?) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
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

                  const SizedBox(width: AppSpacing.md),

                  // Airline name and flight number
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.flight.airline,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          widget.flight.flightNumber,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // Price
                  Text(
                    '${widget.flight.currency} ${widget.flight.amount.toStringAsFixed(2)}',
                    style: AppTextStyles.price,
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  // Heart button
                  IconButton(
                    tooltip: context.ui('saveFlight'),
                    onPressed: () => _saveFlight(context),
                    icon: const Icon(Icons.favorite_border),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Route airports
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.flight.origin,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.navy600,
                        ),
                  ),
                  Text(
                    widget.flight.destination,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.navy600,
                        ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Timeline with times
              Row(
                children: [
                  // Departure time
                  Column(
                    children: [
                      Text(
                        departureTime,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Timeline arrow
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          formattedDuration,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        CustomPaint(
                          painter: _TimelinePainter(),
                          size: const Size(double.infinity, 20),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Arrival time
                  Column(
                    children: [
                      Text(
                        arrivalTime,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Duration, stops, and cabin
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Duration',
                        style: AppTextStyles.label,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        formattedDuration,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stops',
                        style: AppTextStyles.label,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        stopsText,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  if (widget.flight.cabinClass.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.ui('cabin'),
                          style: AppTextStyles.label,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.flight.cabinClass,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Details button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onBookPressed ?? _navigateToDetails,
                  icon: const Icon(Icons.info_outline),
                  label: Text(context.ui('viewDetails')),
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
      ..color = AppColors.borderStrong
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
