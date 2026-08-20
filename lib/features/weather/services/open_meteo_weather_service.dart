import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_data.dart';

class OpenMeteoWeatherService {
  OpenMeteoWeatherService({http.Client? client})
      : _client = client ?? http.Client();

  static final Uri _geocodingUri =
      Uri.parse('https://geocoding-api.open-meteo.com/v1/search');
  static final Uri _forecastUri =
      Uri.parse('https://api.open-meteo.com/v1/forecast');

  final http.Client _client;

  Future<WeatherData> getWeather(String city) async {
    final locationResponse = await _client
        .get(_geocodingUri.replace(queryParameters: {
          'name': city,
          'count': '1',
          'language': 'en',
          'format': 'json',
        }))
        .timeout(const Duration(seconds: 8));
    _ensureSuccess(locationResponse);

    final locationJson = jsonDecode(locationResponse.body);
    final results = locationJson is Map ? locationJson['results'] : null;
    final location =
        results is List && results.isNotEmpty ? results.first : null;
    if (location is! Map) {
      throw const WeatherProviderException('Weather location not found.');
    }

    final latitude = double.tryParse(location['latitude']?.toString() ?? '');
    final longitude = double.tryParse(location['longitude']?.toString() ?? '');
    if (latitude == null || longitude == null) {
      throw const WeatherProviderException('Weather location is unavailable.');
    }

    final forecastResponse = await _client
        .get(_forecastUri.replace(queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'current':
              'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m',
          'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
          'forecast_days': '3',
          'timezone': 'auto',
        }))
        .timeout(const Duration(seconds: 8));
    _ensureSuccess(forecastResponse);

    final forecastJson = jsonDecode(forecastResponse.body);
    if (forecastJson is! Map || forecastJson['current'] is! Map) {
      throw const WeatherProviderException(
          'Weather conditions are unavailable.');
    }

    final current = Map<String, dynamic>.from(forecastJson['current'] as Map);
    final code = (current['weather_code'] as num?)?.toInt() ?? -1;
    final condition = _conditionFor(code);
    return WeatherData(
      city: location['name']?.toString() ?? city,
      country: location['country']?.toString() ?? '',
      tempC: _number(current['temperature_2m']),
      tempF: _celsiusToFahrenheit(_number(current['apparent_temperature'])),
      description: condition,
      iconCode: code.toString(),
      humidity: _number(current['relative_humidity_2m']).round(),
      windKph: _number(current['wind_speed_10m']),
      condition: condition,
      forecast: _forecastDays(forecastJson['daily']),
      dataSource: WeatherDataSource.openMeteo,
    );
  }

  List<WeatherForecastDay> _forecastDays(Object? rawDaily) {
    if (rawDaily is! Map || rawDaily['time'] is! List) {
      return const [];
    }
    final dates =
        (rawDaily['time'] as List).map((value) => value.toString()).toList();
    final codes = (rawDaily['weather_code'] as List?) ?? const [];
    final highs = (rawDaily['temperature_2m_max'] as List?) ?? const [];
    final lows = (rawDaily['temperature_2m_min'] as List?) ?? const [];
    final count = [dates.length, codes.length, highs.length, lows.length]
        .reduce((left, right) => left < right ? left : right);

    return List<WeatherForecastDay>.generate(count, (index) {
      final code = (codes[index] as num?)?.toInt() ?? -1;
      final condition = _conditionFor(code);
      return WeatherForecastDay(
        date: DateTime.tryParse(dates[index]) ?? DateTime.now(),
        minTempC: _number(lows[index]),
        maxTempC: _number(highs[index]),
        description: condition,
        condition: condition,
      );
    }, growable: false);
  }

  static double _number(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  static double _celsiusToFahrenheit(double celsius) => celsius * 9 / 5 + 32;

  static String _conditionFor(int code) {
    if (code == 0) return 'Clear sky';
    if (code <= 3) return 'Partly cloudy';
    if (code <= 48) return 'Fog';
    if (code <= 57) return 'Drizzle';
    if (code <= 67) return 'Rain';
    if (code <= 77) return 'Snow';
    if (code <= 82) return 'Rain showers';
    if (code <= 86) return 'Snow showers';
    return 'Thunderstorm';
  }

  static void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WeatherApiException(response.statusCode);
    }
  }
}

class WeatherProviderException implements Exception {
  const WeatherProviderException(this.message);

  final String message;
}

class WeatherApiException implements Exception {
  const WeatherApiException(this.statusCode);

  final int statusCode;
}
