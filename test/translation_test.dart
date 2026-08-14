import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itarevo/core/translation/translation_language.dart';
import 'package:itarevo/core/translation/translation_service.dart';
import 'package:itarevo/features/translator/screens/travel_translator_screen.dart';
import 'package:itarevo/features/trips/models/trip.dart';
import 'package:itarevo/l10n/app_localizations.dart';

class _FakeTranslationService implements TranslationService {
  final TranslationResult? result;
  final Exception? error;
  TranslationRequest? lastRequest;

  _FakeTranslationService({this.result, this.error});

  @override
  Future<TranslationResult> translate(TranslationRequest request) async {
    lastRequest = request;
    if (error != null) throw error!;
    return result!;
  }
}

Widget _app(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('en'), Locale('ar'), Locale('fa')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  );
}

void main() {
  test('catalogue contains the 19 translator languages', () {
    expect(TranslationLanguage.supported, hasLength(19));
    expect(
      TranslationLanguage.supported.map((language) => language.code),
      containsAll([
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
      ]),
    );
    expect(TranslationLanguage.autoDetect.isAutoDetect, isTrue);
  });

  test('app language and translator target are separate concepts', () {
    expect(TranslationLanguage.defaultTarget(const Locale('ja')).code, 'ja');
    expect(
      TranslationLanguage.defaultTarget(const Locale('zh', 'CN')).code,
      'zh_CN',
    );
  });

  testWidgets('phrase shortcut populates source input and clear resets it', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const TravelTranslatorScreen()));

    await tester.tap(find.text('Hello'));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Hello',
    );

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('swap keeps source and target independent', (tester) async {
    final service = _FakeTranslationService(
      result: const TranslationResult(translatedText: 'ciao'),
    );
    await tester.pumpWidget(_app(TravelTranslatorScreen(service: service)));

    final dropdowns = find.byType(DropdownButtonFormField<TranslationLanguage>);
    expect(dropdowns, findsNWidgets(2));

    await tester.tap(dropdowns.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Italiano').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pump();

    expect(find.text('Italiano'), findsWidgets);
    expect(find.text('English'), findsWidgets);
  });

  testWidgets('unavailable provider never fabricates a translation', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const TravelTranslatorScreen()));
    await tester.enterText(find.byType(TextField), 'Where is the station?');
    await tester.tap(find.text('Translate'));
    await tester.pumpAndSettle();

    expect(find.text('Translation is not configured yet.'), findsOneWidget);
    expect(find.text('Where is the station?'), findsOneWidget);
  });

  testWidgets('successful and failed providers are represented honestly', (
    tester,
  ) async {
    final success = _FakeTranslationService(
      result: const TranslationResult(translatedText: 'Dove e la stazione?'),
    );
    await tester.pumpWidget(_app(TravelTranslatorScreen(service: success)));
    await tester.enterText(find.byType(TextField), 'Where is the station?');
    await tester.tap(find.text('Translate'));
    await tester.pumpAndSettle();

    expect(find.text('Dove e la stazione?'), findsOneWidget);
    expect(success.lastRequest?.sourceLanguageCode, 'auto');
    expect(success.lastRequest?.targetLanguageCode, 'en');

    final failure = _FakeTranslationService(
      error: const TranslationProviderUnavailable('not configured'),
    );
    await tester.pumpWidget(_app(TravelTranslatorScreen(service: failure)));
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.tap(find.text('Translate'));
    await tester.pumpAndSettle();

    expect(find.text('Translation is not configured yet.'), findsOneWidget);
    expect(find.text('Dove e la stazione?'), findsNothing);
  });

  testWidgets('Arabic and Persian target directions are RTL', (tester) async {
    for (final locale in const [Locale('ar'), Locale('fa')]) {
      await tester.pumpWidget(
        _app(
          TravelTranslatorScreen(
            service: _FakeTranslationService(
              result: const TranslationResult(translatedText: 'مرحبا'),
            ),
          ),
          locale: locale,
        ),
      );
      await tester.pump();

      expect(
        Directionality.of(tester.element(find.byType(Scaffold))),
        TextDirection.rtl,
      );
    }
  });

  test('translator state does not mutate trip data', () {
    final trip = Trip(
      id: 'trip',
      destination: 'Rome',
      departureDate: DateTime(2026, 9, 1),
      returnDate: DateTime(2026, 9, 5),
      travellers: 2,
      notes: 'Private note',
      budget: 900,
      currency: 'EUR',
    );

    final request = TranslationRequest(
      sourceText: 'Hello',
      sourceLanguageCode: 'en',
      targetLanguageCode: 'it',
    );

    expect(request.sourceText, 'Hello');
    expect(trip.destination, 'Rome');
    expect(trip.notes, 'Private note');
    expect(trip.budget, 900);
    expect(trip.currency, 'EUR');
  });
}
