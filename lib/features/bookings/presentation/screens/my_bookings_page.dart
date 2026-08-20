import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/models/booking.dart';
import '../providers/my_bookings_provider.dart';

class MyBookingsPage extends ConsumerWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(myBookingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: bookings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('Bookings are unavailable right now. Please try again.'),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Your confirmed flights, stays and transport bookings will appear here.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final upcoming = items
              .where((item) => item.booking.status != BookingStatus.completed)
              .toList();
          final past = items
              .where((item) => item.booking.status == BookingStatus.completed)
              .toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (upcoming.isNotEmpty) ...[
                const _SectionTitle('Upcoming'),
                ...upcoming.map((item) => _BookingTile(item: item)),
              ],
              if (past.isNotEmpty) ...[
                const _SectionTitle('Past'),
                ...past.map((item) => _BookingTile(item: item)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 8),
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      );
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.item});
  final MyBooking item;

  @override
  Widget build(BuildContext context) {
    final booking = item.booking;
    return Card(
      child: ListTile(
        leading: Icon(_iconFor(booking.type)),
        title: Text(_titleFor(booking)),
        subtitle: Text(
            '${item.trip.destination} • ${_subtitleFor(booking)}\n${_sourceFor(booking)}'),
        isThreeLine: true,
        trailing: Chip(label: Text(booking.status.name)),
        onTap: () => context.pushConfirmedBookingDetails(booking),
      ),
    );
  }

  String _titleFor(Booking booking) {
    switch (booking.type) {
      case BookingType.flight:
        return '${booking.metadata['airline'] ?? 'Flight'} ${booking.metadata['flightNumber'] ?? ''}'
            .trim();
      case BookingType.hotel:
        return (booking.metadata['hotelName'] ??
                booking.metadata['name'] ??
                'Hotel')
            .toString();
      case BookingType.transport:
        return (booking.metadata['provider'] ??
                booking.metadata['providerName'] ??
                'Transport')
            .toString();
    }
  }

  String _subtitleFor(Booking booking) {
    final metadata = booking.metadata;
    switch (booking.type) {
      case BookingType.flight:
        return '${metadata['origin'] ?? metadata['departure'] ?? ''} -> ${metadata['destination'] ?? metadata['arrival'] ?? ''}';
      case BookingType.hotel:
        final start = metadata['startTime'] ?? metadata['checkIn'];
        return start is String
            ? DateFormat('dd MMM yyyy')
                .format(DateTime.tryParse(start) ?? booking.createdAt)
            : 'Accommodation';
      case BookingType.transport:
        return '${metadata['pickup'] ?? ''} -> ${metadata['destination'] ?? ''}';
    }
  }

  String _sourceFor(Booking booking) =>
      'Source: ${(booking.metadata['source'] ?? booking.metadata['provider'] ?? booking.metadata['providerName'] ?? 'ITAREVO booking').toString()}';

  IconData _iconFor(BookingType type) => switch (type) {
        BookingType.flight => Icons.flight_takeoff,
        BookingType.hotel => Icons.hotel_outlined,
        BookingType.transport => Icons.local_taxi_outlined,
      };
}
