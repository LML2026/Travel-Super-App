import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/flight_formatter.dart';
import '../models/saved_flight.dart';
import '../providers/flight_provider.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

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
        title: Text(context.ui('savedFlightDetails')),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: AppColors.navy50,
              padding: const EdgeInsets.all(AppSpacing.xl),
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
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Saved Price',
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
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _DetailSection(
                    title: 'Flight Details',
                    child: Column(
                      children: [
                        _DetailsRow(
                            label: 'Duration', value: formattedDuration),
                        _DetailsRow(label: 'Stops', value: _getStopsText()),
                        _DetailsRow(
                            label: context.ui('cabinClass'), value: flight.cabinClass),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
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
                          label: Text(context.ui('remove')),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${flight.flightNumber} is saved. Live ticket purchase is not available yet.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.flight_takeoff),
                          label: Text(context.ui('saveFlightPlan')),
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
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
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
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.xl,
      ),
      child: Row(
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
  const _DetailsRow({required this.label, required this.value});

  final String label;
  final String value;

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
