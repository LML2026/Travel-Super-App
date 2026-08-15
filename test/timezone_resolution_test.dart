import 'package:flutter_test/flutter_test.dart';
import 'package:itarevo/core/timezone/timezone_resolution.dart';

void main() {
  const evidence = TimezoneCoordinateEvidence(
    latitude: 51.5074,
    longitude: -0.1278,
  );
  final resolvedAt = DateTime.utc(2026, 8, 15, 12);

  test(
    'represents a confirmed resolved timezone with coordinate provenance',
    () {
      final resolution = TimezoneResolution.resolved(
        timezoneId: 'Europe/London',
        source: TimezoneResolutionSource.authoritativeProvider,
        confidence: TimezoneResolutionConfidence.confirmed,
        resolvedAt: resolvedAt,
        coordinateEvidence: evidence,
      );

      expect(resolution.status, TimezoneResolutionStatus.resolved);
      expect(resolution.timezoneId, 'Europe/London');
      expect(resolution.coordinateEvidence?.latitude, 51.5074);
      expect(resolution.coordinateEvidence?.longitude, -0.1278);
      expect(resolution.resolvedAt, resolvedAt);
      expect(resolution.hasAuthoritativeTimezone, isTrue);
    },
  );

  test(
    'resolved timezone requires nonempty identifier and coordinate evidence',
    () {
      expect(
        () => TimezoneResolution.resolved(
          timezoneId: '',
          source: TimezoneResolutionSource.authoritativeProvider,
          confidence: TimezoneResolutionConfidence.confirmed,
          resolvedAt: resolvedAt,
          coordinateEvidence: evidence,
        ),
        throwsArgumentError,
      );
    },
  );

  test('resolved timezone rejects unknown source and confidence', () {
    expect(
      () => TimezoneResolution.resolved(
        timezoneId: 'Europe/London',
        source: TimezoneResolutionSource.unknown,
        confidence: TimezoneResolutionConfidence.confirmed,
        resolvedAt: resolvedAt,
        coordinateEvidence: evidence,
      ),
      throwsArgumentError,
    );
    expect(
      () => TimezoneResolution.resolved(
        timezoneId: 'Europe/London',
        source: TimezoneResolutionSource.authoritativeProvider,
        confidence: TimezoneResolutionConfidence.unknown,
        resolvedAt: resolvedAt,
        coordinateEvidence: evidence,
      ),
      throwsArgumentError,
    );
  });

  test(
    'unknown and unavailable states contain no fabricated timezone data',
    () {
      const unknown = TimezoneResolution.unknown();
      const unavailable = TimezoneResolution.unavailable();

      for (final resolution in [unknown, unavailable]) {
        expect(resolution.timezoneId, isNull);
        expect(resolution.coordinateEvidence, isNull);
        expect(resolution.resolvedAt, isNull);
        expect(resolution.confidence, TimezoneResolutionConfidence.unknown);
        expect(resolution.hasAuthoritativeTimezone, isFalse);
      }
    },
  );

  test(
    'stale retains prior provenance but is not authoritative clock evidence',
    () {
      final stale = TimezoneResolution.stale(
        timezoneId: 'Asia/Tokyo',
        source: TimezoneResolutionSource.trustedCache,
        resolvedAt: resolvedAt,
        coordinateEvidence: evidence,
      );

      expect(stale.status, TimezoneResolutionStatus.stale);
      expect(stale.timezoneId, 'Asia/Tokyo');
      expect(stale.coordinateEvidence, same(evidence));
      expect(stale.confidence, TimezoneResolutionConfidence.unknown);
      expect(stale.hasAuthoritativeTimezone, isFalse);
    },
  );

  test('same inputs produce consistent domain state without offset fields', () {
    final first = TimezoneResolution.resolved(
      timezoneId: 'America/New_York',
      source: TimezoneResolutionSource.explicit,
      confidence: TimezoneResolutionConfidence.high,
      resolvedAt: resolvedAt,
      coordinateEvidence: evidence,
    );
    final second = TimezoneResolution.resolved(
      timezoneId: 'America/New_York',
      source: TimezoneResolutionSource.explicit,
      confidence: TimezoneResolutionConfidence.high,
      resolvedAt: resolvedAt,
      coordinateEvidence: evidence,
    );

    expect(first.timezoneId, second.timezoneId);
    expect(first.status, second.status);
    expect(first.source, second.source);
    expect(first.confidence, second.confidence);
  });
}
