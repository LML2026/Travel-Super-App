import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/models/booking.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/user_facing_error.dart';
import '../providers/trip_bookings_provider.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class TripBookingsPage extends ConsumerWidget {
  final String tripId;

  const TripBookingsPage({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedBookings = ref.watch(groupedTripBookingsProvider(tripId));
    final bookingsAsync = ref.watch(tripBookingsProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.ui('confirmedBookings')),
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const _EmptyBookingsView();
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (groupedBookings.containsKey(BookingType.flight))
                _BookingSection(
                  title: 'Flights',
                  icon: Icons.flight_takeoff,
                  bookings: groupedBookings[BookingType.flight]!,
                ),
              if (groupedBookings.containsKey(BookingType.hotel))
                _BookingSection(
                  title: 'Hotels',
                  icon: Icons.hotel,
                  bookings: groupedBookings[BookingType.hotel]!,
                ),
              if (groupedBookings.containsKey(BookingType.transport))
                _BookingSection(
                  title: 'Transport',
                  icon: Icons.local_taxi,
                  bookings: groupedBookings[BookingType.transport]!,
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(UserFacingError.message(
            error,
            fallback: 'Bookings are unavailable right now.',
          )),
        ),
      ),
    );
  }
}

class _BookingSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Booking> bookings;

  const _BookingSection({
    required this.title,
    required this.icon,
    required this.bookings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.navy),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title.toUpperCase(),
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        ...bookings.map((booking) => _BookingCard(booking: booking)),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(name: booking.currency);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 0,
      color: AppColors.cardSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        onTap: () => context.pushConfirmedBookingDetails(booking),
        title: Text(
          _getTitle(),
          style: AppTextStyles.body.copyWith(
            color: AppColors.textNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Text(_getSubtitle(), style: AppTextStyles.bodyMuted),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Booked on ${dateFormat.format(booking.createdAt)}',
              style: AppTextStyles.label,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(booking.amount),
              style: AppTextStyles.price.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            _StatusChip(status: booking.status),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (booking.type) {
      case BookingType.flight:
        return '${booking.metadata['airline']} ${booking.metadata['flightNumber']}';
      case BookingType.hotel:
        return booking.metadata['hotelName'] ?? 'Hotel Booking';
      case BookingType.transport:
        return booking.metadata['providerName'] ?? 'Transport Booking';
    }
  }

  String _getSubtitle() {
    switch (booking.type) {
      case BookingType.flight:
        return '${booking.metadata['departure']} → ${booking.metadata['arrival']}';
      case BookingType.hotel:
        return booking.metadata['roomType'] ?? booking.metadata['city'] ?? '';
      case BookingType.transport:
        return '${booking.metadata['pickup']} → ${booking.metadata['destination']}';
    }
  }
}

class _StatusChip extends StatelessWidget {
  final BookingStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case BookingStatus.confirmed:
        color = AppColors.success;
        break;
      case BookingStatus.pending:
        color = AppColors.warning;
        break;
      case BookingStatus.cancelled:
      case BookingStatus.failed:
        color = AppColors.error;
        break;
      case BookingStatus.completed:
        color = AppColors.info;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EmptyBookingsView extends StatelessWidget {
  const _EmptyBookingsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_online_outlined,
                size: 80, color: AppColors.navy),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No bookings confirmed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textNavy,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Once you confirm a flight, hotel, or transport, it will appear here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted,
            ),
          ],
        ),
      ),
    );
  }
}
