import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/trip_document_upload.dart';

abstract interface class TripDocumentStorageService {
  Future<String> upload({
    required String ownerUserId,
    required String tripId,
    required String documentId,
    required TripDocumentUpload upload,
    void Function(double progress)? onProgress,
  });

  Future<void> open({required String storagePath, required String fileName});

  Future<void> delete(String storagePath);
}

class FirebaseTripDocumentStorageService implements TripDocumentStorageService {
  FirebaseTripDocumentStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  @override
  Future<String> upload({
    required String ownerUserId,
    required String tripId,
    required String documentId,
    required TripDocumentUpload upload,
    void Function(double progress)? onProgress,
  }) async {
    final safeName = _safeFileName(upload.fileName);
    final path =
        'users/$ownerUserId/trips/$tripId/documents/$documentId/$safeName';
    final task = _storage.ref(path).putData(
          Uint8List.fromList(upload.bytes),
          SettableMetadata(contentType: upload.contentType),
        );
    task.snapshotEvents.listen((snapshot) {
      final total = snapshot.totalBytes;
      if (total > 0) {
        onProgress?.call(snapshot.bytesTransferred / total);
      }
    });
    await task;
    return path;
  }

  @override
  Future<void> open({
    required String storagePath,
    required String fileName,
  }) async {
    final bytes = await _storage.ref(storagePath).getData(25 * 1024 * 1024);
    if (bytes == null) {
      throw StateError('This document could not be downloaded.');
    }
    final directory = await getTemporaryDirectory();
    final file = File(
        '${directory.path}${Platform.pathSeparator}${_safeFileName(fileName)}');
    await file.writeAsBytes(bytes, flush: true);
    if (!await launchUrl(file.uri, mode: LaunchMode.externalApplication)) {
      throw StateError('Could not open document.');
    }
  }

  @override
  Future<void> delete(String storagePath) => _storage.ref(storagePath).delete();

  String _safeFileName(String value) {
    final name = value.split(RegExp(r'[/\\]')).last.trim();
    return name.isEmpty ? 'document.bin' : name.replaceAll('..', '_');
  }
}
