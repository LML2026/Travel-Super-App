import '../../services/trip_overview_service.dart';
import '../journey_analyzer.dart';
import '../journey_context.dart';
import '../journey_insight.dart';

class TripStatusAnalyzer implements JourneyAnalyzer {
  const TripStatusAnalyzer();

  @override
  List<JourneyInsight> analyze(JourneyContext context) {
    switch (context.tripStatus) {
      case TripOverviewStatus.upcoming:
        return [
          JourneyInsight(
            id: 'trip-status:${context.trip.id}:upcoming',
            type: JourneyInsightType.information,
            message: JourneyInsightMessage.tripUpcoming,
            supportingData: {
              'destination': context.trip.destination,
              'daysUntilStart': context.daysUntilStart,
            },
            severity: JourneyInsightSeverity.low,
            confidence: JourneyInsightConfidence.confirmed,
            source: 'trip_status',
            actions: const [JourneyActionType.openTrip],
          ),
        ];
      case TripOverviewStatus.inProgress:
        return [
          JourneyInsight(
            id: 'trip-status:${context.trip.id}:active',
            type: JourneyInsightType.information,
            message: JourneyInsightMessage.tripActive,
            supportingData: {'destination': context.trip.destination},
            severity: JourneyInsightSeverity.low,
            confidence: JourneyInsightConfidence.confirmed,
            source: 'trip_status',
            actions: const [JourneyActionType.openTrip],
          ),
        ];
      case TripOverviewStatus.completed:
        return [
          JourneyInsight(
            id: 'trip-status:${context.trip.id}:date-range-complete',
            type: JourneyInsightType.information,
            message: JourneyInsightMessage.tripDateRangeComplete,
            supportingData: {'destination': context.trip.destination},
            severity: JourneyInsightSeverity.low,
            confidence: JourneyInsightConfidence.confirmed,
            source: 'trip_status',
            actions: const [JourneyActionType.openTrip],
          ),
        ];
    }
  }
}
