import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../hotels/models/saved_hotel.dart';
import '../providers/trip_dashboard_provider.dart';
import 'dashboard_section.dart';

class HotelCard extends ConsumerWidget {
  const HotelCard({
    super.key,
    required this.tripId,
    required this.checkInDate,
    required this.checkOutDate,
    this.onOpenHotels,
    this.onViewHotelDetails,
    this.onLinkHotel,
    this.onUnlinkHotel,
  });

  final String tripId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final VoidCallback? onOpenHotels;
  final ValueChanged<SavedHotel>? onViewHotelDetails;
  final VoidCallback? onLinkHotel;
  final VoidCallback? onUnlinkHotel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkedHotelAsync = ref.watch(tripHotelProvider(tripId));
    final linkedHotel = linkedHotelAsync.valueOrNull;
    final hasHotel = linkedHotel != null;
    final dateFormatter = DateFormat('dd MMM yyyy');

    Widget details;
    if (linkedHotelAsync.isLoading) {
      details = const Text('Loading hotel...');
    } else if (linkedHotelAsync.hasError) {
      details = const Text('Unable to load hotel');
    } else if (linkedHotel == null) {
      details = const Text('No hotel linked yet. Tap to add one.');
    } else {
      details = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            linkedHotel.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Rating: ${linkedHotel.rating.toStringAsFixed(1)} ★'),
          Text(_hotelAddress(linkedHotel)),
          Text(
            'Check-in ${dateFormatter.format(checkInDate)} • Check-out ${dateFormatter.format(checkOutDate)}',
          ),
        ],
      );
    }

    return DashboardSection(
      icon: Icons.hotel,
      title: 'Hotel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          details,
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: onOpenHotels,
                child: const Text('Open Hotels'),
              ),
              if (hasHotel)
                OutlinedButton(
                  onPressed: () => onViewHotelDetails?.call(linkedHotel),
                  child: const Text('View Details'),
                ),
              if (!hasHotel)
                FilledButton(
                  onPressed: onLinkHotel,
                  child: const Text('Link Hotel'),
                )
              else
                OutlinedButton(
                  onPressed: onUnlinkHotel,
                  child: const Text('Unlink'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _hotelAddress(SavedHotel hotel) {
    if (hotel.address.isNotEmpty) {
      return hotel.address;
    }

    if (hotel.country.isNotEmpty) {
      return '${hotel.city}, ${hotel.country}';
    }

    return hotel.city;
  }
}
