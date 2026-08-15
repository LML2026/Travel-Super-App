import 'companion_policy_context.dart';
import 'journey_insight.dart';

class JourneyRelevanceFactors {
  final int confidence;
  final int actionability;
  final int consequence;
  final int temporalProximity;
  final int repetitionPenalty;

  const JourneyRelevanceFactors({
    required this.confidence,
    required this.actionability,
    required this.consequence,
    required this.temporalProximity,
    required this.repetitionPenalty,
  });

  int get score =>
      confidence +
      actionability +
      consequence +
      temporalProximity -
      repetitionPenalty;
}

class RankedJourneyInsight {
  final JourneyInsight insight;
  final List<JourneyActionType> actions;
  final JourneyRelevanceFactors factors;
  final int originalIndex;

  const RankedJourneyInsight({
    required this.insight,
    required this.actions,
    required this.factors,
    required this.originalIndex,
  });
}

class JourneyRelevanceEngine {
  const JourneyRelevanceEngine._();

  static List<RankedJourneyInsight> rank({
    required Iterable<RankedJourneyInsight> candidates,
    required CompanionPolicyContext context,
  }) {
    final ranked = candidates.toList()
      ..sort((first, second) {
        final scoreComparison = second.factors.score.compareTo(
          first.factors.score,
        );
        if (scoreComparison != 0) return scoreComparison;
        return first.originalIndex.compareTo(second.originalIndex);
      });

    return List.unmodifiable(ranked);
  }

  static JourneyRelevanceFactors factorsFor({
    required JourneyInsight insight,
    required List<JourneyActionType> actions,
    required CompanionPolicyContext context,
  }) {
    final isMaterial = context.materialConsequenceInsightIds.contains(
      insight.id,
    );
    final isTemporal = context.temporallyRelevantInsightIds.contains(
      insight.id,
    );
    final repetitionCount = context.repetitionCounts[insight.id] ?? 0;

    return JourneyRelevanceFactors(
      confidence: switch (insight.confidence) {
        JourneyInsightConfidence.confirmed => 40,
        JourneyInsightConfidence.high => 30,
        JourneyInsightConfidence.unknown => 0,
      },
      actionability: actions.isEmpty ? 0 : 15,
      consequence: isMaterial ? 15 : _defaultConsequence(insight),
      temporalProximity: isTemporal ? 10 : 0,
      repetitionPenalty: (repetitionCount * 5).clamp(0, 15),
    );
  }

  static int _defaultConsequence(JourneyInsight insight) {
    if (insight.severity == JourneyInsightSeverity.normal) return 8;
    return 0;
  }
}
