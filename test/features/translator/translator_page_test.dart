import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/translator/data/translation_history_repository.dart';
import 'package:travel_super_app/features/translator/data/translation_service.dart';
import 'package:travel_super_app/features/translator/domain/translation_models.dart';
import 'package:travel_super_app/features/translator/presentation/providers/translator_provider.dart';
import 'package:travel_super_app/features/translator/presentation/screens/translator_page.dart';
import 'package:travel_super_app/l10n/app_localizations.dart';

void main() {
  testWidgets('Translate tab shows live translation status for backend results',
      (tester) async {
    await tester.pumpWidget(
      _app(translationService: const _StaticTranslationService(live: true)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'Hello, can you help me?',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Translate'));
    await tester.pumpAndSettle();

    expect(find.text('Live translation'), findsOneWidget);
    expect(find.text('Demo fallback'), findsNothing);
  });

  testWidgets('Phrasebook path keeps demo fallback status visible',
      (tester) async {
    await tester.pumpWidget(
      _app(translationService: const DemoTranslationService()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Phrasebook'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('I have a reservation.').first);
    await tester.pumpAndSettle();

    expect(find.text('Latest phrase translation'), findsOneWidget);
    expect(find.text('Demo fallback'), findsOneWidget);
  });
}

Widget _app({required TranslationService translationService}) {
  return ProviderScope(
    overrides: [
      translationServiceProvider.overrideWithValue(translationService),
      translationHistoryRepositoryProvider.overrideWithValue(
        MemoryTranslationHistoryRepository(),
      ),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: TranslatorPage(),
    ),
  );
}

class _StaticTranslationService implements TranslationService {
  const _StaticTranslationService({required this.live});

  final bool live;

  @override
  Future<TranslationResponse> translate(TranslationRequest request) async {
    return TranslationResponse(
      originalText: request.text,
      translatedText: live ? 'Bonjour' : 'Demo translation: ${request.text}',
      sourceLanguageCode: request.sourceLanguageCode,
      targetLanguageCode: request.targetLanguageCode,
      isDemo: !live,
      source: live ? TranslationSource.backend : TranslationSource.demo,
    );
  }
}
