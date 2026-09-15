import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/user_facing_error.dart';
import '../../core/widgets/widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extensions.dart';
import '../wallet/domain/entities/wallet.dart';
import '../wallet/presentation/providers/wallet_provider.dart';
import 'models/dashboard_summary.dart';
import 'providers/dashboard_provider.dart';

String _languageName(String code) {
  const names = <String, String>{
    'ar': 'العربية',
    'bg': 'Български',
    'cs': 'Čeština',
    'da': 'Dansk',
    'de': 'Deutsch',
    'el': 'Ελληνικά',
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'it': 'Italiano',
    'ja': '日本語',
    'nl': 'Nederlands',
    'pl': 'Polski',
    'pt': 'Português',
    'ro': 'Română',
    'ru': 'Русский',
    'sv': 'Svenska',
    'tr': 'Türkçe',
    'zh': '中文',
  };
  return names[code] ?? code.toUpperCase();
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final walletAsync = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('ITAREVO'),
        leadingWidth: 120,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: PopupMenuButton<String>(
            tooltip: context.ui('language'),
            onSelected: (value) {
              ref.read(appLocaleProvider.notifier).state = Locale(value);
            },
            itemBuilder: (context) => AppLocalizations.supportedLocales
                .map(
                  (locale) => PopupMenuItem<String>(
                    value: locale.languageCode,
                    child: Text(_languageName(locale.languageCode)),
                  ),
                )
                .toList(growable: false),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.language,
                  color: Colors.white,
                  size: 21,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    _languageName(
                      ref.watch(appLocaleProvider)?.languageCode ?? 'en',
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: context.ui('profile'),
            onPressed: () => context.pushProfile(),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DashboardSummarySection(
              summaryAsync: summaryAsync,
              onRetry: () => ref.invalidate(dashboardSummaryProvider),
            ),
            const SizedBox(height: AppSpacing.lg),
            _WalletSnapshotCard(walletAsync: walletAsync),
            const SizedBox(height: AppSpacing.lg),
            _HomeNavigationCard(
              icon: Icons.translate_outlined,
              title: AppLocalizations.of(context)!.translator,
              subtitle: AppLocalizations.of(context)!.translatorSubtitle,
              onTap: () => context.pushTranslator(),
            ),
            const SizedBox(height: AppSpacing.lg),
            _HomeNavigationCard(
              icon: Icons.person_outline,
              title: AppLocalizations.of(context)!.profile,
              subtitle: AppLocalizations.of(context)!.profileSubtitle,
              onTap: () => context.pushProfile(),
            ),
            const SizedBox(height: AppSpacing.lg),
            _HomeNavigationCard(
              icon: Icons.confirmation_number_outlined,
              title: AppLocalizations.of(context)!.myBookings,
              subtitle: AppLocalizations.of(context)!.myBookingsSubtitle,
              onTap: () => context.pushMyBookings(),
            ),
            const SizedBox(height: AppSpacing.lg),
            _HomeNavigationCard(
              icon: Icons.travel_explore_outlined,
              title: AppLocalizations.of(context)!.travelDiscovery,
              subtitle: AppLocalizations.of(context)!.travelDiscoverySubtitle,
              onTap: () => context.pushTravelDiscovery(),
            ),
            const SizedBox(height: AppSpacing.lg),
            _HomeNavigationCard(
              icon: Icons.bookmark_border,
              title: AppLocalizations.of(context)!.savedItems,
              subtitle: AppLocalizations.of(context)!.savedItemsSubtitle,
              onTap: () => context.pushSavedItems(),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppLocalizations.of(context)!.quickBooking,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textNavy,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _TransportActionChip(
                  icon: Icons.local_taxi,
                  label: AppLocalizations.of(context)!.taxi,
                  onTap: () => context.pushTaxi(),
                ),
                _TransportActionChip(
                  icon: Icons.flight,
                  label: AppLocalizations.of(context)!.flights,
                  onTap: () => context.pushFlights(),
                ),
                _TransportActionChip(
                  icon: Icons.hotel,
                  label: AppLocalizations.of(context)!.hotels,
                  onTap: () => context.pushHotels(),
                ),
                _TransportActionChip(
                  icon: Icons.train,
                  label: AppLocalizations.of(context)!.trains,
                  onTap: () => _showComingSoon(context, 'Train booking'),
                ),
                _TransportActionChip(
                  icon: Icons.directions_bus,
                  label: AppLocalizations.of(context)!.buses,
                  onTap: () => _showComingSoon(context, 'Bus planning'),
                ),
                _TransportActionChip(
                  icon: Icons.directions_car,
                  label: AppLocalizations.of(context)!.carRental,
                  onTap: () => _showComingSoon(context, 'Car rental'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _HomeNavigationCard(
              icon: Icons.smart_toy_outlined,
              title: AppLocalizations.of(context)!.aiAssistant,
              subtitle: AppLocalizations.of(context)!.aiAssistantSubtitle,
              onTap: () => context.pushAiAssistant(),
            ),
          ],
        ),
      ),
    );
  }

  static void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('$feature ${context.ui('plannedNextMilestoneSuffix')}')),
    );
  }
}

