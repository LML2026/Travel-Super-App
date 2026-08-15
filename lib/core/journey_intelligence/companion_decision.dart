import 'dart:collection';

import 'journey_insight.dart';
import 'journey_relevance_engine.dart';

enum CompanionMode { silent, helpful, proactive }

enum JourneyInsightSuppressionReason {
  companionDisabled,
  unknownConfidence,
  dismissed,
  cooldown,
  duplicate,
  noUsefulContent,
}

enum CompanionDecisionReason {
  noInsights,
  companionDisabled,
  allSuppressed,
  helpfulDefault,
  proactiveEligible,
  proactiveDisabled,
  proactiveInsufficientEvidence,
  proactiveNoValidAction,
  proactiveMissingConsequence,
  proactiveMissingTemporalRelevance,
}

class SuppressedJourneyInsight {
  final JourneyInsight insight;
  final JourneyInsightSuppressionReason reason;

  const SuppressedJourneyInsight({required this.insight, required this.reason});
}

class CompanionDecision {
  final CompanionMode mode;
  final RankedJourneyInsight? primary;
  final List<RankedJourneyInsight> secondary;
  final List<SuppressedJourneyInsight> suppressed;
  final CompanionDecisionReason reason;

  CompanionDecision({
    required this.mode,
    required this.primary,
    List<RankedJourneyInsight> secondary = const [],
    List<SuppressedJourneyInsight> suppressed = const [],
    required this.reason,
  }) : secondary = UnmodifiableListView(List.of(secondary)),
       suppressed = UnmodifiableListView(List.of(suppressed));
}
