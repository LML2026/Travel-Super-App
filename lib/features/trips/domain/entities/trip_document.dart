class TripDocument {
  const TripDocument({
    required this.id,
    required this.tripId,
    required this.title,
    required this.type,
    required this.reference,
    this.notes,
    this.fileName,
    this.contentType,
    this.sizeBytes,
    this.downloadUrl,
    this.storagePath,
    this.inlineBase64,
    this.uploadedBy,
    this.uploadedAt,
    this.createdAt,
  });

  final String id;
  final String tripId;
  final String title;
  final String type;
  final String reference;
  final String? notes;
  final String? fileName;
  final String? contentType;
  final int? sizeBytes;
  final String? downloadUrl;
  final String? storagePath;
  final String? inlineBase64;
  final String? uploadedBy;
  final DateTime? uploadedAt;
  final DateTime? createdAt;

  bool get hasUploadedFile =>
      (inlineBase64?.isNotEmpty == true) || (downloadUrl?.isNotEmpty == true);

  TripDocument copyWith({
    String? id,
    String? tripId,
    String? title,
    String? type,
    String? reference,
    String? notes,
    String? fileName,
    String? contentType,
    int? sizeBytes,
    String? downloadUrl,
    String? storagePath,
    String? inlineBase64,
    String? uploadedBy,
    DateTime? uploadedAt,
    DateTime? createdAt,
  }) {
    return TripDocument(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      type: type ?? this.type,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      fileName: fileName ?? this.fileName,
      contentType: contentType ?? this.contentType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      storagePath: storagePath ?? this.storagePath,
      inlineBase64: inlineBase64 ?? this.inlineBase64,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
