import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/flights/models/saved_flight.dart';

void main() {
  test('parses savedAt from ISO-8601 string', () {
    final savedAt = DateTime.utc(2026, 8, 28, 12, 30);

    final flight = SavedFlight.fromJson(_savedFlightJson(
      savedAt: savedAt.toIso8601String(),
    ));

    expect(flight.savedAt.isAtSameMomentAs(savedAt), isTrue);
    expect(flight.flightId, 'flight-1');
  });

  test('parses savedAt from Firestore Timestamp', () {
    final savedAt = DateTime.utc(2026, 8, 28, 12, 30);

    final flight = SavedFlight.fromJson(_savedFlightJson(
      savedAt: Timestamp.fromDate(savedAt),
    ));

    expect(flight.savedAt.isAtSameMomentAs(savedAt), isTrue);
    expect(flight.flightId, 'flight-1');
  });

  test('falls back to id when flightId is missing', () {
    final flight = SavedFlight.fromJson(_savedFlightJson(
      flightId: null,
      savedAt: DateTime.utc(2026, 8, 28).toIso8601String(),
    ));

    expect(flight.id, 'flight-1');
    expect(flight.flightId, 'flight-1');
  });
}

Map<String, dynamic> _savedFlightJson({
  Object? savedAt,
  String? flightId = 'flight-1',
}) {
  return <String, dynamic>{
    'id': 'flight-1',
    if (flightId != null) 'flightId': flightId,
    'airline': 'ITAREVO Test Airways',
    'airlineLogo': '',
    'flightNumber': 'IT 100',
    'origin': 'LHR',
    'destination': 'CDG',
    'departureAt': '2026-09-01T08:00:00Z',
    'arrivalAt': '2026-09-01T10:00:00Z',
    'duration': 'PT2H',
    'stops': 0,
    'amount': 120.0,
    'currency': 'GBP',
    'cabinClass': 'economy',
    'source': 'test',
    'savedAt': savedAt,
  };
}
