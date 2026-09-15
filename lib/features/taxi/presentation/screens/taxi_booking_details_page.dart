import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/user_facing_error.dart';
import '../../../trips/domain/entities/trip.dart';
import '../../../trips/presentation/providers/trip_provider.dart';
import '../providers/taxi_hub_provider.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class TaxiBookingDetailsPage extends ConsumerWidget {
  const TaxiBookingDetailsPage({
    required this.args,
    super.key,
  });

  final TaxiBookingRouteArgs args;

  Future<String?> _selectTripId(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final trips = await ref.read(tripsProvider.future);
    if (trips.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.ui('createTripFirstSaveTaxi')),
          ),
        );
      }
      return null;
    }

    final currentSelected = ref.read(taxiTripSelectionProvider);
    String selected = currentSelected ?? trips.first.id;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(context.ui('selectTrip')),
              content: SizedBox(
                width: 360,
                child: DropdownButtonFormField<String>(
                  initialValue: selected,
                  items: trips
                      .map(
                        (Trip trip) => DropdownMenuItem<String>(
                          value: trip.id,
                          child: Text('${trip.title} (${trip.destination})'),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (next) {
                    if (next == null) {
                      return;
                    }
                    setDialogState(() {
                      selected = next;
                    });
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(context.ui('cancel')),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(selected),
                  child: Text(context.ui('save')),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      ref.read(taxiTripSelectionProvider.notifier).state = result;
    }

    return result;
  }

  Future<void> _openRouteOnMap(BuildContext context) async {
    final query =
        '${args.request.pickupAddress} to ${args.request.destinationAddress}';
    final uri =
        Uri.https('www.google.com', '/maps/dir/', {'api': '1', 'query': query});

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.ui('couldNotOpenMapPreview'))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.ui('plannedRideDetails'))),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _TaxiDetailsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  args.option.providerName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textNavy,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Estimated fare: ${args.option.currency} ${args.option.estimatedFare.toStringAsFixed(2)}',
                  style: AppTextStyles.price,
                ),
                Text(
                  'Estimated pickup: ${args.option.estimatedPickupMinutes} min',
                  style: AppTextStyles.bodyMuted,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Planning estimate only. No payment or provider order has been placed.',
                  style: AppTextStyles.bodyMuted,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _TaxiDetailsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Journey',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textNavy,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('${context.ui('pickup')}: ${args.request.pickupAddress}'),
                Text('${context.ui('destination')}: ${args.request.destinationAddress}'),
                Text('${context.ui('passengers')}: ${args.request.passengers}'),
                Text('${context.ui('luggage')}: ${args.request.luggage}'),
                Text(
                  'When: ${args.request.pickupTime?.toString() ?? 'ASAP'}',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => _openRouteOnMap(context),
            icon: const Icon(Icons.map_outlined),
            label: Text(context.ui('viewRouteOnMap')),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            onPressed: () async {
              final tripId = await _selectTripId(context, ref);
              if (tripId == null) {
                return;
              }

              try {
                await ref.read(taxiTransportActionsProvider).saveRideToTrip(
                      tripId: tripId,
                      provider: args.option.providerName,
                      request: args.request,
                      option: args.option,
                    );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Ride saved to trip transport itinerary and expense log.',
                      ),
                    ),
                  );
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(UserFacingError.message(
                        error,
                        fallback: 'We could not save this ride to your trip.',
                      )),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.bookmark_add_outlined),
            label: Text(context.ui('saveRideToItinerary')),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Estimated fare is added as a trip expense when you save the ride to a trip.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.receipt_long_outlined),
            label: Text(context.ui('expenseAutoLoggingInfo')),
          ),
        ],
      ),
    );
  }
}

class _TaxiDetailsCard extends StatelessWidget {
  const _TaxiDetailsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}
