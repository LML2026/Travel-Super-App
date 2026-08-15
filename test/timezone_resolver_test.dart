import 'package:flutter_test/flutter_test.dart';
import 'package:itarevo/core/timezone/timezone_resolution.dart';
import 'package:itarevo/core/timezone/timezone_resolver.dart';

void main() {
  const coordinates = TimezoneCoordinateEvidence(
    latitude: 35.6762,
    longitude: 139.6503,
  );
  final resolvedAt = DateTime.utc(2026, 8, 15, 12);

  test('fake resolver returns configured resolved result unchanged', () async {
    final expected = TimezoneResolution.resolved(
      timezoneId: 'Asia/Tokyo',
      source: TimezoneResolutionSource.authoritativeProvider,
      confidence: TimezoneResolutionConfidence.confirmed,
      resolvedAt: resolvedAt,
      coordinateEvidence: coordinates,
    );
    final resolver = FakeTimezoneResolver(expected);

    final result = await resolver.resolve(coordinates);

    expect(result, same(expected));
    expect(result.timezoneId, 'Asia/Tokyo');
    expect(result.source, TimezoneResolutionSource.authoritativeProvider);
    expect(result.confidence, TimezoneResolutionConfidence.confirmed);
    expect(result.coordinateEvidence, same(coordinates));
    expect(result.resolvedAt, resolvedAt);
  });

  test(
    'fake resolver returns configured unavailable, unknown, and stale states',
    () async {
      const unavailable = TimezoneResolution.unavailable();
      const unknown = TimezoneResolution.unknown();
      final stale = TimezoneResolution.stale(
        timezoneId: 'Europe/London',
        source: TimezoneResolutionSource.trustedCache,
        resolvedAt: resolvedAt,
        coordinateEvidence: coordinates,
      );

      for (final expected in [unavailable, unknown, stale]) {
        final result = await FakeTimezoneResolver(
          expected,
        ).resolve(coordinates);
        expect(result, same(expected));
      }
    },
  );

  test(
    'fake resolver is deterministic for repeated coordinate input',
    () async {
      const expected = TimezoneResolution.unknown();
      final resolver = FakeTimezoneResolver(expected);

      final first = await resolver.resolve(coordinates);
      final second = await resolver.resolve(
        const TimezoneCoordinateEvidence(latitude: 51.5074, longitude: -0.1278),
      );

      expect(first, same(expected));
      expect(second, same(expected));
    },
  );
}

class FakeTimezoneResolver implements TimezoneResolver {
  final TimezoneResolution result;

  const FakeTimezoneResolver(this.result);

  @override
  Future<TimezoneResolution> resolve(TimezoneCoordinateEvidence coordinates) =>
      Future.value(result);
}
