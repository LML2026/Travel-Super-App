import 'dart:collection';

import '../../features/trips/models/itinerary/itinerary_item.dart';
import '../../features/trips/models/trip.dart';
import '../services/trip_overview_service.dart';
import 'journey_clock.dart';

class JourneyContext {
  final Trip trip;
  final List<ItineraryItem> orderedItems;
  final DateTime clock;
  final JourneyClockSource clockSource;
  final TripOverviewStatus tripStatus;
  final int? daysUntilStart;
  final int bookedCount;
  final int mappedCount;
  final int missingCoordinateCount;
  final double knownEstimatedCost;
  final bool hasKnownEstimatedCost;
  final bool isEstimatedCostComplete;
  final ItineraryItem? nextScheduledItem;

  JourneyContext({
    required this.trip,
    required List<ItineraryItem> orderedItems,
    required this.clock,
    required this.clockSource,
    required this.tripStatus,
    required this.daysUntilStart,
    required this.bookedCount,
    required this.mappedCount,
    required this.missingCoordinateCount,
    required this.knownEstimatedCost,
    required this.hasKnownEstimatedCost,
    required this.isEstimatedCostComplete,
    required this.nextScheduledItem,
  }) : orderedItems = UnmodifiableListView(List.of(orderedItems));
}
