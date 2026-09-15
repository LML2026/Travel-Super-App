import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../flights/models/saved_flight.dart';
import '../providers/trip_dashboard_provider.dart';
import 'dashboard_section.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class FlightCard extends ConsumerWidget {
  const FlightCard({
    super.key,
    required this.tripId,
    this.onOpenFlights,
    this.onViewFlightDetails,
    this.onLinkFlight,
    this.onUnlinkFlight,
  });

  final String tripId;
  final VoidCallback? onOpenFlights;
  final ValueChanged<SavedFlight>? onViewFlightDetails;
  final VoidCallback? onLinkFlight;
  final VoidCallback? onUnlinkFlight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkedFlightAsync = ref.watch(tripFlightsProvider(tripId));
    final linkedFlight = linkedFlightAsync.valueOrNull;
    final hasFlight = linkedFlight != null;

    Widget details;
    if (linkedFlightAsync.isLoading) {
      details = Text(context.ui('loadingFlight'));
    } else if (linkedFlightAsync.hasError) {
      details = Text(context.ui('unableLoadFlight'));
    } else if (linkedFlight == null) {
      details = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.ui('noFlightAdded')),
          const SizedBox(height: 2),
          Text(context.ui('tapAttachFlight')),
        ],
      );
    } else {
      details = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${linkedFlight.airline} ${linkedFlight.flightNumber}',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${linkedFlight.origin} → ${linkedFlight.destination}',
            style: AppTextStyles.bodyMuted,
          ),
          Text(
            '${_formatFlightTime(linkedFlight.departureAt)} → ${_formatFlightTime(linkedFlight.arrivalAt)}',
            style: AppTextStyles.bodyMuted,
          ),
        ],
      );
    }

    return DashboardSection(
      icon: Icons.flight_takeoff,
      title: 'Flights',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          details,
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              OutlinedButton(
                onPressed: onOpenFlights,
                child: Text(context.ui('openFlights')),
              ),
              if (hasFlight)
                OutlinedButton(
                  onPressed: () => onViewFlightDetails?.call(linkedFlight),
                  child: Text(context.ui('viewDetails')),
                ),
              if (hasFlight)
                OutlinedButton(
                  onPressed: onUnlinkFlight,
                  child: Text(context.ui('unlink')),
                )
              else
                FilledButton(
                  onPressed: onLinkFlight,
                  child: Text(context.ui('linkFlight')),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatFlightTime(String dateTime) {
    final parsed = DateTime.tryParse(dateTime);
    if (parsed == null) {
      return dateTime;
    }

    return DateFormat('HH:mm').format(parsed);
  }
}
