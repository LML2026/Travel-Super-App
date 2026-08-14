import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.travelSmarter,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.homeDescription,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.whereNext,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      l10n.startNewTrip,
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                l10n.explore,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.25,
                children: [
                  _FeatureTile(
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
                  _FeatureTile(
                    icon: Icons.flight_outlined,
                    title: l10n.flights,
                    subtitle: l10n.searchAndManage,
                  ),
                  _FeatureTile(
                    icon: Icons.hotel_outlined,
                    title: l10n.hotels,
                    subtitle: l10n.findYourStay,
                  ),
                  _FeatureTile(
                    icon: Icons.translate,
                    title: l10n.translator,
                    subtitle: l10n.speakAnywhere,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TravelTranslatorScreen(),
                        ),
                      );
                    },
                  ),
                  _FeatureTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: l10n.wallet,
                    subtitle: l10n.moneyAndPayments,
                  ),
                  _FeatureTile(
                    icon: Icons.auto_awesome_outlined,
                    title: l10n.aiAssistant,
                    subtitle: l10n.yourTravelCopilot,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 34,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
