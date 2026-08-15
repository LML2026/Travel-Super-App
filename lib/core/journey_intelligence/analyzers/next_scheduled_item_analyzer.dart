import '../journey_analyzer.dart';
import '../journey_context.dart';
import '../journey_insight.dart';

class NextScheduledItemAnalyzer implements JourneyAnalyzer {
  const NextScheduledItemAnalyzer();

  @override
  List<JourneyInsight> analyze(JourneyContext context) {
    final item = context.nextScheduledItem;
    if (item == null) return const [];

    return [
      JourneyInsight(
        id: 'next-scheduled-stop:${context.trip.id}:${item.id}',
        type: JourneyInsightType.information,
        message: JourneyInsightMessage.nextScheduledStop,
        supportingData: {
          'itemId': item.id,
          'title': item.title,
          'date': item.date,
          'time': item.time!,
        },
        severity: JourneyInsightSeverity.low,
        confidence: JourneyInsightConfidence.high,
        source: 'next_scheduled_item',
        actions: const [JourneyActionType.reviewStop],
      ),
    ];
  }
}
