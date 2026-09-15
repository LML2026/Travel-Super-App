import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../maps/models/places_prefill.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class TransportHubPage extends StatelessWidget {
  const TransportHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.ui('transportHub')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _TransportTile(
            icon: Icons.local_taxi,
            title: 'Taxi',
            subtitle: 'Plan and save estimated rides to your trips',
            onTap: () => context.pushTaxi(),
          ),
          _TransportTile(
            icon: Icons.directions_car,
            title: 'Ride Sharing',
            subtitle: 'Compare available ride options',
            onTap: () => context.pushTaxi(),
          ),
          _TransportTile(
            icon: Icons.airport_shuttle,
            title: 'Airport Transfer',
            subtitle: 'Plan an airport ride with the existing taxi flow',
            onTap: () => context.pushTaxi(),
          ),
          _TransportTile(
            icon: Icons.train,
            title: 'Train',
            subtitle: 'Not available in this release',
            onTap: null,
          ),
          _TransportTile(
            icon: Icons.directions_bus,
            title: 'Bus',
            subtitle: 'Not available in this release',
            onTap: null,
          ),
          _TransportTile(
            icon: Icons.directions_boat,
            title: 'Ferry',
            subtitle: 'Not available in this release',
            onTap: null,
          ),
          _TransportTile(
            icon: Icons.pedal_bike,
            title: 'Bike',
            subtitle: 'Not available in this release',
            onTap: null,
          ),
          _TransportTile(
            icon: Icons.electric_scooter,
            title: 'Scooter',
            subtitle: 'Not available in this release',
            onTap: null,
          ),
          _TransportTile(
            icon: Icons.directions_walk,
            title: 'Walking',
            subtitle: 'Open walking routes in Maps',
            onTap: () => context.pushMaps(
              prefill: const PlacesPrefill(
                query: 'Walking route',
                title: 'Walking route',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransportTile extends StatelessWidget {
  const _TransportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardSurface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: onTap == null ? AppColors.disabledText : AppColors.navy,
        ),
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(subtitle, style: AppTextStyles.bodyMuted),
        trailing: onTap == null
            ? const Icon(
                Icons.remove_circle_outline,
                color: AppColors.disabledText,
              )
            : const Icon(Icons.chevron_right, color: AppColors.champagne700),
        onTap: onTap,
      ),
    );
  }
}
