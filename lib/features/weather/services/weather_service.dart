import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/weather_data.dart';
import 'open_meteo_weather_service.dart';

class WeatherService {
  WeatherService({
    ApiClient? apiClient,
    OpenMeteoWeatherService? openMeteoService,
    Future<WeatherData> Function(String city)? liveWeather,
    Future<WeatherData> Function(String city)? backendWeather,
  })  : _apiClient = apiClient ?? ApiClient(),
        _openMeteoService = openMeteoService ?? OpenMeteoWeatherService(),
        _liveWeather = liveWeather,
        _backendWeather = backendWeather;

  final ApiClient _apiClient;
  final OpenMeteoWeatherService _openMeteoService;
  final Future<WeatherData> Function(String city)? _liveWeather;
  final Future<WeatherData> Function(String city)? _backendWeather;

  Future<WeatherData> getWeather(String city) async {
    try {
      return await (_liveWeather?.call(city) ??
          _openMeteoService.getWeather(city));
    } catch (_) {
      // Continue to the existing backend and deterministic local fallback.
    }

    try {
      final weather =
          await (_backendWeather?.call(city) ?? _getBackendWeather(city));
      return weather;
    } catch (_) {
      return _demoWeather(city);
    }
  }

  Future<WeatherData> _getBackendWeather(String city) async {
    final response = await _apiClient.get(
      ApiEndpoints.weather,
      queryParameters: {'city': city},
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200 || response.data is! Map<String, dynamic>) {
      throw const WeatherSearchException();
    }
    return WeatherData.fromJson(
      response.data as Map<String, dynamic>,
      dataSource: WeatherDataSource.backend,
    );
  }

  WeatherData _demoWeather(String city) {
    final normalized = city.trim().toLowerCase();
    final preset = switch (normalized) {
      'london' => (13.0, 55, 14.0, 'Partly cloudy'),
      'paris' => (17.0, 62, 18.0, 'Clear sky'),
      'barcelona' => (22.0, 58, 23.0, 'Clear sky'),
      'rome' => (21.0, 52, 22.0, 'Clear sky'),
      'tokyo' => (19.0, 70, 20.0, 'Rain showers'),
      _ => (18.0, 60, 19.0, 'Partly cloudy'),
    };
    final description = preset.$4;
    return WeatherData(
      city: city,
      country: '',
      tempC: preset.$1,
      tempF: preset.$3 * 9 / 5 + 32,
      description: description,
      iconCode: 'demo',
      humidity: preset.$2,
      windKph: 12,
      condition: description,
      dataSource: WeatherDataSource.demo,
    );
  }
}

class WeatherSearchException implements Exception {
  const WeatherSearchException();
}
