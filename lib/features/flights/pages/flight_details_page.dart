import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../trips/presentation/providers/trip_provider.dart';
import '../../trips/presentation/providers/trip_booking_link_provider.dart';
import '../../trips/domain/entities/trip.dart';
import '../models/flight.dart';
import '../models/saved_flight.dart';
import '../providers/flight_provider.dart';
import '../../../core/utils/flight_formatter.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

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

  Future<void> _addToTrip(BuildContext context, WidgetRef ref) async {
    final trips = await ref.read(tripsProvider.future);
    if (trips.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(context.ui('createTripBeforeLinkingFlight'))),
        );
      }
      return;
    }
    final trip = await showModalBottomSheet<Trip>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: trips
              .map((trip) => ListTile(
                    title: Text(trip.title),
                    subtitle: Text(trip.destination),
                    onTap: () => Navigator.pop(sheetContext, trip),
                  ))
              .toList(growable: false),
        ),
      ),
    );
    if (trip == null) return;
    final link = await ref.read(tripBookingLinkActionsProvider).linkFlight(
          trip: trip,
          flight: flight,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            link.isSuccess
                ? link.wasAlreadyLinked
                    ? 'This flight is already linked to ${trip.title}.'
                    : 'Flight added to ${trip.title}.'
                : 'We could not link this flight. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSavedAsync = ref.watch(isFlightSavedProvider(flight.id));
    final formattedDuration = formatDuration(flight.duration);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.ui('flightDetails')),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section with airline info
            Container(
              color: AppColors.navy50,
              padding: const EdgeInsets.all(AppSpacing.xl),
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
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              flight.airline,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              'Flight ${flight.flightNumber}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(color: AppColors.champagne100),
                        ),
                        Text(
                          '${flight.currency} ${flight.amount.toStringAsFixed(2)}',
                          style: AppTextStyles.price.copyWith(
                            color: AppColors.warmWhite,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: AppSpacing.sm),
                              Container(
                                width: 2,
                                height: 40,
                                color: AppColors.border,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                formattedDuration,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Container(
                                width: 2,
                                height: 40,
                                color: AppColors.border,
                              ),
                              const SizedBox(height: AppSpacing.sm),
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

                  const SizedBox(height: AppSpacing.xl),

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
                          label: context.ui('cabinClass'),
                          value: flight.stops == 0 ? 'Economy' : 'Mixed',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Route information
                  _DetailSection(
                    title: 'Route',
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.warmWhite,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(AppRadii.md),
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
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(context.ui('from'),
                                    style: AppTextStyles.label,
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_forward,
                                  size: 32, color: AppColors.champagne),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    flight.destination,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(context.ui('to'),
                                    style: AppTextStyles.label,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Action buttons
                  Row(
                    children: [
                      // Save button
                      Expanded(
                        child: isSavedAsync.when(
                          data: (isSaved) => OutlinedButton.icon(
                            onPressed: () {
                              if (isSaved) {
                                ref
                                    .read(getSavedFlightIdProvider(flight.id)
                                        .future)
                                    .then((saveId) {
                                  if (saveId != null) {
                                    ref.read(removeSavedFlightProvider(saveId)
                                        .future);
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
                                ref.read(
                                    saveFlightProvider(savedFlight).future);
                              }
                            },
                            icon: Icon(
                              isSaved ? Icons.favorite : Icons.favorite_border,
                              color: isSaved ? AppColors.error : null,
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
                            label: Text(context.ui('loading')),
                          ),
                          error: (_, __) => OutlinedButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.error),
                            label: Text(context.ui('error')),
                          ),
                        ),
                      ),

                      const SizedBox(width: AppSpacing.md),

                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _addToTrip(context, ref),
                          icon: const Icon(Icons.add_location_alt_outlined),
                          label: Text(context.ui('addToTrip')),
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
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
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
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.xl,
      ),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.champagne,
                  border: Border.all(color: AppColors.warmWhite, width: 3),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  airport,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall,
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