class _DashboardSummarySection extends StatelessWidget {
  const _DashboardSummarySection({
    required this.summaryAsync,
    required this.onRetry,
  });

  final AsyncValue<DashboardSummary> summaryAsync;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return summaryAsync.when(
      loading: () => AppCard(
        elevation: 1.2,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: LoadingIndicator(
          message: AppLocalizations.of(context)!.preparingYourDashboard,
        ),
      ),
      error: (error, _) => ErrorView(
        title: AppLocalizations.of(context)!.dashboardUnavailable,
        message: UserFacingError.message(
          error,
          fallback: AppLocalizations.of(context)!.dashboardLoadFailed,
        ),
        onRetry: onRetry,
      ),
      data: (summary) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${greetingForNow()}, ${summary.userName}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textNavy,
                  fontWeight: FontWeight.w700,
                ),
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
              },
            )
          else
            AppEmptyState(
              icon: Icons.luggage_outlined,
              title: AppLocalizations.of(context)!.noUpcomingTrip,
              message: AppLocalizations.of(context)!.noUpcomingTripSubtitle,
            ),
        ],
      ),
    );
  }
}

class _HomeNavigationCard extends StatelessWidget {
  const _HomeNavigationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      elevation: 1.2,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          _HomeIconTile(icon: icon),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textNavy,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSubtle,
          ),
        ],
      ),
    );
  }
}

class _HomeIconTile extends StatelessWidget {
  const _HomeIconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.navy50,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(
        icon,
        color: AppColors.navy,
      ),
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
      elevation: 1.2,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Trip',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.champagne700,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            trip.destination,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textNavy,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            dateLine,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.icon(
                onPressed: onOpenLiveTrip,
                icon: const Icon(Icons.explore_outlined),
                label: Text(AppLocalizations.of(context)!.liveTrip),
              ),
              OutlinedButton.icon(
                onPressed: onOpenTrip,
                icon: const Icon(Icons.dashboard_outlined),
                label: Text(AppLocalizations.of(context)!.dashboard),
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
      elevation: 1.2,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textNavy,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          walletAsync.when(
            loading: () => Text(
              'Loading balances...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            error: (_, __) => Text(
              'Sign in to view wallet balances.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            data: (wallet) {
              final balances = wallet.balances;
              if (balances.isEmpty) {
                return Text(
                  'No balances yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                );
              }

              final sortedKeys = balances.keys.toList()..sort();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: sortedKeys
                    .take(3)
                    .map(
                      (currency) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          '$currency ${balances[currency]!.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppColors.textNavy,
                                    fontWeight: FontWeight.w700,
                                  ),
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
      avatar: Icon(icon, size: 18, color: AppColors.navy),
      label: Text(
        label,
        style: AppTextStyles.label.copyWith(color: AppColors.textNavy),
      ),
      backgroundColor: AppColors.warmWhite,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      elevation: 0,
      pressElevation: 0,
      shadowColor: AppShadows.shadowColor.withValues(alpha: 0.08),
      onPressed: onTap,
    );
  }
}
