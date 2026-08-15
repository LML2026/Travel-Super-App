import 'companion_decision.dart';
import 'companion_policy_context.dart';
import 'journey_insight.dart';
import 'journey_relevance_engine.dart';

class CompanionPolicy {
  const CompanionPolicy._();

  static CompanionDecision decide({
    required List<JourneyInsight> insights,
    required CompanionPolicyContext context,
  }) {
    if (insights.isEmpty) {
      return CompanionDecision(
        mode: CompanionMode.silent,
        primary: null,
        reason: CompanionDecisionReason.noInsights,
      );
    }

    final suppressed = <SuppressedJourneyInsight>[];
    if (!context.companionEnabled) {
      suppressed.addAll(
        insights.map(
          (insight) => SuppressedJourneyInsight(
            insight: insight,
            reason: JourneyInsightSuppressionReason.companionDisabled,
          ),
        ),
      );
      return CompanionDecision(
        mode: CompanionMode.silent,
        primary: null,
        suppressed: suppressed,
        reason: CompanionDecisionReason.companionDisabled,
      );
    }

    final eligible = <RankedJourneyInsight>[];
    for (var index = 0; index < insights.length; index++) {
      final insight = insights[index];
      final suppression = _suppressionFor(insight, context);
      if (suppression != null) {
        suppressed.add(
          SuppressedJourneyInsight(insight: insight, reason: suppression),
        );
        continue;
      }

      final actions = insight.actions
          .where(context.availableActions.contains)
          .toList(growable: false);
      if (actions.isEmpty && !_isMateriallyUseful(insight)) {
        suppressed.add(
          SuppressedJourneyInsight(
            insight: insight,
            reason: JourneyInsightSuppressionReason.noUsefulContent,
          ),
        );
        continue;
      }

      eligible.add(
        RankedJourneyInsight(
          insight: insight,
          actions: actions,
          factors: JourneyRelevanceEngine.factorsFor(
            insight: insight,
            actions: actions,
            context: context,
          ),
          originalIndex: index,
        ),
      );
    }

    final deduplicated = _deduplicate(eligible, suppressed);
    final ranked = JourneyRelevanceEngine.rank(
      candidates: deduplicated,
      context: context,
    );
    if (ranked.isEmpty) {
      return CompanionDecision(
        mode: CompanionMode.silent,
        primary: null,
        suppressed: suppressed,
        reason: CompanionDecisionReason.allSuppressed,
      );
    }

    final primary = ranked.first;
    final modeReason = _modeReason(primary, context);
    final mode = modeReason == CompanionDecisionReason.proactiveEligible
        ? CompanionMode.proactive
        : CompanionMode.helpful;

    return CompanionDecision(
      mode: mode,
      primary: primary,
      secondary: ranked.skip(1).toList(growable: false),
      suppressed: suppressed,
      reason: modeReason,
    );
  }

  static JourneyInsightSuppressionReason? _suppressionFor(
    JourneyInsight insight,
    CompanionPolicyContext context,
  ) {
    if (insight.confidence == JourneyInsightConfidence.unknown) {
      return JourneyInsightSuppressionReason.unknownConfidence;
    }
    if (context.dismissedInsightIds.contains(insight.id)) {
      return JourneyInsightSuppressionReason.dismissed;
    }
    if (context.cooldownInsightIds.contains(insight.id)) {
      return JourneyInsightSuppressionReason.cooldown;
    }
    return null;
  }

  static List<RankedJourneyInsight> _deduplicate(
    List<RankedJourneyInsight> candidates,
    List<SuppressedJourneyInsight> suppressed,
  ) {
    final winnerById = <String, RankedJourneyInsight>{};

    for (final candidate in candidates) {
      final existing = winnerById[candidate.insight.id];
      if (existing == null ||
          _confidenceValue(candidate.insight.confidence) >
              _confidenceValue(existing.insight.confidence)) {
        if (existing != null) {
          suppressed.add(
            SuppressedJourneyInsight(
              insight: existing.insight,
              reason: JourneyInsightSuppressionReason.duplicate,
            ),
          );
        }
        winnerById[candidate.insight.id] = candidate;
      } else {
        suppressed.add(
          SuppressedJourneyInsight(
            insight: candidate.insight,
            reason: JourneyInsightSuppressionReason.duplicate,
          ),
        );
      }
    }

    return winnerById.values.toList(growable: false);
  }

  static int _confidenceValue(JourneyInsightConfidence confidence) {
    return switch (confidence) {
      JourneyInsightConfidence.confirmed => 2,
      JourneyInsightConfidence.high => 1,
      JourneyInsightConfidence.unknown => 0,
    };
  }

  static bool _isMateriallyUseful(JourneyInsight insight) =>
      insight.type == JourneyInsightType.attention ||
      insight.severity == JourneyInsightSeverity.normal;

  static CompanionDecisionReason _modeReason(
    RankedJourneyInsight primary,
    CompanionPolicyContext context,
  ) {
    final insight = primary.insight;
    if (!insight.proactiveEligible) {
      return CompanionDecisionReason.helpfulDefault;
    }
    if (!context.proactiveEnabled) {
      return CompanionDecisionReason.proactiveDisabled;
    }
    if (insight.confidence == JourneyInsightConfidence.unknown) {
      return CompanionDecisionReason.proactiveInsufficientEvidence;
    }
    if (primary.actions.isEmpty) {
      return CompanionDecisionReason.proactiveNoValidAction;
    }
    if (!context.materialConsequenceInsightIds.contains(insight.id)) {
      return CompanionDecisionReason.proactiveMissingConsequence;
    }
    if (!context.temporallyRelevantInsightIds.contains(insight.id)) {
      return CompanionDecisionReason.proactiveMissingTemporalRelevance;
    }
    return CompanionDecisionReason.proactiveEligible;
  }
}
