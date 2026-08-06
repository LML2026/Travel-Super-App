import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_routes.dart';
import '../providers/hotel_provider.dart';

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
        title: const Text('Recent Searches'),
      ),
      body: recentSearchesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Failed to load searches'),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                  Icon(Icons.search, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No recent searches',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your searches will appear here',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: searches.length,
            itemBuilder: (context, index) {
              final search = searches[index];
              final checkInDate = _formatDate(search.checkInDate);
              final nights = DateTime.parse(search.checkOutDate)
                  .difference(DateTime.parse(search.checkInDate))
                  .inDays;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.hotel, color: Color(0xFF1976D2)),
                  title: Text(
                    search.city,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(checkInDate),
                      const SizedBox(height: 4),
                      Text(
                          '$nights nights • ${search.guests} Guest${search.guests > 1 ? 's' : ''} • ${search.rooms} Room${search.rooms > 1 ? 's' : ''}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Delete'),
                        onTap: () {
                          ref.read(deleteRecentHotelSearchProvider(search.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Search deleted')),
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
