import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/widgets.dart';
import '../../core/utils/user_facing_error.dart';
import '../wallet/domain/entities/wallet.dart';
import '../wallet/presentation/providers/wallet_provider.dart';
import 'models/dashboard_summary.dart';
import 'providers/dashboard_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final walletAsync = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ITAREVO')),
      body: summaryAsync.when(
        loading: () =>
            const LoadingIndicator(message: 'Preparing your dashboard...'),
        error: (error, _) => ErrorView(
          title: 'Dashboard unavailable',
          message: UserFacingError.message(
            error,
            fallback: 'We could not load your travel summary.',
          ),
          onRetry: () => ref.invalidate(dashboardSummaryProvider),
        ),
        data: (summary) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${greetingForNow()}, ${summary.userName}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'London',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (summary.hasUpcomingTrip)
                _UpcomingTripCard(
                    summary: summary,
                    onOpenTrip: () {
                      context.pushTripDetails(summary.upcomingTrip!);
                    },
                    onOpenLiveTrip: () {
                      context.pushLiveTrip(trip: summary.upcomingTrip!);
                    })
              else
                const AppEmptyState(
                  icon: Icons.luggage_outlined,
                  title: 'No upcoming trip',
                  message:
                      'Save a trip to see flights, hotels, weather, and budget here.',
                ),
              const SizedBox(height: AppSpacing.lg),
              _WalletSnapshotCard(walletAsync: walletAsync),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                onTap: () => context.pushMyBookings(),
                child: Row(
                  children: [
                    const Icon(Icons.confirmation_number_outlined, size: 40),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('My Bookings',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          const Text(
                              'Flights, stays and transport across your trips.'),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                onTap: () => context.pushTravelDiscovery(),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.travel_explore_outlined),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Travel Discovery',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Search flights, hotels, rides, activities and restaurants, then add them to a trip.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                onTap: () => context.pushSavedItems(),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bookmark_border),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saved Items',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Flights, hotels, rides, restaurants and places you want to remember.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Quick Booking',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _TransportActionChip(
                    icon: Icons.local_taxi,
                    label: 'Taxi',
                    onTap: () => context.pushTaxi(),
                  ),
                  _TransportActionChip(
                    icon: Icons.flight,
                    label: 'Flights',
                    onTap: () => context.pushFlights(),
                  ),
                  _TransportActionChip(
                    icon: Icons.hotel,
                    label: 'Hotels',
                    onTap: () => context.pushHotels(),
                  ),
                  _TransportActionChip(
                    icon: Icons.train,
                    label: 'Trains',
                    onTap: () => _showComingSoon(context, 'Train booking'),
                  ),
                  _TransportActionChip(
                    icon: Icons.directions_bus,
                    label: 'Buses',
                    onTap: () => _showComingSoon(context, 'Bus planning'),
                  ),
                  _TransportActionChip(
                    icon: Icons.directions_car,
                    label: 'Car Rental',
                    onTap: () => _showComingSoon(context, 'Car rental'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                onTap: () => context.pushAiAssistant(),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.smart_toy_outlined),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Assistant',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'How can I help today?',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                onTap: () => context.pushTranslator(),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.translate_outlined),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Translator',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Text, conversation mode and travel phrases.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
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
  const _UpcomingTripCard({
    required this.summary,
    required this.onOpenTrip,
    required this.onOpenLiveTrip,
  });

  final DashboardSummary summary;
  final VoidCallback onOpenTrip;
  final VoidCallback onOpenLiveTrip;

  @override
  Widget build(BuildContext context) {
    final trip = summary.upcomingTrip!;
    final dateLine =
        '${trip.startDate.day} ${_monthName(trip.startDate.month)} - ${trip.endDate.day} ${_monthName(trip.endDate.month)}';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming Trip', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Text(trip.destination,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          Text(dateLine),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.icon(
                onPressed: onOpenLiveTrip,
                icon: const Icon(Icons.explore_outlined),
                label: const Text('Live Trip'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenTrip,
                icon: const Icon(Icons.dashboard_outlined),
                label: const Text('Dashboard'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

class _WalletSnapshotCard extends StatelessWidget {
  const _WalletSnapshotCard({required this.walletAsync});

  final AsyncValue<Wallet> walletAsync;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wallet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          walletAsync.when(
            loading: () => const Text('Loading balances...'),
            error: (_, __) => const Text('Sign in to view wallet balances.'),
            data: (wallet) {
              final balances = wallet.balances;
              if (balances.isEmpty) {
                return const Text('No balances yet.');
              }

              final sortedKeys = balances.keys.toList()..sort();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: sortedKeys
                    .take(3)
                    .map(
                      (currency) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '$currency ${balances[currency]!.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TransportActionChip extends StatelessWidget {
  const _TransportActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppColors.primary),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
