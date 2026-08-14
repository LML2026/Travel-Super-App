import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:itarevo/core/localization/app_locale.dart';
import 'package:itarevo/core/localization/locale_preferences.dart';
import 'package:itarevo/features/trips/models/trip.dart';
import 'package:itarevo/l10n/app_localizations.dart';
import 'package:itarevo/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('supports exactly 19 Phase 1 application languages', () {
    expect(
      AppLocaleController.supportedLocales.map(AppLocaleController.localeKey),
      [
        'en',
        'it',
        'es',
        'fr',
        'de',
        'ru',
        'zh_CN',
        'ja',
        'ko',
        'pt',
        'ar',
        'tr',
        'pl',
        'nl',
        'hi',
        'ka',
        'fa',
        'hy',
        'uk',
      ],
    );
  });

  test(
    'generated localization resources load for every supported locale',
    () async {
      for (final locale in AppLocaleController.supportedLocales) {
        final localization = await AppLocalizations.delegate.load(locale);

        expect(localization.travel, isNotEmpty);
        expect(localization.language, isNotEmpty);
      }
    },
  );

  test('unsupported device locales fall back to English', () {
    expect(AppLocaleController.resolve(const Locale('xx')), const Locale('en'));
    expect(AppLocaleController.resolve(null), const Locale('en'));
    expect(
      AppLocaleController.resolve(const Locale('fr', 'CA')),
      const Locale('fr'),
    );
    expect(
      AppLocaleController.resolve(const Locale('zh', 'CN')),
      const Locale('zh', 'CN'),
    );
    expect(
      AppLocaleController.resolve(const Locale('zh')),
      const Locale('zh', 'CN'),
    );
    expect(
      AppLocaleController.resolve(const Locale('zh', 'TW')),
      const Locale('en'),
    );
    expect(AppLocaleController.resolve(const Locale('ka')), const Locale('ka'));
    expect(AppLocaleController.resolve(const Locale('ar')), const Locale('ar'));
    expect(AppLocaleController.resolve(const Locale('fa')), const Locale('fa'));
    expect(AppLocaleController.resolve(const Locale('hy')), const Locale('hy'));
    expect(AppLocaleController.resolve(const Locale('uk')), const Locale('uk'));
  });

  test('every explicit language selection persists and restores', () async {
    final controller = AppLocaleController();

    for (final locale in AppLocaleController.supportedLocales) {
      await controller.select(locale);

      expect(
        await LocalePreferences.loadLanguageCode(),
        AppLocaleController.localeKey(locale),
      );
      final restored = await AppLocaleController.load();
      expect(restored.locale, locale);
    }
  });

  test('existing six-language preferences remain compatible', () async {
    for (final languageCode in ['en', 'it', 'es', 'fr', 'de', 'ru']) {
      SharedPreferences.setMockInitialValues({
        LocalePreferences.key: languageCode,
      });

      final restored = await AppLocaleController.load();

      expect(restored.locale, Locale(languageCode));
    }
  });

  test(
    'Persian, Armenian, and Ukrainian preferences restore correctly',
    () async {
      for (final locale in const [Locale('fa'), Locale('hy'), Locale('uk')]) {
        final controller = AppLocaleController();

        await controller.select(locale);

        final restored = await AppLocaleController.load();
        expect(restored.locale, locale);
      }
    },
  );

  test('invalid stored language is ignored safely', () async {
    SharedPreferences.setMockInitialValues({
      LocalePreferences.key: 'unsupported',
    });

    final restored = await AppLocaleController.load();

    expect(restored.locale, isNull);
    expect(AppLocaleController.resolve(restored.locale), const Locale('en'));
  });

  test('changing language does not mutate trip data or currency', () async {
    final controller = AppLocaleController();
    final trip = Trip(
      id: 'trip',
      destination: 'Rome',
      departureDate: DateTime(2026, 9, 1),
      returnDate: DateTime(2026, 9, 5),
      travellers: 2,
      notes: 'Keep this note',
      budget: 1250,
      currency: 'GBP',
    );

    await controller.select(const Locale('ar'));

    expect(trip.destination, 'Rome');
    expect(trip.notes, 'Keep this note');
    expect(trip.budget, 1250);
    expect(trip.currency, 'GBP');
  });

  test('rapid repeated switching persists the latest selection', () async {
    final controller = AppLocaleController();
    const sequence = [
      Locale('ar'),
      Locale('en'),
      Locale('fa'),
      Locale('ka'),
      Locale('uk'),
      Locale('zh', 'CN'),
      Locale('hy'),
      Locale('it'),
    ];

    for (var cycle = 0; cycle < 3; cycle++) {
      final pending = [
        for (final locale in sequence) controller.select(locale),
      ];

      expect(controller.locale, const Locale('it'));
      await Future.wait(pending);
      expect(
        await LocalePreferences.loadLanguageCode(),
        AppLocaleController.localeKey(const Locale('it')),
      );
    }

    final restored = await AppLocaleController.load();
    expect(restored.locale, const Locale('it'));
  });

  testWidgets('Arabic uses right-to-left directionality', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => Text(
            AppLocalizations.of(context).travel,
            textDirection: Directionality.of(context),
          ),
        ),
      ),
    );

    expect(
      Directionality.of(tester.element(find.byType(Text))),
      TextDirection.rtl,
    );
    expect(find.text('السفر'), findsOneWidget);
  });

  testWidgets('Persian uses right-to-left directionality', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fa'),
        supportedLocales: const [Locale('fa')],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => Text(
            AppLocalizations.of(context).travel,
            textDirection: Directionality.of(context),
          ),
        ),
      ),
    );

    expect(
      Directionality.of(tester.element(find.byType(Text))),
      TextDirection.rtl,
    );
    expect(find.text('سفر'), findsOneWidget);
  });

  testWidgets('MaterialApp updates through repeated locale changes', (
    tester,
  ) async {
    final controller = AppLocaleController();

    await tester.pumpWidget(ItarevoApp(controller: controller));

    for (final locale in const [
      Locale('en'),
      Locale('it'),
      Locale('ru'),
      Locale('ka'),
      Locale('zh', 'CN'),
      Locale('ar'),
      Locale('fa'),
      Locale('uk'),
      Locale('hy'),
      Locale('it'),
    ]) {
      await controller.select(locale);
      await tester.pumpAndSettle();

      expect(controller.locale, locale);
      expect(
        Directionality.of(tester.element(find.byType(NavigationBar))),
        locale.languageCode == 'ar' || locale.languageCode == 'fa'
            ? TextDirection.rtl
            : TextDirection.ltr,
      );
    }

    expect(find.text('Viaggi'), findsWidgets);
  });
}
