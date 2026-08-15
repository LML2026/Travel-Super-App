import '../journey_analyzer.dart';
import '../journey_context.dart';
import '../journey_insight.dart';

class BookingFlagAnalyzer implements JourneyAnalyzer {
  const BookingFlagAnalyzer();

  @override
  List<JourneyInsight> analyze(JourneyContext context) {
    if (context.bookedCount == 0) return const [];

    return [
      JourneyInsight(
        id: 'booking-flags:${context.trip.id}:marked-booked',
        type: JourneyInsightType.information,
        message: JourneyInsightMessage.markedBookedCount,
        supportingData: {'count': context.bookedCount},
        severity: JourneyInsightSeverity.low,
        confidence: JourneyInsightConfidence.confirmed,
        source: 'booking_flags',
        actions: const [JourneyActionType.openItinerary],
      ),
    ];
  }
}
