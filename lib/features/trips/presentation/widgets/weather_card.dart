import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../weather/providers/weather_provider.dart';
import '../../../weather/models/weather_data.dart';
import 'dashboard_section.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

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
      loading: () => Text(context.ui('loadingWeather')),
      error: (_, __) => Text(context.ui('weatherCurrentlyUnavailable')),
      data: (weather) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${weather.tempC.toStringAsFixed(0)}°C • ${weather.description}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textNavy,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _sourceLabel(weather.dataSource),
            style: AppTextStyles.label.copyWith(
              color: weather.dataSource == WeatherDataSource.demo
                  ? AppColors.warning
                  : AppColors.textMuted,
            ),
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
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
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
