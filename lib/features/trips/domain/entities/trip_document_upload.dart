class TripDocumentUpload {
  const TripDocumentUpload({
    required this.fileName,
    required this.contentType,
    required this.bytes,
  });

  final String fileName;
  final String contentType;
  final List<int> bytes;

  int get sizeBytes => bytes.length;
}
