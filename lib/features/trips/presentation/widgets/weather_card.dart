import 'package:flutter/material.dart';

import 'dashboard_section.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({
    super.key,
    this.temperatureC,
    this.condition,
    this.isLoading = false,
    this.errorText,
  });

  final double? temperatureC;
  final String? condition;
  final bool isLoading;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (isLoading) {
      content = const Text('Loading weather...');
    } else if (errorText != null) {
      content = Text(errorText!);
    } else if (temperatureC != null && condition != null) {
      content = Text('${temperatureC!.toStringAsFixed(0)}°C • $condition');
    } else {
      content = const Text('No weather data yet.');
    }

    return DashboardSection(
      icon: Icons.wb_sunny_outlined,
      title: 'Weather',
      child: content,
    );
  }
}
