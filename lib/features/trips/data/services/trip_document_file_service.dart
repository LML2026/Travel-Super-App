import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/trip_document.dart';
import '../../domain/entities/trip_document_upload.dart';

class TripDocumentFileService {
  const TripDocumentFileService();

  static const int maxInlineBytes = 700 * 1024;

  Future<TripDocumentUpload> readLocalFile(String path) async {
    final file = File(path);
    final exists = await file.exists();
    if (!exists) {
      throw FileSystemException('File not found', path);
    }

    final bytes = await file.readAsBytes();
    if (bytes.length > maxInlineBytes) {
      throw StateError(
        'This file is too large for inline trip storage. Add it as a secure URL/reference for now.',
      );
    }

    return TripDocumentUpload(
      fileName: path.split(Platform.pathSeparator).last,
      contentType: _contentTypeFor(path),
      bytes: bytes,
    );
  }

  Future<void> openDocument(TripDocument document) async {
    final downloadUrl = document.downloadUrl ?? document.reference;
    final uri = Uri.tryParse(downloadUrl);
    if (uri != null && uri.hasScheme && uri.scheme != 'file') {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        throw StateError('Could not open document link.');
      }
      return;
    }

    final inlineBase64 = document.inlineBase64;
    if (inlineBase64 == null || inlineBase64.isEmpty) {
      throw StateError('This document has no uploaded file or URL to open.');
    }

    final directory = await getTemporaryDirectory();
    final fileName = document.fileName ?? '${document.id}.txt';
    final file = File('${directory.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(base64Decode(inlineBase64), flush: true);
    final opened = await launchUrl(
      file.uri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      throw StateError('Document downloaded to ${file.path}.');
    }
  }

  String encodeInline(TripDocumentUpload upload) {
    return base64Encode(upload.bytes);
  }

  String _contentTypeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return 'application/pdf';
    }
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lower.endsWith('.json')) {
      return 'application/json';
    }
    return 'application/octet-stream';
  }
}
