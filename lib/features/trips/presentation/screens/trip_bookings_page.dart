import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/models/booking.dart';
import '../../../../core/utils/user_facing_error.dart';
import '../providers/trip_bookings_provider.dart';

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
        title: const Text('Confirmed Bookings'),
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const _EmptyBookingsView();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
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
              Icon(icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey,
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
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => context.pushConfirmedBookingDetails(booking),
        title: Text(
          _getTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(_getSubtitle()),
            const SizedBox(height: 4),
            Text(
              'Booked on ${dateFormat.format(booking.createdAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(booking.amount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),
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
        color = Colors.green;
        break;
      case BookingStatus.pending:
        color = Colors.orange;
        break;
      case BookingStatus.cancelled:
      case BookingStatus.failed:
        color = Colors.red;
        break;
      case BookingStatus.completed:
        color = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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
            const Icon(Icons.book_online_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              'No bookings confirmed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              'Once you confirm a flight, hotel, or transport, it will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
