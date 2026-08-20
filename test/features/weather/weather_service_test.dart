import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:travel_super_app/features/weather/models/weather_data.dart';
import 'package:travel_super_app/features/weather/services/open_meteo_weather_service.dart';
import 'package:travel_super_app/features/weather/services/weather_service.dart';

class _OpenMeteoClient extends http.BaseClient {
  final List<Uri> requests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request.url);
    final body = request.url.host.startsWith('geocoding')
        ? <String, dynamic>{
            'results': <Map<String, dynamic>>[
              <String, dynamic>{
                'name': 'Paris',
                'country': 'France',
                'latitude': 48.8566,
                'longitude': 2.3522,
              },
            ],
          }
        : <String, dynamic>{
            'current': <String, dynamic>{
              'temperature_2m': 21.5,
              'relative_humidity_2m': 62,
              'apparent_temperature': 22.1,
              'weather_code': 1,
              'wind_speed_10m': 14.2,
            },
            'daily': <String, dynamic>{
              'time': <String>['2026-08-20', '2026-08-21', '2026-08-22'],
              'weather_code': <int>[1, 61, 3],
              'temperature_2m_max': <double>[23, 20, 22],
              'temperature_2m_min': <double>[15, 14, 16],
            },
          };
    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(jsonEncode(body))),
      200,
      headers: const {'content-type': 'application/json'},
    );
  }
}

void main() {
  test('maps Open-Meteo current conditions and short forecast', () async {
    final client = _OpenMeteoClient();
    final weather =
        await OpenMeteoWeatherService(client: client).getWeather('Paris');

    expect(weather.dataSource, WeatherDataSource.openMeteo);
    expect(weather.city, 'Paris');
    expect(weather.country, 'France');
    expect(weather.tempC, 21.5);
    expect(weather.humidity, 62);
    expect(weather.windKph, 14.2);
    expect(weather.forecast, hasLength(3));
    expect(weather.forecast[1].description, 'Rain');
    expect(client.requests, hasLength(2));
  });

  test('prefers live weather and labels the source', () async {
    final service = WeatherService(
      liveWeather: (_) async => const WeatherData(
        city: 'Paris',
        country: 'France',
        tempC: 21,
        tempF: 70,
        description: 'Clear sky',
        iconCode: '1',
        humidity: 50,
        windKph: 10,
        condition: 'Clear sky',
        dataSource: WeatherDataSource.openMeteo,
      ),
      backendWeather: (_) async => throw StateError('backend should not run'),
    );

    final weather = await service.getWeather('Paris');

    expect(weather.dataSource, WeatherDataSource.openMeteo);
  });

  test('falls back deterministically when live and backend weather fail',
      () async {
    final service = WeatherService(
      liveWeather: (_) async => throw const WeatherProviderException('offline'),
      backendWeather: (_) async => throw const WeatherSearchException(),
    );

    final first = await service.getWeather('London');
    final second = await service.getWeather('London');

    expect(first.dataSource, WeatherDataSource.demo);
    expect(first.toJson(), second.toJson());
    expect(first.city, 'London');
    expect(first.condition, 'Partly cloudy');
  });
}
