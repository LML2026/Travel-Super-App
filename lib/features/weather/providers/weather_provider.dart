import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/weather_service.dart';
import '../models/weather_data.dart';

final weatherServiceProvider = Provider<WeatherService>(
  (ref) => WeatherService(),
);

final weatherProvider = FutureProvider.family<WeatherData, String>((
  ref,
  city,
) async {
  return ref.read(weatherServiceProvider).getWeather(city);
});
