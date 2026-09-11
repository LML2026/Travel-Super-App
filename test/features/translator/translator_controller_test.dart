import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/translator/data/translation_history_repository.dart';
import 'package:travel_super_app/features/translator/data/speech_service.dart';
import 'package:travel_super_app/features/translator/data/translation_service.dart';
import 'package:travel_super_app/features/translator/domain/translation_models.dart';
import 'package:travel_super_app/features/translator/presentation/providers/translator_provider.dart';

void main() {
  group('BackendTranslationService', () {
    test('maps a backend response and marks it as live', () async {
      TranslationRequest? sentRequest;
      final service = BackendTranslationService(
        endpoint: 'https://translation.example.test/api/translate',
        sender: (request) async {
          sentRequest = request;
          return {
            'translatedText': 'Bonjour',
            'detectedLanguageCode': 'en',
          };
        },
      );

      final response = await service.translate(
        const TranslationRequest(
          text: 'Hello',
          sourceLanguageCode: 'auto',
          targetLanguageCode: 'fr',
          autoDetect: true,
        ),
      );

      expect(sentRequest?.autoDetect, isTrue);
      expect(response.translatedText, 'Bonjour');
      expect(response.source, TranslationSource.backend);
      expect(response.isDemo, isFalse);
      expect(response.sourceLanguageCode, 'en');
    });

    test('falls back to deterministic demo translation when backend fails',
        () async {
      final service = FallbackTranslationService(
        liveService: BackendTranslationService(
          endpoint: 'https://translation.example.test/api/translate',
          sender: (_) async => throw const TranslationProviderException(),
        ),
      );

      final response = await service.translate(
        const TranslationRequest(
          text: 'I have a reservation.',
          sourceLanguageCode: 'en',
          targetLanguageCode: 'fr',
        ),
      );

      expect(response.translatedText, 'J ai une reservation.');
      expect(response.source, TranslationSource.demo);
      expect(response.isDemo, isTrue);
    });
  });

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

    test('turns final speech input into a translated response', () async {
      final repository = MemoryTranslationHistoryRepository();
      final container = _container(
        repository,
        speechInput: _FakeSpeechInput(available: true),
      );
      addTearDown(container.dispose);

      await container.read(translatorControllerProvider.future);
      final controller = container.read(translatorControllerProvider.notifier);
      await controller.startListening();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(translatorControllerProvider).requireValue;
      expect(state.inputText, 'I have a reservation.');
      expect(state.lastResponse?.translatedText, 'J ai une reservation.');
      expect(state.isListening, isFalse);
    });

    test('keeps text mode usable when speech is unavailable', () async {
      final container = _container(
        MemoryTranslationHistoryRepository(),
        speechInput: _FakeSpeechInput(available: false),
      );
      addTearDown(container.dispose);

      await container.read(translatorControllerProvider.future);
      await container
          .read(translatorControllerProvider.notifier)
          .startListening();
      final state = container.read(translatorControllerProvider).requireValue;

      expect(state.speechAvailable, isFalse);
      expect(state.speechError, contains('unavailable'));
    });

    test('uses speech in conversation mode for the selected speaker', () async {
      final container = _container(
        MemoryTranslationHistoryRepository(),
        speechInput: _FakeSpeechInput(available: true),
      );
      addTearDown(container.dispose);

      await container.read(translatorControllerProvider.future);
      await container
          .read(translatorControllerProvider.notifier)
          .startListening(
            conversation: true,
            travellerSpeaking: true,
          );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(translatorControllerProvider).requireValue;
      expect(state.conversation.single.speakerLabel, 'Traveller');
      expect(state.conversation.single.sourceText, 'I have a reservation.');
      expect(state.isListening, isFalse);
    });

    test('does not expose provider errors in the text UI state', () async {
      final container = _container(
        MemoryTranslationHistoryRepository(),
        translationService: _ThrowingTranslationService(),
      );
      addTearDown(container.dispose);

      await container.read(translatorControllerProvider.future);
      final controller = container.read(translatorControllerProvider.notifier);
      controller.setInputText('Hello');
      await controller.translate();

      final state = container.read(translatorControllerProvider).requireValue;
      expect(state.errorMessage, isNot(contains('provider.internal')));
      expect(state.errorMessage, contains('temporarily unavailable'));
    });

    test('speaks and can stop the latest translation', () async {
      final output = _FakeSpeechOutput();
      final container = _container(
        MemoryTranslationHistoryRepository(),
        speechOutput: output,
      );
      addTearDown(container.dispose);

      await container.read(translatorControllerProvider.future);
      final controller = container.read(translatorControllerProvider.notifier);
      controller.setInputText('A table for two, please.');
      await controller.translate();
      await controller.speakTranslation();
      await controller.stopSpeaking();

      expect(output.spokenText, 'Une table pour deux, s il vous plait.');
      expect(output.stopped, isTrue);
      expect(
          container.read(translatorControllerProvider).requireValue.isSpeaking,
          isFalse);
    });
  });
}

ProviderContainer _container(
  TranslationHistoryRepository repository, {
  SpeechInputService? speechInput,
  SpeechOutputService? speechOutput,
  TranslationService? translationService,
}) {
  return ProviderContainer(
    overrides: [
      translationServiceProvider.overrideWithValue(
        translationService ?? const DemoTranslationService(),
      ),
      translationHistoryRepositoryProvider.overrideWithValue(repository),
      if (speechInput != null)
        speechInputServiceProvider.overrideWithValue(speechInput),
      if (speechOutput != null)
        speechOutputServiceProvider.overrideWithValue(speechOutput),
    ],
  );
}

class _FakeSpeechInput implements SpeechInputService {
  _FakeSpeechInput({required this.available});

  final bool available;

  @override
  Future<bool> initialize() async => available;

  @override
  Future<void> listen({
    required String localeId,
    required void Function(String text, bool isFinal) onResult,
  }) async {
    if (!available) throw StateError('unavailable');
    onResult('I have a', false);
    onResult('I have a reservation.', true);
  }

  @override
  Future<void> stop() async {}
}

class _FakeSpeechOutput implements SpeechOutputService {
  String? spokenText;
  bool stopped = false;

  @override
  Future<void> speak({required String text, required String localeId}) async {
    spokenText = text;
  }

  @override
  Future<void> stop() async {
    stopped = true;
  }
}

class _ThrowingTranslationService implements TranslationService {
  @override
  Future<TranslationResponse> translate(TranslationRequest request) {
    throw StateError('provider.internal details must stay private');
  }
}
