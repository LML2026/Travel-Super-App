import '../journey_analyzer.dart';
import '../journey_context.dart';
import '../journey_insight.dart';

class BudgetEstimateAnalyzer implements JourneyAnalyzer {
  const BudgetEstimateAnalyzer();

  @override
  List<JourneyInsight> analyze(JourneyContext context) {
    if (!context.hasKnownEstimatedCost) return const [];

    final supportingData = {
      'currency': context.trip.currency,
      'knownEstimatedCost': context.knownEstimatedCost,
      'isComplete': context.isEstimatedCostComplete,
    };
    final overBudget =
        context.trip.budget > 0 &&
        context.knownEstimatedCost > context.trip.budget;

    if (overBudget) {
      return [
        JourneyInsight(
          id: 'budget:${context.trip.id}:known-estimates-over-budget',
          type: JourneyInsightType.attention,
          message: JourneyInsightMessage.knownEstimatesOverBudget,
          supportingData: {
            ...supportingData,
            'budget': context.trip.budget,
            'overBudget': context.knownEstimatedCost - context.trip.budget,
          },
          severity: JourneyInsightSeverity.normal,
          confidence: JourneyInsightConfidence.high,
          source: 'budget_estimates',
          actions: const [JourneyActionType.openTrip],
        ),
      ];
    }

    return [
      JourneyInsight(
        id: 'budget:${context.trip.id}:known-estimated-cost',
        type: JourneyInsightType.information,
        message: JourneyInsightMessage.knownEstimatedCost,
        supportingData: supportingData,
        severity: JourneyInsightSeverity.low,
        confidence: JourneyInsightConfidence.confirmed,
        source: 'budget_estimates',
        actions: const [JourneyActionType.openTrip],
      ),
    ];
  }
}
