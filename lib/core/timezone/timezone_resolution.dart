enum TimezoneResolutionStatus { resolved, unavailable, stale, unknown }

enum TimezoneResolutionSource {
  authoritativeProvider,
  trustedCache,
  explicit,
  unknown,
}

enum TimezoneResolutionConfidence { confirmed, high, unknown }

class TimezoneCoordinateEvidence {
  final double latitude;
  final double longitude;

  const TimezoneCoordinateEvidence({
    required this.latitude,
    required this.longitude,
  });
}

class TimezoneResolution {
  final String? timezoneId;
  final TimezoneResolutionStatus status;
  final TimezoneResolutionSource source;
  final TimezoneResolutionConfidence confidence;
  final DateTime? resolvedAt;
  final TimezoneCoordinateEvidence? coordinateEvidence;

  const TimezoneResolution._({
    required this.timezoneId,
    required this.status,
    required this.source,
    required this.confidence,
    required this.resolvedAt,
    required this.coordinateEvidence,
  });

  factory TimezoneResolution.resolved({
    required String timezoneId,
    required TimezoneResolutionSource source,
    required TimezoneResolutionConfidence confidence,
    required DateTime resolvedAt,
    required TimezoneCoordinateEvidence coordinateEvidence,
  }) {
    if (timezoneId.trim().isEmpty) {
      throw ArgumentError.value(timezoneId, 'timezoneId', 'must not be empty');
    }
    if (source == TimezoneResolutionSource.unknown) {
      throw ArgumentError.value(source, 'source', 'must be authoritative');
    }
    if (confidence == TimezoneResolutionConfidence.unknown) {
      throw ArgumentError.value(
        confidence,
        'confidence',
        'must not be unknown',
      );
    }

    return TimezoneResolution._(
      timezoneId: timezoneId,
      status: TimezoneResolutionStatus.resolved,
      source: source,
      confidence: confidence,
      resolvedAt: resolvedAt,
      coordinateEvidence: coordinateEvidence,
    );
  }

  factory TimezoneResolution.stale({
    required String timezoneId,
    required TimezoneResolutionSource source,
    required DateTime resolvedAt,
    required TimezoneCoordinateEvidence coordinateEvidence,
  }) {
    if (timezoneId.trim().isEmpty) {
      throw ArgumentError.value(timezoneId, 'timezoneId', 'must not be empty');
    }
    if (source == TimezoneResolutionSource.unknown) {
      throw ArgumentError.value(source, 'source', 'must retain provenance');
    }

    return TimezoneResolution._(
      timezoneId: timezoneId,
      status: TimezoneResolutionStatus.stale,
      source: source,
      confidence: TimezoneResolutionConfidence.unknown,
      resolvedAt: resolvedAt,
      coordinateEvidence: coordinateEvidence,
    );
  }

  const TimezoneResolution.unavailable()
    : timezoneId = null,
      status = TimezoneResolutionStatus.unavailable,
      source = TimezoneResolutionSource.unknown,
      confidence = TimezoneResolutionConfidence.unknown,
      resolvedAt = null,
      coordinateEvidence = null;

  const TimezoneResolution.unknown()
    : timezoneId = null,
      status = TimezoneResolutionStatus.unknown,
      source = TimezoneResolutionSource.unknown,
      confidence = TimezoneResolutionConfidence.unknown,
      resolvedAt = null,
      coordinateEvidence = null;

  bool get hasAuthoritativeTimezone =>
      status == TimezoneResolutionStatus.resolved &&
      confidence != TimezoneResolutionConfidence.unknown;
}
