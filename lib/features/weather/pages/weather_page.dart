import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/weather_provider.dart';
import '../models/weather_data.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

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
        title: Text(context.ui('weather')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AppInputField(
                    controller: _cityController,
                    label: 'City',
                    hint: 'e.g. Paris',
                    prefixIcon: Icons.location_city,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                AppPrimaryButton(
                  onPressed: () {
                    final city = _cityController.text.trim();
                    if (city.isNotEmpty) setState(() => _searchCity = city);
                  },
                  icon: Icons.search,
                  label: context.ui('search'),
                  expand: false,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            weatherAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppEmptyState(
                icon: Icons.error_outline,
                title: 'Weather unavailable',
                message: 'We could not load weather for this destination.',
                iconColor: AppColors.error,
              ),
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
    return AppCard(
      elevation: 2,
      child: Column(
        children: [
          Text(
            '${weather.city}, ${weather.country}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            weather.emoji,
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${weather.tempC.toStringAsFixed(0)}°C',
            style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
          ),
          Text(
            weather.description,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _sourceLabel(weather.dataSource),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(
                label: 'Humidity',
                value: '${weather.humidity}%',
                icon: Icons.water_drop,
              ),
              _Stat(
                label: 'Wind',
                value: '${weather.windKph.toStringAsFixed(0)} km/h',
                icon: Icons.air,
              ),
              _Stat(
                label: 'Feels like',
                value: '${weather.tempF.toStringAsFixed(0)}°F',
                icon: Icons.thermostat,
              ),
            ],
          ),
          if (weather.forecast.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '3-day forecast',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weather.forecast.take(3).map((day) {
                return Column(
                  children: [
                    Text(_dayLabel(day.date)),
                    Text(day.emoji, style: const TextStyle(fontSize: 22)),
                    Text(
                      '${day.maxTempC.toStringAsFixed(0)}° / ${day.minTempC.toStringAsFixed(0)}°',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _dayLabel(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

  String _sourceLabel(WeatherDataSource source) {
    switch (source) {
      case WeatherDataSource.openMeteo:
        return 'Live weather from Open-Meteo';
      case WeatherDataSource.backend:
        return 'Backend weather';
      case WeatherDataSource.demo:
        return 'Demo weather';
    }
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
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: AppSpacing.xs),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}
