import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class FlightsPage extends StatelessWidget {
  const FlightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.ui('flights')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Text(
            'Where would you like to fly?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Search and compare live flight offers.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.card),
              onTap: () {
                context.pushFlightSearch();
              },
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.navy50,
                      child: Icon(
                        Icons.flight_takeoff,
                        size: 30,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.ui('searchFlights'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          const Text(
                            'Compare routes, prices and airlines',
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: Text(context.ui('recentSearches')),
              subtitle: const Text(
                'View your recent flight searches',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.pushRecentFlights();
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: ListTile(
              leading: const Icon(Icons.favorite_outline),
              title: Text(context.ui('savedFlights')),
              subtitle: const Text(
                'View flight offers saved for later',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.pushSavedFlights();
              },
            ),
          ),
        ],
      ),
    );
  }
}
