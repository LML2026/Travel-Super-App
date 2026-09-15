import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';

abstract interface class SpeechInputService {
  Future<bool> initialize();
  Future<void> listen({
    required String localeId,
    required void Function(String text, bool isFinal) onResult,
  });
  Future<void> stop();
}

abstract interface class SpeechOutputService {
  Future<void> speak({required String text, required String localeId});
  Future<void> stop();
}

class NativeSpeechInputService implements SpeechInputService {
  NativeSpeechInputService([SpeechToText? speech])
      : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;

  @override
  Future<bool> initialize() => _speech.initialize();

  @override
  Future<void> listen({
    required String localeId,
    required void Function(String text, bool isFinal) onResult,
  }) async {
    await _speech.listen(
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        onDevice: true,
      ),
      onResult: (result) =>
          onResult(result.recognizedWords, result.finalResult),
    );
  }

  @override
  Future<void> stop() => _speech.stop();
}

class NativeSpeechOutputService implements SpeechOutputService {
  static const _channel = MethodChannel('itarevo.speech');

  @override
  Future<void> speak({required String text, required String localeId}) async {
    await _channel.invokeMethod<void>('speak', {
      'text': text,
      'localeId': localeId,
    });
  }

  @override
  Future<void> stop() async {
    await _channel.invokeMethod<void>('stop');
  }
}

String speechLocaleFor(String languageCode) {
  return switch (languageCode) {
    'fr' => 'fr-FR',
    'es' => 'es-ES',
    'it' => 'it-IT',
    'de' => 'de-DE',
    'pt' => 'pt-PT',
    'ja' => 'ja-JP',
    'ar' => 'ar-SA',
    'bg' => 'bg-BG',
    'cs' => 'cs-CZ',
    'da' => 'da-DK',
    'el' => 'el-GR',
    'nl' => 'nl-NL',
    'pl' => 'pl-PL',
    'ro' => 'ro-RO',
    'ru' => 'ru-RU',
    'sv' => 'sv-SE',
    'tr' => 'tr-TR',
    'zh' => 'zh-CN',
    _ => 'en-US',
  };
}
