import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/user_facing_error.dart';

import '../../../trips/domain/entities/trip.dart';
import '../../../trips/presentation/providers/trip_provider.dart';
import '../providers/taxi_hub_provider.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class SavedRidesPage extends ConsumerWidget {
  const SavedRidesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.ui('savedRides'))),
      body: tripsAsync.when(
        data: (trips) {
          if (trips.isEmpty) {
            return const Center(
              child: Text(
                'No trips found. Create a trip to save transport rides.',
                textAlign: TextAlign.center,
              ),
            );
          }

          final selectedTripId = ref.watch(taxiTripSelectionProvider);
          final effectiveTripId = selectedTripId ?? trips.first.id;

          if (selectedTripId == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(taxiTripSelectionProvider.notifier).state =
                  trips.first.id;
            });
          }

          final ridesAsync =
              ref.watch(taxiSavedRidesForTripProvider(effectiveTripId));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: effectiveTripId,
                  decoration: InputDecoration(
                    labelText: context.ui('trip'),
                    border: OutlineInputBorder(),
                  ),
                  items: trips
                      .map(
                        (Trip trip) => DropdownMenuItem<String>(
                          value: trip.id,
                          child: Text('${trip.title} (${trip.destination})'),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    ref.read(taxiTripSelectionProvider.notifier).state = value;
                  },
                ),
              ),
              Expanded(
                child: ridesAsync.when(
                  data: (rides) {
                    if (rides.isEmpty) {
                      return const Center(
                        child: Text(
                          'No saved rides yet for this trip.',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: rides.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final ride = rides[index];
                        return Card(
                          color: AppColors.cardSurface,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.card),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.route_outlined,
                              color: AppColors.navy,
                            ),
                            title: Text(
                              '${ride.pickupAddress} -> ${ride.destinationAddress}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: AppColors.textNavy,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            subtitle: Text(
                              '${ride.provider} | ${ride.currency} ${ride.estimatedFare.toStringAsFixed(2)}',
                              style: AppTextStyles.bodyMuted,
                            ),
                            trailing: Text(
                              ride.scheduledAt == null
                                  ? 'ASAP'
                                  : '${ride.scheduledAt}',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.champagne700,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(UserFacingError.message(
                        error,
                        fallback: 'Saved rides are unavailable right now.',
                      )),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(UserFacingError.message(
              error,
              fallback: 'Trips are unavailable right now.',
            )),
          ),
        ),
      ),
    );
  }
}
