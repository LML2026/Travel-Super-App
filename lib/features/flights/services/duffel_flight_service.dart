import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/flight.dart';

typedef DuffelTokenReader = String? Function();

class DuffelFlightService {
  DuffelFlightService({
    http.Client? client,
    DuffelTokenReader? tokenReader,
  })  : _client = client ?? http.Client(),
        _tokenReader = tokenReader ?? _readConfiguredToken;

  static final Uri _offerRequestsUri =
      Uri.parse('https://api.duffel.com/air/offer_requests');

  final http.Client _client;
  final DuffelTokenReader _tokenReader;

  bool get isConfigured => _readToken() != null;

  Future<List<Flight>> searchFlights({
    required String from,
    required String to,
    required String departureDate,
    String? returnDate,
    int passengers = 1,
    String cabinClass = 'economy',
  }) async {
    final token = _readToken();
    if (token == null) {
      throw const DuffelNotConfiguredException();
    }

    final slices = <Map<String, String>>[
      {
        'origin': from.trim().toUpperCase(),
        'destination': to.trim().toUpperCase(),
        'departure_date': departureDate,
      },
    ];
    if (returnDate != null && returnDate.isNotEmpty) {
      slices.add({
        'origin': to.trim().toUpperCase(),
        'destination': from.trim().toUpperCase(),
        'departure_date': returnDate,
      });
    }

    final response = await _client.post(
      _offerRequestsUri,
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Duffel-Version': 'v2',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, Object?>{
        'data': <String, Object?>{
          'slices': slices,
          'passengers': List<Map<String, String>>.generate(
            passengers,
            (_) => <String, String>{'type': 'adult'},
          ),
          'cabin_class': cabinClass.toLowerCase(),
          'return_offers': true,
        },
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw DuffelApiException(response.statusCode);
    }

    final root = jsonDecode(response.body);
    if (root is! Map) {
      throw const FormatException('Duffel returned an invalid response.');
    }
    final data = root['data'];
    if (data is! Map) {
      throw const FormatException('Duffel offer data is missing.');
    }
    if (data['live_mode'] == true) {
      throw const FormatException('Duffel returned unexpected live-mode data.');
    }

    final offers = data['offers'];
    if (offers is! List) {
      throw const FormatException('Duffel offer list is missing.');
    }

    return offers
        .whereType<Map>()
        .map((offer) => _mapOffer(Map<String, dynamic>.from(offer)))
        .toList(growable: false);
  }

  String? _readToken() {
    try {
      final configured = _tokenReader()?.trim();
      if (configured == null || configured.isEmpty) {
        return null;
      }

      var token = configured.replaceFirst('\uFEFF', '');
      if (token.startsWith('Bearer ')) {
        token = token.substring('Bearer '.length).trim();
      }
      if (token.length >= 2 &&
          ((token.startsWith('"') && token.endsWith('"')) ||
              (token.startsWith("'") && token.endsWith("'")))) {
        token = token.substring(1, token.length - 1).trim();
      }
      return token.isEmpty ? null : token;
    } catch (_) {
      return null;
    }
  }

  Flight _mapOffer(Map<String, dynamic> offer) {
    final slices = (offer['slices'] as List<dynamic>?)
            ?.whereType<Map>()
            .map((slice) => Map<String, dynamic>.from(slice))
            .toList(growable: false) ??
        const <Map<String, dynamic>>[];
    final firstSlice =
        slices.isEmpty ? const <String, dynamic>{} : slices.first;
    final lastSlice = slices.isEmpty ? const <String, dynamic>{} : slices.last;
    final segments = slices
        .expand((slice) => (slice['segments'] as List<dynamic>?) ?? const [])
        .whereType<Map>()
        .map((segment) => Map<String, dynamic>.from(segment))
        .toList(growable: false);
    final firstSegment =
        segments.isEmpty ? const <String, dynamic>{} : segments.first;
    final lastSegment =
        segments.isEmpty ? const <String, dynamic>{} : segments.last;
    final owner = offer['owner'] as Map<String, dynamic>?;
    final marketingCarrier =
        firstSegment['marketing_carrier'] as Map<String, dynamic>?;
    final firstPassenger = (firstSegment['passengers'] as List<dynamic>?)
        ?.whereType<Map>()
        .map((passenger) => Map<String, dynamic>.from(passenger))
        .firstOrNull;

    return Flight(
      id: offer['id']?.toString() ?? '',
      airline: owner?['name']?.toString() ??
          marketingCarrier?['name']?.toString() ??
          'Unknown airline',
      airlineLogo: marketingCarrier?['logo_symbol_url']?.toString() ?? '',
      flightNumber: firstSegment['flight_number']?.toString() ?? '',
      origin: _airportCode(firstSlice['origin']),
      destination: _airportCode(lastSlice['destination']),
      departureAt: firstSegment['departing_at']?.toString() ?? '',
      arrivalAt: lastSegment['arriving_at']?.toString() ?? '',
      duration: firstSlice['duration']?.toString() ??
          firstSegment['duration']?.toString() ??
          '',
      stops: (segments.length - slices.length).clamp(0, 99).toInt(),
      amount: double.tryParse(offer['total_amount']?.toString() ?? '') ?? 0,
      currency: offer['total_currency']?.toString() ?? 'GBP',
      cabinClass: firstPassenger?['cabin_class']?.toString() ?? '',
      dataSource: FlightDataSource.duffelTest,
    );
  }

  String _airportCode(Object? airport) {
    if (airport is Map) {
      return airport['iata_code']?.toString() ??
          airport['icao_code']?.toString() ??
          '';
    }
    return '';
  }

  static String? _readConfiguredToken() {
    return dotenv.maybeGet('DUFFEL_ACCESS_TOKEN');
  }
}

class DuffelNotConfiguredException implements Exception {
  const DuffelNotConfiguredException();
}

class DuffelApiException implements Exception {
  const DuffelApiException(this.statusCode);

  final int statusCode;
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
