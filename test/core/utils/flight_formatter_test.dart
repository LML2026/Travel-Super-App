import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/core/utils/flight_formatter.dart';

void main() {
  group('formatDuration', () {
    test('parses hours and minutes', () {
      expect(formatDuration('PT4H35M'), '4h 35m');
    });

    test('pads single-digit minutes', () {
      expect(formatDuration('PT2H5M'), '2h 05m');
    });

    test('handles hours only', () {
      expect(formatDuration('PT3H'), '3h');
    });

    test('handles minutes only', () {
      expect(formatDuration('PT45M'), '45m');
    });

    test('returns N/A for empty string', () {
      expect(formatDuration(''), 'N/A');
    });

    test('returns N/A for invalid format', () {
      expect(formatDuration('invalid'), 'N/A');
    });

    test('handles long-haul flight', () {
      expect(formatDuration('PT14H30M'), '14h 30m');
    });
  });

  group('formatTime', () {
    test('extracts HH:MM from ISO datetime', () {
      expect(formatTime('2026-08-20T14:25:00'), '14:25');
    });

    test('pads midnight correctly', () {
      expect(formatTime('2026-08-20T00:05:00'), '00:05');
    });

    test('handles noon', () {
      expect(formatTime('2026-08-20T12:00:00'), '12:00');
    });

    test('returns fallback for invalid input', () {
      expect(formatTime('not-a-date'), '--:--');
    });
  });
}
