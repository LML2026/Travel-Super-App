import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../hotels/models/saved_hotel.dart';
import '../providers/trip_dashboard_provider.dart';
import 'dashboard_section.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

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
      details = Text(context.ui('loadingHotel'));
    } else if (linkedHotelAsync.hasError) {
      details = Text(context.ui('unableLoadHotel'));
    } else if (linkedHotel == null) {
      details = Text(context.ui('noHotelLinkedTap'));
    } else {
      details = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            linkedHotel.name,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Rating: ${linkedHotel.rating.toStringAsFixed(1)} ★',
            style: AppTextStyles.bodyMuted,
          ),
          Text(_hotelAddress(linkedHotel), style: AppTextStyles.bodyMuted),
          Text(
            'Check-in ${dateFormatter.format(checkInDate)} • Check-out ${dateFormatter.format(checkOutDate)}',
            style: AppTextStyles.bodyMuted,
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
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              OutlinedButton(
                onPressed: onOpenHotels,
                child: Text(context.ui('openHotels')),
              ),
              if (hasHotel)
                OutlinedButton(
                  onPressed: () => onViewHotelDetails?.call(linkedHotel),
                  child: Text(context.ui('viewDetails')),
                ),
              if (!hasHotel)
                FilledButton(
                  onPressed: onLinkHotel,
                  child: Text(context.ui('linkHotel')),
                )
              else
                OutlinedButton(
                  onPressed: onUnlinkHotel,
                  child: Text(context.ui('unlink')),
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
