import 'dart:convert';

import '../../../core/services/storage_service.dart';
import '../domain/saved_item.dart';

abstract interface class SavedItemsRepository {
  Future<List<SavedItem>> load();
  Future<void> save(List<SavedItem> items);
}

class LocalSavedItemsRepository implements SavedItemsRepository {
  LocalSavedItemsRepository(this._storage);

  static const _key = 'itarevo_saved_items_v1';

  final StorageService _storage;

  @override
  Future<List<SavedItem>> load() async {
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
        .map(SavedItem.fromJson)
        .toList(growable: false);
  }

  @override
  Future<void> save(List<SavedItem> items) {
    return _storage.write(
      key: _key,
      value: jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }
}

class MemorySavedItemsRepository implements SavedItemsRepository {
  MemorySavedItemsRepository([List<SavedItem>? initial])
      : _items = [...?initial];

  final List<SavedItem> _items;

  @override
  Future<List<SavedItem>> load() async => [..._items];

  @override
  Future<void> save(List<SavedItem> items) async {
    _items
      ..clear()
      ..addAll(items);
  }
}
