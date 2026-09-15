import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/core/api/api_client.dart';
import 'package:travel_super_app/features/flights/models/flight.dart';
import 'package:travel_super_app/features/flights/services/flight_service.dart';

class _FakeApiClient extends ApiClient {
  _FakeApiClient(this._handler) : super(dio: Dio());

  final Future<Response<dynamic>> Function(String path, Object? data) _handler;
  int postCount = 0;

  @override
  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    postCount += 1;
    return _handler(path, data);
  }
}

void main() {
  group('FlightService', () {
    test('uses backend flight API results first', () async {
      final apiClient = _FakeApiClient((path, data) async {
        return Response<dynamic>(
          requestOptions: RequestOptions(path: path),
          statusCode: 200,
          data: <String, dynamic>{
            'flights': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'backend-1',
                'airline': 'Backend Airways',
                'airlineLogo': '',
                'flightNumber': 'BA100',
                'origin': 'LHR',
                'destination': 'CDG',
                'departureAt': '2026-09-15T08:00:00',
                'arrivalAt': '2026-09-15T10:00:00',
                'duration': 'PT2H',
                'stops': 0,
                'amount': 120,
                'currency': 'GBP',
                'cabinClass': 'economy',
              },
            ],
          },
        );
      });

      final service = FlightService(apiClient: apiClient);

      final flights = await service.searchFlights(
        from: 'lhr',
        to: 'cdg',
        departureDate: '2026-09-15',
      );

      expect(apiClient.postCount, 1);
      expect(flights, hasLength(1));
      expect(flights.single.id, 'backend-1');
      expect(flights.single.dataSource, FlightDataSource.backend);
      expect(service.lastSearchUsedFallback, isFalse);
    });

    test('keeps deterministic demo fallback when backend is unavailable',
        () async {
      final apiClient = _FakeApiClient((path, data) async {
        throw DioException(
          requestOptions: RequestOptions(path: path),
          type: DioExceptionType.connectionError,
          error: 'offline',
        );
      });

      final service = FlightService(apiClient: apiClient);

      final flights = await service.searchFlights(
        from: 'lhr',
        to: 'cdg',
        departureDate: '2026-09-15',
        cabinClass: 'premium',
      );

      expect(apiClient.postCount, 1);
      expect(flights, hasLength(1));
      expect(flights.single.id, 'demo-lhr-cdg-2026-09-15');
      expect(flights.single.dataSource, FlightDataSource.demo);
      expect(flights.single.cabinClass, 'premium');
      expect(service.lastSearchUsedFallback, isTrue);
    });
  });
}
