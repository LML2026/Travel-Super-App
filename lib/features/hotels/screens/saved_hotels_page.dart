import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/user_facing_error.dart';
import '../providers/hotel_provider.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class SavedHotelsPage extends ConsumerWidget {
  const SavedHotelsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedHotelsAsync = ref.watch(savedHotelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.ui('savedHotels')),
      ),
      body: savedHotelsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.textSubtle,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(context.ui('failedLoadSavedHotels')),
              const SizedBox(height: AppSpacing.sm),
              Text(
                UserFacingError.message(
                  error,
                  fallback: 'Saved hotels are unavailable right now.',
                ),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (savedHotels) {
          if (savedHotels.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: AppColors.textSubtle,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No saved hotels yet.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Save a hotel from the search results\nto find it here later.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: savedHotels.length,
            itemBuilder: (context, index) {
              final saved = savedHotels[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  onTap: () {
                    context.pushSavedHotelDetails(saved);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with name and image
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.navy50,
                                borderRadius:
                                    BorderRadius.circular(AppRadii.md),
                              ),
                              child: Text(
                                saved.image,
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    saved.name,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: AppColors.textMuted,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        saved.address.isEmpty
                                            ? '${saved.city}${saved.country.isEmpty ? '' : ', ${saved.country}'}'
                                            : saved.address,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    saved.roomType,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 14,
                                        color: AppColors.champagne,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        saved.rating.toStringAsFixed(1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Price and details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_currencySymbol(saved.currency)}${saved.totalPrice.toStringAsFixed(0)}',
                                  style: AppTextStyles.price,
                                ),
                                Text(
                                  '${_currencySymbol(saved.currency)}${saved.pricePerNight.toStringAsFixed(0)} / night',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${saved.beds} bed${saved.beds > 1 ? 's' : ''}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  '${saved.nights} night${saved.nights > 1 ? 's' : ''}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Remove button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ref.read(removeSavedHotelProvider(saved.id));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${saved.name} removed from saved hotels'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: Text(context.ui('remove')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _currencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'EUR':
        return 'EUR ';
      case 'USD':
        return '\$';
      case 'JPY':
        return 'JPY ';
      default:
        return '£';
    }
  }
}
