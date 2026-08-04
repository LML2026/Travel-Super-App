import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/weather_data.dart';

class WeatherService {
  WeatherService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<WeatherData> getWeather(String city) async {
    final response = await _apiClient.get(
      ApiEndpoints.weather,
      queryParameters: {'city': city},
    );

    if (response.statusCode == 200) {
      final json = response.data as Map<String, dynamic>;
      return WeatherData.fromJson(json);
    } else {
      throw Exception('Failed to load weather: ${response.data}');
    }
  }
}
