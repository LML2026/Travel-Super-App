import '../../features/trips/models/itinerary/itinerary_item.dart';
import '../../features/trips/models/trip.dart';
import '../services/trip_overview_service.dart';
import 'journey_clock.dart';
import 'journey_context.dart';

class JourneyContextBuilder {
  const JourneyContextBuilder._();

  static JourneyContext build({
    required Trip trip,
    required Iterable<ItineraryItem> items,
    required DateTime clock,
    JourneyClockSource clockSource = JourneyClockSource.unknown,
  }) {
    final itemList = List<ItineraryItem>.of(items);
    final overview = TripOverviewService.build(
      trip: trip,
      items: itemList,
      now: clock,
    );
    final missingCoordinateCount = overview.orderedItems
        .where((item) => item.latitude == null || item.longitude == null)
        .length;
    final estimatedCostItemCount = overview.orderedItems
        .where((item) => item.estimatedCost != null)
        .length;

    return JourneyContext(
      trip: trip,
      orderedItems: overview.orderedItems,
      clock: clock,
      clockSource: clockSource,
      tripStatus: overview.status,
      daysUntilStart: overview.daysUntilStart,
      bookedCount: overview.bookedCount,
      mappedCount: overview.mappedCount,
      missingCoordinateCount: missingCoordinateCount,
      knownEstimatedCost: overview.estimatedCost,
      hasKnownEstimatedCost: overview.hasEstimatedCost,
      isEstimatedCostComplete:
          estimatedCostItemCount == overview.orderedItems.length,
      nextScheduledItem:
          JourneyClock(
            value: clock,
            source: clockSource,
          ).isTrustedForItineraryLocalComparison
          ? _scheduledItemAtOrAfter(overview.nextPlan, clock)
          : null,
    );
  }

  static ItineraryItem? _scheduledItemAtOrAfter(
    ItineraryItem? item,
    DateTime clock,
  ) {
    if (item == null || item.time == null) return null;

    final parts = item.time!.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null || hour > 23 || minute > 59) {
      return null;
    }

    final scheduledAt = DateTime(
      item.date.year,
      item.date.month,
      item.date.day,
      hour,
      minute,
    );

    return scheduledAt.isBefore(clock) ? null : item;
  }
}
