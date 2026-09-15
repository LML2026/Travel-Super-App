import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/user_facing_error.dart';
import '../../domain/entities/taxi_ride_request.dart';
import '../providers/taxi_hub_provider.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class TaxiResultsPage extends ConsumerWidget {
  const TaxiResultsPage({
    required this.request,
    super.key,
  });

  final TaxiRideRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsync = ref.watch(taxiRideOptionsProvider(request));

    return Scaffold(
      appBar: AppBar(title: Text(context.ui('rideOptions'))),
      body: optionsAsync.when(
        data: (options) {
          if (options.isEmpty) {
            return Center(
              child: Text(context.ui('noProvidersAvailable')),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final option = options[index];

              return Card(
                color: AppColors.cardSurface,
                elevation: 0,
                shadowColor: AppShadows.shadowColor.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.providerName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.textNavy,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          Chip(
                            backgroundColor: AppColors.champagne100,
                            side: const BorderSide(color: AppColors.champagne),
                            label: Text(
                              '${option.currency} ${option.estimatedFare.toStringAsFixed(2)}',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.champagne700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${option.description}. Planning estimate only; no provider order has been placed.',
                        style: AppTextStyles.bodyMuted,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Estimated pickup: ${option.estimatedPickupMinutes} min',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textNavy,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                context.pushTaxiBookingDetails(
                                  TaxiBookingRouteArgs(
                                    request: request,
                                    option: option,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.check_circle_outline),
                              label: Text(context.ui('reviewPlannedRide')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(UserFacingError.message(
              error,
              fallback: 'Ride options are unavailable right now.',
            )),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
