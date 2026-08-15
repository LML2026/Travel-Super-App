import 'dart:collection';

enum JourneyInsightType { information, attention }

enum JourneyInsightSeverity { low, normal }

enum JourneyInsightConfidence { confirmed, high, unknown }

enum JourneyActionType {
  openTrip,
  openItinerary,
  openMap,
  reviewStop,
  editStop,
}

enum JourneyInsightMessage {
  tripUpcoming,
  tripActive,
  tripDateRangeComplete,
  plannedStopCount,
  firstScheduledStop,
  nextScheduledStop,
  missingCoordinates,
  markedBookedCount,
  knownEstimatedCost,
  knownEstimatesOverBudget,
}

class JourneyInsight {
  final String id;
  final JourneyInsightType type;
  final JourneyInsightMessage message;
  final Map<String, Object?> supportingData;
  final JourneyInsightSeverity severity;
  final JourneyInsightConfidence confidence;
  final String source;
  final List<JourneyActionType> actions;
  final bool proactiveEligible;

  JourneyInsight({
    required this.id,
    required this.type,
    required this.message,
    Map<String, Object?> supportingData = const {},
    required this.severity,
    required this.confidence,
    required this.source,
    List<JourneyActionType> actions = const [],
    this.proactiveEligible = false,
  }) : supportingData = UnmodifiableMapView(Map.of(supportingData)),
       actions = List.unmodifiable(actions);
}
