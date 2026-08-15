import 'package:flutter_test/flutter_test.dart';
import 'package:itarevo/core/journey_intelligence/companion_decision.dart';
import 'package:itarevo/core/journey_intelligence/companion_policy.dart';
import 'package:itarevo/core/journey_intelligence/companion_policy_context.dart';
import 'package:itarevo/core/journey_intelligence/journey_insight.dart';

void main() {
  group('policy gates', () {
    test('suppresses unknown confidence before relevance ranking', () {
      final decision = _decide([
        _insight(confidence: JourneyInsightConfidence.unknown),
      ]);

      expect(decision.mode, CompanionMode.silent);
      expect(
        decision.suppressed.single.reason,
        JourneyInsightSuppressionReason.unknownConfidence,
      );
    });

    test('companion disabled produces an explainable silent decision', () {
      final decision = _decide([
        _insight(),
      ], context: _policy(companionEnabled: false));

      expect(decision.mode, CompanionMode.silent);
      expect(decision.reason, CompanionDecisionReason.companionDisabled);
      expect(
        decision.suppressed.single.reason,
        JourneyInsightSuppressionReason.companionDisabled,
      );
    });

    test('dismissed and cooldown insights are suppressed', () {
      final dismissed = _decide([
        _insight(id: 'dismissed'),
      ], context: _policy(dismissed: {'dismissed'}));
      final cooldown = _decide([
        _insight(id: 'cooldown'),
      ], context: _policy(cooldown: {'cooldown'}));

      expect(
        dismissed.suppressed.single.reason,
        JourneyInsightSuppressionReason.dismissed,
      );
      expect(
        cooldown.suppressed.single.reason,
        JourneyInsightSuppressionReason.cooldown,
      );
    });

    test('removes unavailable actions without inventing replacements', () {
      final decision = _decide([
        _insight(
          actions: [JourneyActionType.openTrip, JourneyActionType.editStop],
        ),
      ], context: _policy(actions: {JourneyActionType.openTrip}));

      expect(decision.primary?.actions, [JourneyActionType.openTrip]);
    });

    test('invalid low-value actions result in a silent decision', () {
      final decision = _decide([
        _insight(actions: [JourneyActionType.editStop]),
      ], context: _policy(actions: const {}));

      expect(decision.mode, CompanionMode.silent);
      expect(
        decision.suppressed.single.reason,
        JourneyInsightSuppressionReason.noUsefulContent,
      );
    });
  });

  group('deduplication and ranking', () {
    test('collapses duplicate IDs in deterministic order', () {
      final decision = _decide([
        _insight(id: 'duplicate', source: 'first'),
        _insight(id: 'duplicate', source: 'second'),
      ]);

      expect(decision.primary?.insight.source, 'first');
      expect(decision.secondary, isEmpty);
      expect(
        decision.suppressed.single.reason,
        JourneyInsightSuppressionReason.duplicate,
      );
    });

    test('retains the higher-confidence duplicate candidate', () {
      final decision = _decide([
        _insight(id: 'duplicate', confidence: JourneyInsightConfidence.high),
        _insight(
          id: 'duplicate',
          confidence: JourneyInsightConfidence.confirmed,
        ),
      ]);

      expect(
        decision.primary?.insight.confidence,
        JourneyInsightConfidence.confirmed,
      );
    });

    test('confirmed evidence outranks equivalent high evidence', () {
      final decision = _decide([
        _insight(id: 'high', confidence: JourneyInsightConfidence.high),
        _insight(
          id: 'confirmed',
          confidence: JourneyInsightConfidence.confirmed,
        ),
      ]);

      expect(decision.primary?.insight.id, 'confirmed');
      expect(decision.primary?.factors.confidence, greaterThan(30));
    });

    test('valid actions outrank equivalent actionless information', () {
      final decision = _decide([
        _insight(
          id: 'actionless',
          type: JourneyInsightType.attention,
          actions: const [],
        ),
        _insight(id: 'actionable', actions: [JourneyActionType.openTrip]),
      ]);

      expect(decision.primary?.insight.id, 'actionable');
      expect(decision.primary?.factors.actionability, 15);
    });

    test('material consequence and repetition penalty are inspectable', () {
      final decision = _decide(
        [
          _insight(
            id: 'repeated',
            type: JourneyInsightType.attention,
            actions: const [],
          ),
          _insight(
            id: 'material',
            type: JourneyInsightType.attention,
            actions: const [],
          ),
        ],
        context: _policy(
          repetitionCounts: {'repeated': 3},
          material: {'material'},
        ),
      );

      expect(decision.primary?.insight.id, 'material');
      expect(decision.primary?.factors.consequence, 15);
      expect(decision.secondary.single.factors.repetitionPenalty, 15);
    });

    test('a policy gate beats an otherwise high relevance candidate', () {
      final decision = _decide([
        _insight(
          id: 'unknown',
          confidence: JourneyInsightConfidence.unknown,
          actions: [JourneyActionType.openTrip],
        ),
        _insight(
          id: 'confirmed',
          type: JourneyInsightType.attention,
          actions: const [],
        ),
      ]);

      expect(decision.primary?.insight.id, 'confirmed');
      expect(
        decision.suppressed.single.reason,
        JourneyInsightSuppressionReason.unknownConfidence,
      );
    });

    test('same inputs produce the same ranked decision', () {
      final insights = [
        _insight(id: 'first', actions: [JourneyActionType.openTrip]),
        _insight(
          id: 'second',
          type: JourneyInsightType.attention,
          actions: const [],
        ),
      ];
      final context = _policy(actions: {JourneyActionType.openTrip});

      final first = _decide(insights, context: context);
      final second = _decide(insights, context: context);

      expect(first.mode, second.mode);
      expect(first.primary?.insight.id, second.primary?.insight.id);
      expect(
        first.secondary.map((candidate) => candidate.insight.id),
        second.secondary.map((candidate) => candidate.insight.id),
      );
    });
  });

  group('companion decisions', () {
    test('empty, unknown-only, and all-suppressed inputs choose silent', () {
      expect(_decide(const []).mode, CompanionMode.silent);
      expect(
        _decide([_insight(confidence: JourneyInsightConfidence.unknown)]).mode,
        CompanionMode.silent,
      );
      expect(
        _decide([
          _insight(id: 'dismissed'),
        ], context: _policy(dismissed: {'dismissed'})).mode,
        CompanionMode.silent,
      );
    });

    test(
      'deterministic planning, budget, and next-stop insights choose helpful',
      () {
        final planning = _decide([
          _insight(
            id: 'coordinates',
            type: JourneyInsightType.attention,
            actions: [JourneyActionType.editStop],
          ),
        ]);
        final budget = _decide([
          _insight(
            id: 'budget',
            type: JourneyInsightType.attention,
            actions: [JourneyActionType.openTrip],
          ),
        ]);
        final nextStop = _decide([
          _insight(
            id: 'next',
            confidence: JourneyInsightConfidence.high,
            actions: [JourneyActionType.reviewStop],
          ),
        ]);

        expect(planning.mode, CompanionMode.helpful);
        expect(budget.mode, CompanionMode.helpful);
        expect(nextStop.mode, CompanionMode.helpful);
        expect(nextStop.reason, CompanionDecisionReason.helpfulDefault);
      },
    );

    test('selects one primary insight and retains secondary candidates', () {
      final decision = _decide([
        _insight(id: 'primary', actions: [JourneyActionType.openTrip]),
        _insight(
          id: 'secondary',
          type: JourneyInsightType.attention,
          actions: const [],
        ),
      ]);

      expect(decision.primary?.insight.id, 'primary');
      expect(decision.secondary.map((candidate) => candidate.insight.id), [
        'secondary',
      ]);
    });
  });

  group('proactive safeguards', () {
    test(
      'a current deterministic JI-1-style insight remains non-proactive',
      () {
        final decision = _decide(
          [
            _insight(
              actions: [JourneyActionType.editStop],
              proactiveEligible: false,
            ),
          ],
          context: _policy(
            proactiveEnabled: true,
            material: {'insight'},
            temporal: {'insight'},
          ),
        );

        expect(decision.mode, CompanionMode.helpful);
      },
    );

    test(
      'proactive is denied when disabled, weak, actionless, dismissed, or cooled down',
      () {
        final disabled = _decide([_proactiveInsight()], context: _policy());
        final weak = _decide(
          [_proactiveInsight(confidence: JourneyInsightConfidence.unknown)],
          context: _policy(
            proactiveEnabled: true,
            material: {'insight'},
            temporal: {'insight'},
          ),
        );
        final actionless = _decide(
          [_proactiveInsight(actions: const [])],
          context: _policy(
            proactiveEnabled: true,
            material: {'insight'},
            temporal: {'insight'},
          ),
        );
        final dismissed = _decide(
          [_proactiveInsight()],
          context: _policy(
            proactiveEnabled: true,
            material: {'insight'},
            temporal: {'insight'},
            dismissed: {'insight'},
          ),
        );
        final cooldown = _decide(
          [_proactiveInsight()],
          context: _policy(
            proactiveEnabled: true,
            material: {'insight'},
            temporal: {'insight'},
            cooldown: {'insight'},
          ),
        );

        expect(disabled.mode, CompanionMode.helpful);
        expect(disabled.reason, CompanionDecisionReason.proactiveDisabled);
        expect(weak.mode, CompanionMode.silent);
        expect(actionless.mode, CompanionMode.helpful);
        expect(
          actionless.reason,
          CompanionDecisionReason.proactiveNoValidAction,
        );
        expect(dismissed.mode, CompanionMode.silent);
        expect(cooldown.mode, CompanionMode.silent);
      },
    );

    test('fully eligible synthetic future candidate may choose proactive', () {
      final decision = _decide(
        [_proactiveInsight()],
        context: _policy(
          proactiveEnabled: true,
          material: {'insight'},
          temporal: {'insight'},
        ),
      );

      expect(decision.mode, CompanionMode.proactive);
      expect(decision.reason, CompanionDecisionReason.proactiveEligible);
    });
  });
}

