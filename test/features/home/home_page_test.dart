import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_super_app/app/app_routes.dart';
import 'package:travel_super_app/core/theme/app_theme.dart';
import 'package:travel_super_app/core/widgets/widgets.dart';
import 'package:travel_super_app/features/home/home_page.dart';
import 'package:travel_super_app/features/home/models/dashboard_summary.dart';
import 'package:travel_super_app/features/home/providers/dashboard_provider.dart';
import 'package:travel_super_app/features/wallet/domain/entities/wallet.dart';
import 'package:travel_super_app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:travel_super_app/l10n/app_localizations.dart';

void main() {
  testWidgets('Home exposes stable Build 3 shortcuts and Profile access',
      (tester) async {
    final router = _homeRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardSummaryProvider.overrideWith(
            (ref) async => const DashboardSummary(userName: 'Traveler'),
          ),
          walletProvider.overrideWith(
            (ref) => Stream.value(
              const Wallet(
                id: 'wallet-test',
                userId: 'user-test',
                baseCurrency: 'GBP',
                balances: {'GBP': 125.50},
              ),
            ),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ITAREVO'), findsOneWidget);
    expect(find.text('London'), findsNothing);
    expect(find.byTooltip('Profile'), findsOneWidget);
    expect(find.widgetWithText(AppCard, 'Profile'), findsOneWidget);
    expect(
      find.text('Account settings, sign out and delete account.'),
      findsOneWidget,
    );
    expect(find.text('No upcoming trip'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('My Bookings'), findsOneWidget);
    expect(find.text('Travel Discovery'), findsOneWidget);
    expect(find.text('Saved Items'), findsOneWidget);
    expect(find.text('Quick Booking'), findsOneWidget);
    expect(find.text('Taxi'), findsOneWidget);
    expect(find.text('Flights'), findsOneWidget);
    expect(find.text('Hotels'), findsOneWidget);
    expect(find.text('AI Assistant'), findsOneWidget);
    expect(find.text('Translator'), findsOneWidget);
  });

  testWidgets(
      'Home keeps feature access and Translator reachable when dashboard fails',
      (tester) async {
    var dashboardLoads = 0;
    var walletLoads = 0;
    final router = _homeRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardSummaryProvider.overrideWith((ref) async {
            dashboardLoads += 1;
            throw Exception(
                '[cloud_firestore/permission-denied] Missing or insufficient permissions.');
          }),
          walletProvider.overrideWith((ref) {
            walletLoads += 1;
            return Stream.value(
              const Wallet(
                id: 'wallet-test',
                userId: 'user-test',
                baseCurrency: 'GBP',
                balances: {'GBP': 125.50},
              ),
            );
          }),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ITAREVO'), findsOneWidget);
    expect(find.text('Dashboard unavailable'), findsOneWidget);
    expect(
      find.text('You do not have permission to access this information.'),
      findsOneWidget,
    );
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.widgetWithText(AppCard, 'Translator'), findsOneWidget);
    expect(find.widgetWithText(AppCard, 'Profile'), findsOneWidget);
    expect(find.text('Quick Booking'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(dashboardLoads, 2);
    expect(walletLoads, 1);

    await tester.ensureVisible(find.widgetWithText(AppCard, 'Translator'));
    await tester.tap(find.widgetWithText(AppCard, 'Translator'));
    await tester.pumpAndSettle();

    expect(find.text('Translator reached'), findsOneWidget);
  });
}

GoRouter _homeRouter() {
  return GoRouter(
    initialLocation: AppRoute.home.path,
    routes: [
      GoRoute(
        name: AppRoute.home.routeName,
        path: AppRoute.home.path,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        name: AppRoute.translator.routeName,
        path: AppRoute.translator.path,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Translator reached')),
        ),
      ),
    ],
  );
}
