import 'dart:convert';

import '../../../core/services/storage_service.dart';
import '../domain/translation_models.dart';

abstract interface class TranslationHistoryRepository {
  Future<List<SavedTranslation>> load();
  Future<void> save(List<SavedTranslation> translations);
}

class LocalTranslationHistoryRepository
    implements TranslationHistoryRepository {
  LocalTranslationHistoryRepository(this._storage);

  static const _key = 'itarevo_translator_history_v1';

  final StorageService _storage;

  @override
  Future<List<SavedTranslation>> load() async {
    final raw = await _storage.read(_key);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(SavedTranslation.fromJson)
        .toList(growable: false);
  }

  @override
  Future<void> save(List<SavedTranslation> translations) {
    final encoded = jsonEncode(
      translations.map((translation) => translation.toJson()).toList(),
    );
    return _storage.write(key: _key, value: encoded);
  }
}

class MemoryTranslationHistoryRepository
    implements TranslationHistoryRepository {
  MemoryTranslationHistoryRepository([List<SavedTranslation>? initial])
      : _translations = [...?initial];

  final List<SavedTranslation> _translations;

  @override
  Future<List<SavedTranslation>> load() async {
    return [..._translations];
  }

  @override
  Future<void> save(List<SavedTranslation> translations) async {
    _translations
      ..clear()
      ..addAll(translations);
  }
}
