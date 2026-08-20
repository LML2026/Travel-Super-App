import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../weather/providers/weather_provider.dart';
import '../../../weather/models/weather_data.dart';
import 'dashboard_section.dart';

class WeatherCard extends ConsumerWidget {
  const WeatherCard({
    super.key,
    required this.destination,
    this.onTap,
  });

  final String destination;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider(destination));

    final content = weatherAsync.when<Widget>(
      loading: () => const Text('Loading weather...'),
      error: (_, __) => const Text('Weather currently unavailable'),
      data: (weather) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              '${weather.tempC.toStringAsFixed(0)}°C • ${weather.description}'),
          const SizedBox(height: 2),
          Text(
            _sourceLabel(weather.dataSource),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );

    return DashboardSection(
      icon: Icons.wb_sunny_outlined,
      title: 'Weather',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: content,
        ),
      ),
    );
  }

  String _sourceLabel(WeatherDataSource source) {
    switch (source) {
      case WeatherDataSource.openMeteo:
        return 'Live weather';
      case WeatherDataSource.backend:
        return 'Backend weather';
      case WeatherDataSource.demo:
        return 'Demo weather';
    }
  }
}
