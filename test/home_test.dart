import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itarevo/core/auth/auth_service.dart';
import 'package:itarevo/core/auth/auth_service_scope.dart';
import 'package:itarevo/core/auth/auth_state.dart';
import 'package:itarevo/core/auth/auth_user.dart';
import 'package:itarevo/core/localization/app_locale.dart';
import 'package:itarevo/core/widgets/app_feature_tile.dart';
import 'package:itarevo/features/home/screens/home_screen.dart';
import 'package:itarevo/l10n/app_localizations.dart';

class _FakeAuthService implements AuthService {
  const _FakeAuthService();

  @override
  AuthUser? get currentUser =>
      const AuthUser(uid: 'home-test-user', email: 'home@example.com');

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();

  @override
  Future<AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<AuthUser> createAccount({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> signOut() async {}

  @override
  Future<String?> getIdToken() async => null;
}

Widget _home({Locale locale = const Locale('en')}) {
  final controller = AppLocaleController();
  return AppLocaleScope(
    notifier: controller,
    child: AuthServiceScope(
      service: const _FakeAuthService(),
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocaleController.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const HomeScreen(),
      ),
    ),
  );
}

void main() {
  testWidgets('Home renders functional and unavailable feature hierarchy', (
    tester,
  ) async {
    await tester.pumpWidget(_home());

    expect(find.text('Travel smarter.'), findsOneWidget);
    expect(find.text('Trips'), findsOneWidget);
    expect(find.text('Translator'), findsOneWidget);
    expect(find.byType(AppFeatureTile), findsNWidgets(6));
    expect(find.byIcon(Icons.lock_outline), findsNWidgets(4));
  });

  testWidgets('enabled feature tiles expose tap callbacks', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppFeatureTile(
            icon: Icons.map_outlined,
            title: 'Trips',
            subtitle: 'Plan your journey',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Trips'));
    expect(tapped, isTrue);
  });

  testWidgets('Home adapts to narrow and wide layouts', (tester) async {
    for (final size in const [Size(360, 800), Size(1280, 900)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(_home());
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    }
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Home builds in Arabic RTL with long localized content', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(_home(locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(
      Directionality.of(tester.element(find.byType(HomeScreen))),
      TextDirection.rtl,
    );
    expect(find.text('سافر بذكاء أكبر.'), findsOneWidget);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('unavailable feature tiles do not expose tap callbacks', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppFeatureTile(
            icon: Icons.hotel_outlined,
            title: 'Hotels',
            subtitle: 'Coming later',
            available: false,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Hotels'));
    expect(tapped, isFalse);
  });
}
