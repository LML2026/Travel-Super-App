import 'package:flutter/material.dart';
import '../../../core/auth/auth_service_scope.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/translation/backend_translation_service.dart';
import '../../../core/translation/translation_service.dart';
import '../../../core/widgets/app_feature_tile.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../l10n/app_localizations.dart';
import '../../translator/screens/travel_translator_screen.dart';
import '../../trips/screens/trips_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ITAREVO',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        actions: [
          _AccountMenu(),
          PopupMenuButton<Locale>(
            tooltip: l10n.language,
            icon: const Icon(Icons.language),
            onSelected: (locale) {
              AppLocaleScope.of(context).select(locale);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: const Locale('en'),
                child: Text(l10n.english),
              ),
              PopupMenuItem(
                value: const Locale('it'),
                child: Text(l10n.italian),
              ),
              PopupMenuItem(
                value: const Locale('es'),
                child: Text(l10n.spanish),
              ),
              PopupMenuItem(
                value: const Locale('fr'),
                child: Text(l10n.french),
              ),
              PopupMenuItem(
                value: const Locale('de'),
                child: Text(l10n.german),
              ),
              PopupMenuItem(
                value: const Locale('ru'),
                child: Text(l10n.russian),
              ),
              PopupMenuItem(
                value: Locale('zh', 'CN'),
                child: Text(l10n.chineseSimplified),
              ),
              PopupMenuItem(
                value: const Locale('ja'),
                child: Text(l10n.japanese),
              ),
              PopupMenuItem(
                value: const Locale('ko'),
                child: Text(l10n.korean),
              ),
              PopupMenuItem(value: Locale('pt'), child: Text(l10n.portuguese)),
              PopupMenuItem(
                value: const Locale('ar'),
                child: Text(l10n.arabic),
              ),
              PopupMenuItem(
                value: const Locale('tr'),
                child: Text(l10n.turkish),
              ),
              PopupMenuItem(
                value: const Locale('pl'),
                child: Text(l10n.polish),
              ),
              PopupMenuItem(value: Locale('nl'), child: Text(l10n.dutch)),
              PopupMenuItem(value: const Locale('hi'), child: Text(l10n.hindi)),
              PopupMenuItem(
                value: const Locale('ka'),
                child: Text(l10n.georgian),
              ),
              PopupMenuItem(
                value: const Locale('fa'),
                child: Text(l10n.persian),
              ),
              PopupMenuItem(
                value: const Locale('hy'),
                child: Text(l10n.armenian),
              ),
              PopupMenuItem(
                value: const Locale('uk'),
                child: Text(l10n.ukrainian),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.travelSmarter,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.homeDescription,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 184),
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: AppRadii.largeBorder.borderRadius,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.whereNext,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                l10n.startNewTrip,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withAlpha(220),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(24),
                            borderRadius: AppRadii.largeBorder.borderRadius,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            child: Icon(
                              Icons.explore_outlined,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppSectionHeader(title: l10n.explore),
                  const SizedBox(height: AppSpacing.md),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 900
                          ? 3
                          : constraints.maxWidth >= 560
                          ? 2
                          : 1;
                      final ratio = columns == 1 ? 2.35 : 1.25;

                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: ratio,
                        children: [
                          AppFeatureTile(
                            icon: Icons.map_outlined,
                            title: l10n.trips,
                            subtitle: l10n.planYourJourney,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const TripsListScreen(),
                                ),
                              );
                            },
                          ),
                          AppFeatureTile(
                            icon: Icons.flight_outlined,
                            title: l10n.flights,
                            subtitle: l10n.searchAndManage,
                            available: false,
                          ),
                          AppFeatureTile(
                            icon: Icons.hotel_outlined,
                            title: l10n.hotels,
                            subtitle: l10n.findYourStay,
                            available: false,
                          ),
                          AppFeatureTile(
                            icon: Icons.translate,
                            title: l10n.translator,
                            subtitle: l10n.speakAnywhere,
                            onTap: () {
                              final authService = AuthServiceScope.of(context);
                              final service =
                                  BackendTranslationService.configuredBaseUrl
                                      .trim()
                                      .isEmpty
                                  ? const UnavailableTranslationService()
                                  : BackendTranslationService(
                                      authService: authService,
                                    );
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TravelTranslatorScreen(service: service),
                                ),
                              );
                            },
                          ),
                          AppFeatureTile(
                            icon: Icons.account_balance_wallet_outlined,
                            title: l10n.wallet,
                            subtitle: l10n.moneyAndPayments,
                            available: false,
                          ),
                          AppFeatureTile(
                            icon: Icons.auto_awesome_outlined,
                            title: l10n.aiAssistant,
                            subtitle: l10n.yourTravelCopilot,
                            available: false,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountMenu extends StatelessWidget {
  const _AccountMenu();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final service = AuthServiceScope.of(context);
    final email = service.currentUser?.email ?? l10n.account;

    return PopupMenuButton<String>(
      tooltip: l10n.account,
      icon: const Icon(Icons.account_circle_outlined),
      onSelected: (value) async {
        if (value != 'signOut') return;
        try {
          await service.signOut();
        } on Object {
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.authSignOutFailed)));
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          value: 'email',
          child: Text(email),
        ),
        PopupMenuItem<String>(value: 'signOut', child: Text(l10n.signOut)),
      ],
    );
  }
}
