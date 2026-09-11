import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/providers.dart';
import '../../data/translation_history_repository.dart';
import '../../data/speech_service.dart';
import '../../data/translation_service.dart';
import '../../domain/translation_models.dart';

final translationServiceProvider = Provider<TranslationService>((ref) {
  final endpoint = _translationEndpointFromEnvironment();
  return FallbackTranslationService(
    liveService:
        endpoint == null ? null : BackendTranslationService(endpoint: endpoint),
  );
});

final translationHistoryRepositoryProvider =
    Provider<TranslationHistoryRepository>((ref) {
  return LocalTranslationHistoryRepository(ref.watch(storageServiceProvider));
});

final speechInputServiceProvider = Provider<SpeechInputService>((ref) {
  return NativeSpeechInputService();
});

final speechOutputServiceProvider = Provider<SpeechOutputService>((ref) {
  return NativeSpeechOutputService();
});

final translatorControllerProvider =
    AsyncNotifierProvider<TranslatorController, TranslatorState>(
  TranslatorController.new,
);

String? _translationEndpointFromEnvironment() {
  final explicit = dotenv.maybeGet('TRANSLATION_API_URL')?.trim();
  if (explicit != null && _isHttpUrl(explicit)) {
    return explicit;
  }

  final baseUrl = dotenv.maybeGet('API_BASE_URL')?.trim();
  if (baseUrl == null || !_isHttpUrl(baseUrl)) {
    return null;
  }
  return '${baseUrl.replaceFirst(RegExp(r'/$'), '')}/api/translate';
}

bool _isHttpUrl(String value) {
  final uri = Uri.tryParse(value);
  return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
}

class TranslatorState {
  const TranslatorState({
    this.sourceLanguageCode = 'auto',
    this.targetLanguageCode = 'fr',
    this.travellerLanguageCode = 'en',
    this.localLanguageCode = 'fr',
    this.inputText = '',
    this.lastResponse,
    this.history = const [],
    this.conversation = const [],
    this.context,
    this.errorMessage,
    this.speechAvailable = false,
    this.isListening = false,
    this.isSpeaking = false,
    this.speechError,
  });

  final String sourceLanguageCode;
  final String targetLanguageCode;
  final String travellerLanguageCode;
  final String localLanguageCode;
  final String inputText;
  final TranslationResponse? lastResponse;
  final List<SavedTranslation> history;
  final List<ConversationTurn> conversation;
  final TranslatorContext? context;
  final String? errorMessage;
  final bool speechAvailable;
  final bool isListening;
  final bool isSpeaking;
  final String? speechError;

  List<SavedTranslation> get favourites =>
      history.where((item) => item.isFavourite).toList(growable: false);

  TranslatorState copyWith({
    String? sourceLanguageCode,
    String? targetLanguageCode,
    String? travellerLanguageCode,
    String? localLanguageCode,
    String? inputText,
    TranslationResponse? lastResponse,
    List<SavedTranslation>? history,
    List<ConversationTurn>? conversation,
    TranslatorContext? context,
    String? errorMessage,
    bool? speechAvailable,
    bool? isListening,
    bool? isSpeaking,
    String? speechError,
    bool clearResponse = false,
    bool clearError = false,
    bool clearSpeechError = false,
  }) {
    return TranslatorState(
      sourceLanguageCode: sourceLanguageCode ?? this.sourceLanguageCode,
      targetLanguageCode: targetLanguageCode ?? this.targetLanguageCode,
      travellerLanguageCode:
          travellerLanguageCode ?? this.travellerLanguageCode,
      localLanguageCode: localLanguageCode ?? this.localLanguageCode,
      inputText: inputText ?? this.inputText,
      lastResponse: clearResponse ? null : lastResponse ?? this.lastResponse,
      history: history ?? this.history,
      conversation: conversation ?? this.conversation,
      context: context ?? this.context,
      errorMessage: clearError ? null : errorMessage,
      speechAvailable: speechAvailable ?? this.speechAvailable,
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      speechError: clearSpeechError ? null : speechError ?? this.speechError,
    );
  }
}

