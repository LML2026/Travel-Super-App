import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/models/booking.dart';
import '../providers/trip_bookings_provider.dart';
import '../../../../core/utils/user_facing_error.dart';

class BookingsCard extends ConsumerWidget {
  final String tripId;

  const BookingsCard({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(tripBookingsProvider(tripId));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => context.pushTripBookings(tripId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bookings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              bookingsAsync.when(
                data: (bookings) {
                  if (bookings.isEmpty) {
                    return const Text(
                      'No saved booking plans yet. Search for flights or hotels to add one.',
                      style: TextStyle(color: Colors.grey),
                    );
                  }

                  return Row(
                    children: [
                      _BookingBadge(
                        icon: Icons.flight_takeoff,
                        count: bookings.where((b) => b.type == BookingType.flight).length,
                        label: 'Flights',
                      ),
                      const SizedBox(width: 16),
                      _BookingBadge(
                        icon: Icons.hotel,
                        count: bookings.where((b) => b.type == BookingType.hotel).length,
                        label: 'Hotels',
                      ),
                      const SizedBox(width: 16),
                      _BookingBadge(
                        icon: Icons.local_taxi,
                        count: bookings.where((b) => b.type == BookingType.transport).length,
                        label: 'Transport',
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: LinearProgressIndicator()),
                error: (error, _) => Text(
                  UserFacingError.message(
                    error,
                    fallback: 'Bookings are unavailable right now.',
                  ),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;

  const _BookingBadge({
    required this.icon,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final color = count > 0 ? Theme.of(context).primaryColor : Colors.grey;

    return Column(
      children: [
        Badge(
          label: Text(count.toString()),
          isLabelVisible: count > 0,
          backgroundColor: color,
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: count > 0 ? Colors.black87 : Colors.grey,
            fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
