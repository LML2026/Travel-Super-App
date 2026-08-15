import '../../../features/trips/models/itinerary/itinerary_item.dart';
import '../journey_analyzer.dart';
import '../journey_context.dart';
import '../journey_insight.dart';

class ItinerarySummaryAnalyzer implements JourneyAnalyzer {
  const ItinerarySummaryAnalyzer();

  @override
  List<JourneyInsight> analyze(JourneyContext context) {
    final insights = <JourneyInsight>[
      JourneyInsight(
        id: 'itinerary-summary:${context.trip.id}:planned-stops',
        type: JourneyInsightType.information,
        message: JourneyInsightMessage.plannedStopCount,
        supportingData: {'count': context.orderedItems.length},
        severity: JourneyInsightSeverity.low,
        confidence: JourneyInsightConfidence.confirmed,
        source: 'itinerary_summary',
        actions: const [JourneyActionType.openItinerary],
      ),
    ];
    ItineraryItem? firstScheduled;
    for (final item in context.orderedItems) {
      if (_hasValidTime(item)) {
        firstScheduled = item;
        break;
      }
    }

    if (firstScheduled != null) {
      insights.add(
        JourneyInsight(
          id: 'itinerary-summary:${context.trip.id}:first-scheduled-stop',
          type: JourneyInsightType.information,
          message: JourneyInsightMessage.firstScheduledStop,
          supportingData: {
            'itemId': firstScheduled.id,
            'title': firstScheduled.title,
            'date': firstScheduled.date,
            'time': firstScheduled.time!,
          },
          severity: JourneyInsightSeverity.low,
          confidence: JourneyInsightConfidence.high,
          source: 'itinerary_summary',
          actions: const [JourneyActionType.reviewStop],
        ),
      );
    }

    return insights;
  }

  bool _hasValidTime(ItineraryItem item) {
    final value = item.time;
    if (value == null) return false;

    final parts = value.split(':');
    if (parts.length != 2) return false;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    return hour != null && minute != null && hour <= 23 && minute <= 59;
  }
}
