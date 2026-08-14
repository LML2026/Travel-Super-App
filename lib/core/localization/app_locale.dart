import 'package:flutter/material.dart';

import 'locale_preferences.dart';

class AppLocaleController extends ChangeNotifier {
  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('ru'),
    Locale('zh', 'CN'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ar'),
    Locale('tr'),
    Locale('pl'),
    Locale('nl'),
    Locale('hi'),
    Locale('ka'),
    Locale('fa'),
    Locale('hy'),
    Locale('uk'),
  ];

  static const fallbackLocale = Locale('en');

  Locale? _locale;

  Locale? get locale => _locale;

  static Future<AppLocaleController> load() async {
    final controller = AppLocaleController();
    final storedLanguage = await LocalePreferences.loadLanguageCode();
    controller._locale = localeForLanguageCode(storedLanguage);
    return controller;
  }

  static Locale? localeForLanguageCode(String? languageCode) {
    if (languageCode == null) return null;

    for (final locale in supportedLocales) {
      if (localeKey(locale) == languageCode) return locale;
    }

    // Preserve the original six language-code preference format.
    for (final locale in supportedLocales) {
      if (locale.countryCode == null && locale.languageCode == languageCode) {
        return locale;
      }
    }

    return null;
  }

  static Locale resolve(Locale? deviceLocale) {
    if (deviceLocale != null) {
      if (deviceLocale.languageCode == 'zh') {
        if (deviceLocale.countryCode == null ||
            deviceLocale.countryCode == 'CN') {
          return const Locale('zh', 'CN');
        }
        return fallbackLocale;
      }

      final match = localeForLanguageCode(deviceLocale.languageCode);
      if (match != null) return match;
    }

    return fallbackLocale;
  }

  Future<void> select(Locale locale) {
    final supported = localeForLanguageCode(localeKey(locale));
    if (supported == null) return Future<void>.value();

    _locale = supported;
    final selection = ++_selectionVersion;
    notifyListeners();
    _persistenceQueue = _persistenceQueue.then((_) async {
      if (selection != _selectionVersion) return;

      await LocalePreferences.saveLanguageCode(localeKey(supported));
    });

    return _persistenceQueue;
  }

  int _selectionVersion = 0;
  Future<void> _persistenceQueue = Future<void>.value();

  static String localeKey(Locale locale) => locale.countryCode == null
      ? locale.languageCode
      : '${locale.languageCode}_${locale.countryCode}';
}

class AppLocaleScope extends InheritedNotifier<AppLocaleController> {
  const AppLocaleScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppLocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'AppLocaleScope is missing from the widget tree.');
    return scope!.notifier!;
  }
}
