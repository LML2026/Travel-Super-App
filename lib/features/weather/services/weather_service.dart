import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/api_config.dart';
import '../models/weather_data.dart';

class WeatherService {
  static const String _backendUrl = '$apiBaseUrl/api/weather';

  Future<WeatherData> getWeather(String city) async {
    final response = await http.get(
      Uri.parse('$_backendUrl?city=${Uri.encodeComponent(city)}'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherData.fromJson(json);
    } else {
      throw Exception('Failed to load weather: ${response.body}');
    }
  }
}
