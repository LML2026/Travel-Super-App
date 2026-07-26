import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_super_app/core/utils/result.dart';
import 'package:travel_super_app/features/flights/models/flight.dart';
import 'package:travel_super_app/features/flights/models/flight_search_request.dart';
import 'package:travel_super_app/features/flights/repositories/flight_repository.dart';
import 'package:travel_super_app/features/flights/services/flight_service.dart';

class MockFlightService extends Mock implements FlightService {}

void main() {
  late FlightRepository repository;
  late MockFlightService mockService;

  final testRequest = const FlightSearchRequest(
    from: 'LHR',
    to: 'CDG',
    departureDate: '2026-08-20',
    passengers: 1,
    cabinClass: 'economy',
  );

  final testFlights = [
    Flight(
      id: 'offer_1',
      airline: 'British Airways',
      airlineLogo: '',
      flightNumber: 'BA304',
      origin: 'LHR',
      destination: 'CDG',
      departureAt: '2026-08-20T08:00:00',
      arrivalAt: '2026-08-20T10:15:00',
      duration: 'PT2H15M',
      stops: 0,
      amount: 95.0,
      currency: 'GBP',
    ),
  ];

  setUp(() {
    mockService = MockFlightService();
    repository = FlightRepository(api: mockService);
    registerFallbackValue('');
  });

  group('FlightRepository', () {
    test('returns Success with flights on successful API call', () async {
      when(() => mockService.searchFlights(
            from: any(named: 'from'),
            to: any(named: 'to'),
            departureDate: any(named: 'departureDate'),
            returnDate: any(named: 'returnDate'),
            passengers: any(named: 'passengers'),
            cabinClass: any(named: 'cabinClass'),
          )).thenAnswer((_) async => testFlights);

      final result = await repository.searchFlights(testRequest);

      expect(result, isA<Success<List<Flight>>>());
      final success = result as Success<List<Flight>>;
      expect(success.data.length, 1);
      expect(success.data.first.airline, 'British Airways');
    });

    test('returns Failure when API throws', () async {
      when(() => mockService.searchFlights(
            from: any(named: 'from'),
            to: any(named: 'to'),
            departureDate: any(named: 'departureDate'),
            returnDate: any(named: 'returnDate'),
            passengers: any(named: 'passengers'),
            cabinClass: any(named: 'cabinClass'),
          )).thenThrow(Exception('Network error'));

      final result = await repository.searchFlights(testRequest);

      expect(result, isA<Failure<List<Flight>>>());
      final failure = result as Failure<List<Flight>>;
      expect(failure.message, contains('Network error'));
    });

    test('FlightSearchRequest equality works for caching', () {
      const req1 = FlightSearchRequest(from: 'LHR', to: 'CDG', departureDate: '2026-08-20');
      const req2 = FlightSearchRequest(from: 'LHR', to: 'CDG', departureDate: '2026-08-20');
      const req3 = FlightSearchRequest(from: 'LHR', to: 'JFK', departureDate: '2026-08-20');

      expect(req1, equals(req2));
      expect(req1.hashCode, equals(req2.hashCode));
      expect(req1, isNot(equals(req3)));
    });

    test('flights sort correctly by amount', () {
      final flights = [
        testFlights.first,
        Flight(
          id: 'offer_2',
          airline: 'Ryanair',
          airlineLogo: '',
          flightNumber: 'FR123',
          origin: 'LHR',
          destination: 'CDG',
          departureAt: '2026-08-20T12:00:00',
          arrivalAt: '2026-08-20T14:00:00',
          duration: 'PT2H',
          stops: 0,
          amount: 49.99,
          currency: 'GBP',
        ),
      ];

      flights.sort((a, b) => a.amount.compareTo(b.amount));

      expect(flights.first.airline, 'Ryanair');
      expect(flights.last.airline, 'British Airways');
    });
  });
}
