import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/user_facing_error.dart';
import '../../domain/entities/trip.dart';
import '../providers/trip_provider.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class TripListPage extends ConsumerWidget {
  const TripListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.ui('myTrips')),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.warmWhite,
        child: const Icon(Icons.add),
        onPressed: () {
          context.pushCreateTrip();
        },
      ),
      body: tripsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(UserFacingError.message(
            error,
            fallback: 'We could not load your trips. Please try again.',
          )),
        ),
        data: (trips) {
          if (trips.isEmpty) {
            return const _EmptyTripsView();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              return TripCard(
                trip: trips[index],
              );
            },
          );
        },
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.trip,
  });

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      elevation: 1,
      color: AppColors.cardSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.lg),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.navy50,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: const Icon(Icons.flight_takeoff, color: AppColors.navy),
        ),
        title: Text(
          trip.destination,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textNavy,
                fontWeight: FontWeight.w700,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Text(
              "${formatter.format(trip.departureDate)}"
              " → "
              "${formatter.format(trip.returnDate)}",
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              "Budget: ${trip.currency} ${trip.budget.toStringAsFixed(2)}",
              style: AppTextStyles.label.copyWith(color: AppColors.textNavy),
            ),
            Text(
              "Travellers: ${trip.travellers}",
              style: AppTextStyles.label,
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.champagne),
        onTap: () {
          context.pushTripDetails(trip);
        },
      ),
    );
  }
}

class _EmptyTripsView extends StatelessWidget {
  const _EmptyTripsView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.luggage,
            size: 80,
            color: AppColors.navy,
          ),
          SizedBox(height: AppSpacing.xl),
          Text(
            "No trips yet",
            style: AppTextStyles.title,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            "Tap + to create your first trip.",
            style: AppTextStyles.bodyMuted,
          ),
        ],
      ),
    );
  }
}
