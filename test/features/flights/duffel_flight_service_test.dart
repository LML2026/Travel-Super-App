import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:travel_super_app/features/flights/models/flight.dart';
import 'package:travel_super_app/features/flights/services/duffel_flight_service.dart';

class _FakeDuffelClient extends http.BaseClient {
  _FakeDuffelClient(this.body, {required this.statusCode});

  final Map<String, dynamic> body;
  final int statusCode;
  late final http.BaseRequest request;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    this.request = request;
    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(jsonEncode(body))),
      statusCode,
      headers: const {'content-type': 'application/json'},
    );
  }
}

void main() {
  test('maps a Duffel TEST offer into the existing Flight model', () async {
    final client = _FakeDuffelClient(<String, dynamic>{
      'data': <String, dynamic>{
        'live_mode': false,
        'offers': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'off_test_123',
            'owner': <String, dynamic>{'name': 'Test Airways'},
            'total_amount': '145.50',
            'total_currency': 'GBP',
            'slices': <Map<String, dynamic>>[
              <String, dynamic>{
                'duration': 'PT2H15M',
                'origin': <String, dynamic>{'iata_code': 'LHR'},
                'destination': <String, dynamic>{'iata_code': 'CDG'},
                'segments': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'flight_number': 'TA123',
                    'departing_at': '2026-09-15T08:00:00Z',
                    'arriving_at': '2026-09-15T10:15:00Z',
                    'marketing_carrier': <String, dynamic>{
                      'name': 'Test Airways',
                      'logo_symbol_url': 'https://example.test/logo.png',
                    },
                    'passengers': <Map<String, dynamic>>[
                      <String, dynamic>{'cabin_class': 'economy'},
                    ],
                  },
                ],
              },
            ],
          },
        ],
      },
    }, statusCode: 200);

    final flights = await DuffelFlightService(
      client: client,
      tokenReader: () => 'fixture-value',
    ).searchFlights(
      from: 'LHR',
      to: 'CDG',
      departureDate: '2026-09-15',
      cabinClass: 'economy',
    );

    expect(flights, hasLength(1));
    expect(flights.single.dataSource, FlightDataSource.duffelTest);
    expect(flights.single.airline, 'Test Airways');
    expect(flights.single.flightNumber, 'TA123');
    expect(flights.single.origin, 'LHR');
    expect(flights.single.destination, 'CDG');
    expect(flights.single.amount, 145.50);
    expect(flights.single.cabinClass, 'economy');
    expect(client.request.headers['Authorization'], startsWith('Bearer '));
  });

  test('does not call Duffel when the local token is unavailable', () async {
    final client =
        _FakeDuffelClient(const <String, dynamic>{}, statusCode: 200);
    final service = DuffelFlightService(
      client: client,
      tokenReader: () => null,
    );

    expect(service.isConfigured, isFalse);
    await expectLater(
      service.searchFlights(
        from: 'LHR',
        to: 'CDG',
        departureDate: '2026-09-15',
      ),
      throwsA(isA<DuffelNotConfiguredException>()),
    );
  });

  test('normalizes a locally configured Bearer token before sending it',
      () async {
    final client = _FakeDuffelClient(<String, dynamic>{
      'data': <String, dynamic>{
        'live_mode': false,
        'offers': <Map<String, dynamic>>[],
      },
    }, statusCode: 200);

    await DuffelFlightService(
      client: client,
      tokenReader: () => '  Bearer fixture-value  ',
    ).searchFlights(
      from: 'EDI',
      to: 'LHR',
      departureDate: '2026-10-01',
      passengers: 3,
      cabinClass: 'business',
    );

    expect(client.request.headers['Authorization'], 'Bearer fixture-value');
  });
}
