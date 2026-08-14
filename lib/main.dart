import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/auth/auth_service.dart';
import 'core/auth/firebase_auth_service.dart';
import 'core/maps_config.dart';
import 'core/maps_loader.dart';
import 'core/localization/app_locale.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/widgets/auth_gate.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'shells/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadGoogleMaps(MapsConfig.apiKey);
  final authService = await _createAuthService();
  final localeController = await AppLocaleController.load();
  runApp(ItarevoApp(controller: localeController, authService: authService));
}

Future<AuthService> _createAuthService() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return FirebaseAuthService();
  } catch (_) {
    return const UnavailableAuthService();
  }
}

class ItarevoApp extends StatefulWidget {
  final AppLocaleController? controller;
  final AuthService? authService;

  const ItarevoApp({super.key, this.controller, this.authService});

  @override
  State<ItarevoApp> createState() => _ItarevoAppState();
}

class _ItarevoAppState extends State<ItarevoApp> {
  late final AppLocaleController _localeController;
  late final AuthService _authService;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _localeController = widget.controller ?? AppLocaleController();
    _authService = widget.authService ?? const UnavailableAuthService();
    _localeController.addListener(_handleLocaleChanged);
  }

  void _handleLocaleChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _localeController.removeListener(_handleLocaleChanged);
    if (_ownsController) _localeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLocaleScope(
      notifier: _localeController,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ITAREVO',
        theme: AppTheme.lightTheme,
        locale: _localeController.locale,
        supportedLocales: AppLocaleController.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        localeResolutionCallback: (locale, supportedLocales) =>
            AppLocaleController.resolve(locale),
        home: AuthGate(
          service: _authService,
          authenticatedChild: const AppShell(),
        ),
      ),
    );
  }
}