class TranslatorController extends AsyncNotifier<TranslatorState> {
  @override
  FutureOr<TranslatorState> build() async {
    final history = await ref.read(translationHistoryRepositoryProvider).load();
    return TranslatorState(history: history);
  }

  Future<void> applyContext(TranslatorContext context) async {
    final current = state.valueOrNull ?? const TranslatorState();
    final suggestedLanguage =
        _suggestLanguageForDestination(context.destination);
    state = AsyncData(
      current.copyWith(
        context: context,
        inputText: context.initialText?.trim().isNotEmpty == true
            ? context.initialText!.trim()
            : current.inputText,
        targetLanguageCode: suggestedLanguage ?? current.targetLanguageCode,
        localLanguageCode: suggestedLanguage ?? current.localLanguageCode,
        clearError: true,
      ),
    );
  }

  Future<bool> initializeSpeech() async {
    final current = state.valueOrNull ?? const TranslatorState();
    try {
      final available = await ref.read(speechInputServiceProvider).initialize();
      state = AsyncData(
        current.copyWith(
          speechAvailable: available,
          speechError:
              available ? null : 'Speech input is unavailable on this device.',
          clearSpeechError: available,
        ),
      );
      return available;
    } catch (_) {
      state = AsyncData(
        current.copyWith(
          speechAvailable: false,
          speechError: 'Speech input is unavailable on this device.',
        ),
      );
      return false;
    }
  }

  Future<void> startListening({
    String? languageCode,
    bool conversation = false,
    bool travellerSpeaking = true,
  }) async {
    final current = state.valueOrNull ?? const TranslatorState();
    final available = current.speechAvailable || await initializeSpeech();
    if (!available) return;
    final selectedLanguage = languageCode ??
        (conversation
            ? (travellerSpeaking
                ? current.travellerLanguageCode
                : current.localLanguageCode)
            : current.sourceLanguageCode);
    state =
        AsyncData(current.copyWith(isListening: true, clearSpeechError: true));
    try {
      await ref.read(speechInputServiceProvider).listen(
            localeId: speechLocaleFor(selectedLanguage),
            onResult: (text, isFinal) {
              if (conversation) {
                if (isFinal && text.trim().isNotEmpty) {
                  unawaited(_finishConversationSpeech(
                    text: text,
                    travellerSpeaking: travellerSpeaking,
                  ));
                }
              } else {
                setInputText(text);
                if (isFinal && text.trim().isNotEmpty) {
                  unawaited(_finishSourceSpeech(text));
                }
              }
            },
          );
    } catch (_) {
      final latest = state.valueOrNull ?? current;
      state = AsyncData(latest.copyWith(
        isListening: false,
        speechError:
            'Could not start speech input. You can still type your translation.',
      ));
    }
  }

  Future<void> stopListening() async {
    try {
      await ref.read(speechInputServiceProvider).stop();
    } catch (_) {
      // Native recognition may have already ended.
    }
    final current = state.valueOrNull ?? const TranslatorState();
    state = AsyncData(current.copyWith(isListening: false));
  }

  Future<void> _finishSourceSpeech(String text) async {
    await translate(text);
    final current = state.valueOrNull ?? const TranslatorState();
    state = AsyncData(current.copyWith(isListening: false));
  }

  Future<void> _finishConversationSpeech({
    required String text,
    required bool travellerSpeaking,
  }) async {
    await addConversationTurn(
      text: text,
      travellerSpeaking: travellerSpeaking,
    );
    final current = state.valueOrNull ?? const TranslatorState();
    state = AsyncData(current.copyWith(isListening: false));
  }

  Future<void> speakTranslation({String? text, String? languageCode}) async {
    final current = state.valueOrNull ?? const TranslatorState();
    final spokenText = (text ?? current.lastResponse?.translatedText)?.trim();
    if (spokenText == null || spokenText.isEmpty) return;
    state =
        AsyncData(current.copyWith(isSpeaking: true, clearSpeechError: true));
    try {
      await ref.read(speechOutputServiceProvider).speak(
            text: spokenText,
            localeId: speechLocaleFor(
              languageCode ??
                  current.lastResponse?.targetLanguageCode ??
                  current.targetLanguageCode,
            ),
          );
    } catch (_) {
      state = AsyncData((state.valueOrNull ?? current).copyWith(
        speechError: 'This device does not support that spoken language.',
      ));
    } finally {
      state =
          AsyncData((state.valueOrNull ?? current).copyWith(isSpeaking: false));
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await ref.read(speechOutputServiceProvider).stop();
    } catch (_) {
      // Stop is best effort across native voice engines.
    }
    final current = state.valueOrNull ?? const TranslatorState();
    state = AsyncData(current.copyWith(isSpeaking: false));
  }