CompanionDecision _decide(
  List<JourneyInsight> insights, {
  CompanionPolicyContext? context,
}) => CompanionPolicy.decide(insights: insights, context: context ?? _policy());

CompanionPolicyContext _policy({
  Set<JourneyActionType> actions = const {
    JourneyActionType.openTrip,
    JourneyActionType.openItinerary,
    JourneyActionType.openMap,
    JourneyActionType.reviewStop,
    JourneyActionType.editStop,
  },
  Set<String> dismissed = const {},
  Set<String> cooldown = const {},
  Map<String, int> repetitionCounts = const {},
  bool companionEnabled = true,
  bool proactiveEnabled = false,
  Set<String> material = const {},
  Set<String> temporal = const {},
}) => CompanionPolicyContext(
  clock: DateTime(2026, 9, 16, 12),
  availableActions: actions,
  dismissedInsightIds: dismissed,
  cooldownInsightIds: cooldown,
  repetitionCounts: repetitionCounts,
  companionEnabled: companionEnabled,
  proactiveEnabled: proactiveEnabled,
  materialConsequenceInsightIds: material,
  temporallyRelevantInsightIds: temporal,
);

JourneyInsight _insight({
  String id = 'insight',
  JourneyInsightType type = JourneyInsightType.information,
  JourneyInsightConfidence confidence = JourneyInsightConfidence.confirmed,
  List<JourneyActionType> actions = const [JourneyActionType.openTrip],
  bool proactiveEligible = false,
  String source = 'test',
}) => JourneyInsight(
  id: id,
  type: type,
  message: JourneyInsightMessage.plannedStopCount,
  severity: JourneyInsightSeverity.low,
  confidence: confidence,
  source: source,
  actions: actions,
  proactiveEligible: proactiveEligible,
);

JourneyInsight _proactiveInsight({
  JourneyInsightConfidence confidence = JourneyInsightConfidence.confirmed,
  List<JourneyActionType> actions = const [JourneyActionType.openTrip],
}) => _insight(
  type: JourneyInsightType.attention,
  confidence: confidence,
  actions: actions,
  proactiveEligible: true,
);
