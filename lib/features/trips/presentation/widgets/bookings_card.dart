import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/models/booking.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/trip_bookings_provider.dart';
import '../../../../core/utils/user_facing_error.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class BookingsCard extends ConsumerWidget {
  final String tripId;

  const BookingsCard({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(tripBookingsProvider(tripId));

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 1,
      color: AppColors.cardSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => context.pushTripBookings(tripId),
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bookings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textNavy,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.champagne),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              bookingsAsync.when(
                data: (bookings) {
                  if (bookings.isEmpty) {
                    return const Text(
                      'No saved booking plans yet. Search for flights or hotels to add one.',
                      style: AppTextStyles.bodyMuted,
                    );
                  }

                  return Row(
                    children: [
                      _BookingBadge(
                        icon: Icons.flight_takeoff,
                        count: bookings
                            .where((b) => b.type == BookingType.flight)
                            .length,
                        label: context.ui('flights'),
                      ),
                      const SizedBox(width: 16),
                      _BookingBadge(
                        icon: Icons.hotel,
                        count: bookings
                            .where((b) => b.type == BookingType.hotel)
                            .length,
                        label: 'Hotels',
                      ),
                      const SizedBox(width: 16),
                      _BookingBadge(
                        icon: Icons.local_taxi,
                        count: bookings
                            .where((b) => b.type == BookingType.transport)
                            .length,
                        label: 'Transport',
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: LinearProgressIndicator()),
                error: (error, _) => Text(
                  UserFacingError.message(
                    error,
                    fallback: 'Bookings are unavailable right now.',
                  ),
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;

  const _BookingBadge({
    required this.icon,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final color = count > 0 ? AppColors.navy : AppColors.textSubtle;

    return Column(
      children: [
        Badge(
          label: Text(count.toString()),
          isLabelVisible: count > 0,
          backgroundColor: color,
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: count > 0 ? AppColors.textNavy : AppColors.textMuted,
            fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