  Future<void> replayTranslation() => speakTranslation();

  void setInputText(String value) {
    final current = state.valueOrNull ?? const TranslatorState();
    state = AsyncData(current.copyWith(inputText: value, clearError: true));
  }

  void setSourceLanguage(String code) {
    final current = state.valueOrNull ?? const TranslatorState();
    state = AsyncData(current.copyWith(sourceLanguageCode: code));
  }

  void setTargetLanguage(String code) {
    final current = state.valueOrNull ?? const TranslatorState();
    state = AsyncData(
      current.copyWith(
        targetLanguageCode: code,
        localLanguageCode: code == 'auto' ? current.localLanguageCode : code,
      ),
    );
  }

  void setTravellerLanguage(String code) {
    final current = state.valueOrNull ?? const TranslatorState();
    state = AsyncData(current.copyWith(travellerLanguageCode: code));
  }

  void setLocalLanguage(String code) {
    final current = state.valueOrNull ?? const TranslatorState();
    state = AsyncData(
      current.copyWith(
        localLanguageCode: code,
        targetLanguageCode: code,
      ),
    );
  }

  void swapLanguages() {
    final current = state.valueOrNull ?? const TranslatorState();
    if (current.sourceLanguageCode == 'auto') {
      state = AsyncData(
        current.copyWith(
          sourceLanguageCode: current.targetLanguageCode,
          targetLanguageCode: 'en',
        ),
      );
      return;
    }
    state = AsyncData(
      current.copyWith(
        sourceLanguageCode: current.targetLanguageCode,
        targetLanguageCode: current.sourceLanguageCode,
      ),
    );
  }

  void swapConversationLanguages() {
    final current = state.valueOrNull ?? const TranslatorState();
    state = AsyncData(
      current.copyWith(
        travellerLanguageCode: current.localLanguageCode,
        localLanguageCode: current.travellerLanguageCode,
        targetLanguageCode: current.travellerLanguageCode,
      ),
    );
  }

  Future<TranslationResponse?> translate([String? text]) async {
    final current = state.valueOrNull ?? const TranslatorState();
    final sourceText = (text ?? current.inputText).trim();
    if (sourceText.isEmpty) {
      state = AsyncData(
        current.copyWith(errorMessage: 'Enter text to translate.'),
      );
      return null;
    }

    state = const AsyncLoading<TranslatorState>().copyWithPrevious(state);
    try {
      final response = await ref.read(translationServiceProvider).translate(
            TranslationRequest(
              text: sourceText,
              sourceLanguageCode: current.sourceLanguageCode,
              targetLanguageCode: current.targetLanguageCode,
              autoDetect: current.sourceLanguageCode == 'auto',
            ),
          );
      final updatedHistory = await _saveToHistory(
        current,
        response,
        isFavourite: false,
      );
      state = AsyncData(
        current.copyWith(
          inputText: sourceText,
          lastResponse: response,
          history: updatedHistory,
          clearError: true,
        ),
      );
      return response;
    } catch (error) {
      state = AsyncData(
          current.copyWith(errorMessage: _friendlyTranslationError(error)));
      return null;
    }
  }

  Future<void> translatePhrase(PhrasebookPhrase phrase) async {
    setInputText(phrase.text);
    await translate(phrase.text);
  }

  Future<void> addConversationTurn({
    required String text,
    required bool travellerSpeaking,
  }) async {
    final current = state.valueOrNull ?? const TranslatorState();
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      state = AsyncData(
        current.copyWith(errorMessage: 'Enter conversation text.'),
      );
      return;
    }

