import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/widgets.dart';
import 'models/dashboard_summary.dart';
import 'providers/dashboard_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Dashboard'),
      ),
      body: summaryAsync.when(
        loading: () => const LoadingIndicator(message: 'Preparing your dashboard...'),
        error: (error, _) => ErrorView(
          title: 'Dashboard unavailable',
          message: error.toString(),
          onRetry: () => ref.invalidate(dashboardSummaryProvider),
        ),
        data: (summary) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${greetingForNow()}, ${summary.userName} 👋', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.lg),
              if (summary.hasUpcomingTrip)
                _UpcomingTripCard(summary: summary)
              else
                const AppEmptyState(
                  icon: Icons.luggage_outlined,
                  title: 'No upcoming trip',
                  message: 'Save a trip to see flights, hotels, weather, and budget here.',
                ),
              const SizedBox(height: AppSpacing.lg),
              Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.55,
                children: [
                  _QuickActionTile(
                    icon: Icons.flight,
                    label: 'Flights',
                    onTap: () => context.pushFlights(),
                  ),
                  _QuickActionTile(
                    icon: Icons.hotel,
                    label: 'Hotels',
                    onTap: () => context.pushHotels(),
                  ),
                  _QuickActionTile(
                    icon: Icons.map_outlined,
                    label: 'Trips',
                    onTap: () => context.pushTrips(),
                  ),
                  _QuickActionTile(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Wallet',
                    onTap: () => _showComingSoon(context, 'Wallet'),
                  ),
                  _QuickActionTile(
                    icon: Icons.translate,
                    label: 'Translate',
                    onTap: () => _showComingSoon(context, 'Translate'),
                  ),
                  _QuickActionTile(
                    icon: Icons.smart_toy_outlined,
                    label: 'AI Assistant',
                    onTap: () => context.pushAiAssistant(),
                  ),
                  _QuickActionTile(
                    icon: Icons.wb_sunny_outlined,
                    label: 'Weather',
                    onTap: () => context.pushWeather(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is planned in the next milestone.')),
    );
  }
}

class _UpcomingTripCard extends StatelessWidget {
  const _UpcomingTripCard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final trip = summary.upcomingTrip!;
    final dateLine =
      '${trip.startDate.day}–${trip.endDate.day} ${_monthName(trip.endDate.month)}';
    final daysRemaining = trip.startDate.difference(DateTime.now()).inDays;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Next Trip', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Text(trip.destination, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          _DashboardLine(icon: Icons.calendar_month, label: dateLine),
          const SizedBox(height: AppSpacing.sm),
          _DashboardLine(
            icon: Icons.schedule,
            label: daysRemaining > 0 ? '$daysRemaining days remaining' : 'Trip in progress',
          ),
          const SizedBox(height: AppSpacing.sm),
          _DashboardLine(
            icon: Icons.flight,
            label: summary.linkedFlight?.airline ?? 'Flight not linked',
          ),
          const SizedBox(height: AppSpacing.sm),
          _DashboardLine(
            icon: Icons.hotel_outlined,
            label: summary.linkedHotel?.name ?? 'No hotel linked yet',
            trailing: summary.linkedHotel == null
                ? null
                : RatingBadge(rating: summary.linkedHotel!.rating),
          ),
          const SizedBox(height: AppSpacing.sm),
          _DashboardLine(
            icon: Icons.wb_sunny_outlined,
            label: summary.weather == null
                ? 'Weather unavailable'
                : '${summary.weather!.tempC.toStringAsFixed(0)}°C ${summary.weather!.description}',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              PriceTag(currency: summary.currency, amount: summary.budget),
            ],
          ),
        ],
      ),
    );
  }

  static String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}

class _DashboardLine extends StatelessWidget {
  const _DashboardLine({
    required this.icon,
    required this.label,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(label)),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 30),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
