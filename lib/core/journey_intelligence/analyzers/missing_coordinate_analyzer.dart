import '../journey_analyzer.dart';
import '../journey_context.dart';
import '../journey_insight.dart';

class MissingCoordinateAnalyzer implements JourneyAnalyzer {
  const MissingCoordinateAnalyzer();

  @override
  List<JourneyInsight> analyze(JourneyContext context) {
    if (context.missingCoordinateCount == 0) return const [];

    return [
      JourneyInsight(
        id: 'missing-coordinates:${context.trip.id}',
        type: JourneyInsightType.attention,
        message: JourneyInsightMessage.missingCoordinates,
        supportingData: {'count': context.missingCoordinateCount},
        severity: JourneyInsightSeverity.normal,
        confidence: JourneyInsightConfidence.confirmed,
        source: 'missing_coordinates',
        actions: const [JourneyActionType.openMap, JourneyActionType.editStop],
      ),
    ];
  }
}
