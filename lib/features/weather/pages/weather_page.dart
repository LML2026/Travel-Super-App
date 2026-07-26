import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_provider.dart';
import '../models/weather_data.dart';

class WeatherPage extends ConsumerStatefulWidget {
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage> {
  final _cityController = TextEditingController(text: 'London');
  String _searchCity = 'London';

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(weatherProvider(_searchCity));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      hintText: 'e.g. Paris',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) {
                        setState(() => _searchCity = v.trim());
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    final city = _cityController.text.trim();
                    if (city.isNotEmpty) setState(() => _searchCity = city);
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            weatherAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorCard(message: e.toString()),
              data: (weather) => _WeatherCard(weather: weather),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final WeatherData weather;
  const _WeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '${weather.city}, ${weather.country}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              weather.emoji,
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 8),
            Text(
              '${weather.tempC.toStringAsFixed(0)}°C',
              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
            ),
            Text(
              weather.description,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(label: 'Humidity', value: '${weather.humidity}%', icon: Icons.water_drop),
                _Stat(label: 'Wind', value: '${weather.windKph.toStringAsFixed(0)} km/h', icon: Icons.air),
                _Stat(label: 'Feels like', value: '${weather.tempF.toStringAsFixed(0)}°F', icon: Icons.thermostat),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _Stat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}
