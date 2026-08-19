import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

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

class FirestoreSavedItemsRepository implements SavedItemsRepository {
  FirestoreSavedItemsRepository({
    FirebaseFirestore? firestore,
    required this.userId,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String userId;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(userId).collection('savedItems');

  @override
  Future<List<SavedItem>> load() async {
    final snapshot =
        await _collection.orderBy('savedAt', descending: true).get();
    return snapshot.docs
        .map((doc) => SavedItem.fromJson(doc.data()))
        .toList(growable: false);
  }

  @override
  Future<void> save(List<SavedItem> items) async {
    final batch = _firestore.batch();
    final existing = await _collection.get();
    final itemIds = items.map((item) => item.id).toSet();
    for (final doc in existing.docs) {
      if (!itemIds.contains(doc.id)) {
        batch.delete(doc.reference);
      }
    }
    for (final item in items) {
      batch.set(
          _collection.doc(item.id), item.toJson(), SetOptions(merge: true));
    }
    await batch.commit();
  }
}

class CloudBackedSavedItemsRepository implements SavedItemsRepository {
  CloudBackedSavedItemsRepository({
    required SavedItemsRepository cloud,
    required SavedItemsRepository cache,
  })  : _cloud = cloud,
        _cache = cache;

  final SavedItemsRepository _cloud;
  final SavedItemsRepository _cache;

  @override
  Future<List<SavedItem>> load() async {
    try {
      final items = await _cloud.load();
      await _cache.save(items);
      return items;
    } catch (_) {
      return _cache.load();
    }
  }

  @override
  Future<void> save(List<SavedItem> items) async {
    await _cache.save(items);
    await _cloud.save(items);
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