    final source = travellerSpeaking
        ? current.travellerLanguageCode
        : current.localLanguageCode;
    final target = travellerSpeaking
        ? current.localLanguageCode
        : current.travellerLanguageCode;

    state = const AsyncLoading<TranslatorState>().copyWithPrevious(state);
    try {
      final response = await ref.read(translationServiceProvider).translate(
            TranslationRequest(
              text: trimmed,
              sourceLanguageCode: source,
              targetLanguageCode: target,
            ),
          );
      final turn = ConversationTurn(
        id: const Uuid().v4(),
        speakerLabel: travellerSpeaking ? 'Traveller' : 'Local',
        sourceText: trimmed,
        translatedText: response.translatedText,
        sourceLanguageCode: source,
        targetLanguageCode: target,
        createdAt: DateTime.now(),
      );
      final updatedHistory = await _saveToHistory(
        current,
        response,
        isFavourite: false,
      );
      state = AsyncData(
        current.copyWith(
          lastResponse: response,
          history: updatedHistory,
          conversation: [turn, ...current.conversation].take(12).toList(),
          clearError: true,
        ),
      );
    } catch (error) {
      state = AsyncData(
          current.copyWith(errorMessage: _friendlyTranslationError(error)));
    }
  }

  Future<void> favouriteLatest() async {
    final current = state.valueOrNull ?? const TranslatorState();
    final response = current.lastResponse;
    if (response == null) {
      return;
    }
    final updatedHistory = await _saveToHistory(
      current,
      response,
      isFavourite: true,
    );
    state = AsyncData(current.copyWith(history: updatedHistory));
  }

  Future<void> toggleFavourite(String id) async {
    final current = state.valueOrNull ?? const TranslatorState();
    final updated = current.history
        .map((item) => item.id == id
            ? item.copyWith(isFavourite: !item.isFavourite)
            : item)
        .toList(growable: false);
    await ref.read(translationHistoryRepositoryProvider).save(updated);
    state = AsyncData(current.copyWith(history: updated));
  }

  Future<void> clearHistory() async {
    final current = state.valueOrNull ?? const TranslatorState();
    final favourites = current.favourites;
    await ref.read(translationHistoryRepositoryProvider).save(favourites);
    state = AsyncData(current.copyWith(history: favourites));
  }

  void clearText() {
    final current = state.valueOrNull ?? const TranslatorState();
    state = AsyncData(
      current.copyWith(inputText: '', clearResponse: true, clearError: true),
    );
  }

  Future<List<SavedTranslation>> _saveToHistory(
    TranslatorState current,
    TranslationResponse response, {
    required bool isFavourite,
  }) async {
    final existing = current.history.where((item) {
      return item.sourceText != response.originalText ||
          item.targetLanguageCode != response.targetLanguageCode;
    });
    final item = SavedTranslation(
      id: const Uuid().v4(),
      sourceText: response.originalText,
      translatedText: response.translatedText,
      sourceLanguageCode: response.sourceLanguageCode,
      targetLanguageCode: response.targetLanguageCode,
      createdAt: DateTime.now(),
      isFavourite: isFavourite,
      contextLabel:
          current.context?.contextLabel ?? current.context?.destination,
    );
    final updated = [item, ...existing].take(30).toList(growable: false);
    await ref.read(translationHistoryRepositoryProvider).save(updated);
    return updated;
  }

  String? _suggestLanguageForDestination(String? destination) {
    final value = destination?.trim().toLowerCase();
    if (value == null || value.isEmpty) {
      return null;
    }
    const known = {
      'paris': 'fr',
      'france': 'fr',
      'rome': 'it',
      'italy': 'it',
      'madrid': 'es',
      'barcelona': 'es',
      'spain': 'es',
      'berlin': 'de',
      'germany': 'de',
      'lisbon': 'pt',
      'portugal': 'pt',
      'tokyo': 'ja',
      'japan': 'ja',
    };
    for (final entry in known.entries) {
      if (value.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  String _friendlyTranslationError(Object error) {
    if (error is ArgumentError) {
      return error.message?.toString() ?? 'Enter text to translate.';
    }
    return 'Translation is temporarily unavailable. You can try again or continue with text mode.';
  }
}
