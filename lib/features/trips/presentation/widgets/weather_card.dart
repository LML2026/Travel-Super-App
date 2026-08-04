import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../weather/providers/weather_provider.dart';
import 'dashboard_section.dart';

class WeatherCard extends ConsumerWidget {
  const WeatherCard({super.key, required this.destination, this.onTap});

  final String destination;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider(destination));

    final content = weatherAsync.when<Widget>(
      loading: () => const Text('Loading weather...'),
      error: (_, __) => const Text('Unable to load weather'),
      data: (forecast) => Text(
        '${forecast.tempC.toStringAsFixed(0)}°C • ${forecast.description}',
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
}
