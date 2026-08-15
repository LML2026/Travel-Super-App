import 'journey_context.dart';
import 'journey_insight.dart';

abstract interface class JourneyAnalyzer {
  List<JourneyInsight> analyze(JourneyContext context);
}
