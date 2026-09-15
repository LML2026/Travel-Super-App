import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/user_facing_error.dart';
import '../providers/hotel_provider.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class RecentHotelSearchesPage extends ConsumerWidget {
  const RecentHotelSearchesPage({super.key});

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day} ${_monthName(date.month)} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentSearchesAsync = ref.watch(recentHotelSearchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.ui('recentSearches')),
      ),
      body: recentSearchesAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.textSubtle,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(context.ui('failedLoadSearches')),
              const SizedBox(height: AppSpacing.sm),
              Text(
                UserFacingError.message(
                  error,
                  fallback: 'Recent searches are unavailable right now.',
                ),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (searches) {
          if (searches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search,
                    size: 64,
                    color: AppColors.textSubtle,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No recent searches',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your searches will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: searches.length,
            itemBuilder: (context, index) {
              final search = searches[index];
              final checkInDate = _formatDate(search.checkInDate);
              final nights = DateTime.parse(search.checkOutDate)
                  .difference(DateTime.parse(search.checkInDate))
                  .inDays;

              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.lg),
                  leading: const Icon(Icons.hotel, color: AppColors.navy600),
                  title: Text(
                    search.city,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      Text(checkInDate),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                          '$nights nights • ${search.guests} Guest${search.guests > 1 ? 's' : ''} • ${search.rooms} Room${search.rooms > 1 ? 's' : ''}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text(context.ui('delete')),
                        onTap: () {
                          ref.read(deleteRecentHotelSearchProvider(search.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.ui('searchDeleted'))),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    context.pushHotels();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
