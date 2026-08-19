import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/translator/data/translation_history_repository.dart';
import 'package:travel_super_app/features/translator/data/translation_service.dart';
import 'package:travel_super_app/features/translator/domain/translation_models.dart';
import 'package:travel_super_app/features/translator/presentation/providers/translator_provider.dart';

void main() {
  group('DemoTranslationService', () {
    test('translates known travel phrases deterministically', () async {
      final response = await const DemoTranslationService().translate(
        const TranslationRequest(
          text: 'I have a reservation.',
          sourceLanguageCode: 'en',
          targetLanguageCode: 'fr',
        ),
      );

      expect(response.translatedText, 'J ai une reservation.');
      expect(response.isDemo, isTrue);
    });

    test('auto-detects common source language markers', () async {
      final response = await const DemoTranslationService().translate(
        const TranslationRequest(
          text: 'Bonjour merci',
          sourceLanguageCode: 'auto',
          targetLanguageCode: 'en',
          autoDetect: true,
        ),
      );

      expect(response.detectedLanguageCode, 'fr');
      expect(response.sourceLanguageCode, 'fr');
    });
  });

  group('TranslatorController', () {
    test('applies trip destination context and suggests known language',
        () async {
      final repository = MemoryTranslationHistoryRepository();
      final container = _container(repository);
      addTearDown(container.dispose);

      await container.read(translatorControllerProvider.future);
      await container.read(translatorControllerProvider.notifier).applyContext(
            const TranslatorContext(
              destination: 'Rome, Italy',
              contextLabel: 'Hotel check-in',
              initialText: 'I have a reservation.',
            ),
          );

      final state = container.read(translatorControllerProvider).requireValue;
      expect(state.targetLanguageCode, 'it');
      expect(state.localLanguageCode, 'it');
      expect(state.inputText, 'I have a reservation.');
      expect(state.context?.contextLabel, 'Hotel check-in');
    });

    test('translates text and persists recent history and favourites',
        () async {
      final repository = MemoryTranslationHistoryRepository();
      final container = _container(repository);
      addTearDown(container.dispose);

      await container.read(translatorControllerProvider.future);
      final controller = container.read(translatorControllerProvider.notifier);
      controller.setInputText('A table for two, please.');
      controller.setTargetLanguage('es');

      final response = await controller.translate();
      await controller.favouriteLatest();

      final state = container.read(translatorControllerProvider).requireValue;
      final persisted = await repository.load();

      expect(response?.translatedText, 'Una mesa para dos, por favor.');
      expect(state.history, hasLength(1));
      expect(state.favourites.single.sourceText, 'A table for two, please.');
      expect(persisted.single.isFavourite, isTrue);
    });

    test('adds alternating conversation turns', () async {
      final repository = MemoryTranslationHistoryRepository();
      final container = _container(repository);
      addTearDown(container.dispose);

      await container.read(translatorControllerProvider.future);
      final controller = container.read(translatorControllerProvider.notifier);
      controller.setLocalLanguage('fr');

      await controller.addConversationTurn(
        text: 'Hello, can you help me?',
        travellerSpeaking: true,
      );

      final state = container.read(translatorControllerProvider).requireValue;
      expect(state.conversation, hasLength(1));
      expect(state.conversation.single.speakerLabel, 'Traveller');
      expect(
        state.conversation.single.translatedText,
        'Bonjour, pouvez-vous m aider ?',
      );
    });
  });
}

ProviderContainer _container(TranslationHistoryRepository repository) {
  return ProviderContainer(
    overrides: [
      translationServiceProvider.overrideWithValue(
        const DemoTranslationService(),
      ),
      translationHistoryRepositoryProvider.overrideWithValue(repository),
    ],
  );
}
