import 'package:flutter_test/flutter_test.dart';
import 'package:itarevo/core/journey_intelligence/companion_decision.dart';
import 'package:itarevo/core/journey_intelligence/journey_companion_presenter.dart';
import 'package:itarevo/core/journey_intelligence/journey_insight.dart';
import 'package:itarevo/core/journey_intelligence/journey_relevance_engine.dart';

void main() {
  test('silent decision produces no companion model', () {
    final model = JourneyCompanionPresenter.present(
      CompanionDecision(
        mode: CompanionMode.silent,
        primary: null,
        reason: CompanionDecisionReason.noInsights,
      ),
    );

    expect(model, isNull);
  });

  test('helpful decision preserves semantic arguments and action', () {
    final decision = _decision(
      message: JourneyInsightMessage.missingCoordinates,
      arguments: {'count': 2},
      action: JourneyActionType.openMap,
    );

    final model = JourneyCompanionPresenter.present(decision);

    expect(model?.mode, CompanionMode.helpful);
    expect(model?.message, JourneyCompanionMessage.missingCoordinates);
    expect(model?.arguments['count'], 2);
    expect(model?.action, JourneyActionType.openMap);
    expect(model?.isAttention, isTrue);
  });

  test('does not expose ranking or suppression metadata', () {
    final model = JourneyCompanionPresenter.present(
      _decision(
        message: JourneyInsightMessage.missingCoordinates,
        arguments: {'count': 1},
        action: JourneyActionType.openMap,
      ),
    );

    expect(model, isNotNull);
    expect(model.runtimeType.toString(), 'JourneyCompanionViewModel');
  });

  test('same decision produces equivalent view models', () {
    final decision = _decision(
      message: JourneyInsightMessage.missingCoordinates,
      arguments: {'count': 1},
      action: JourneyActionType.openMap,
    );

    final first = JourneyCompanionPresenter.present(decision);
    final second = JourneyCompanionPresenter.present(decision);

    expect(first?.message, second?.message);
    expect(first?.arguments, second?.arguments);
    expect(first?.action, second?.action);
  });
}

CompanionDecision _decision({
  required JourneyInsightMessage message,
  required Map<String, Object?> arguments,
  required JourneyActionType action,
}) {
  final insight = JourneyInsight(
    id: 'insight',
    type: JourneyInsightType.attention,
    message: message,
    supportingData: arguments,
    severity: JourneyInsightSeverity.normal,
    confidence: JourneyInsightConfidence.confirmed,
    source: 'test',
    actions: [action],
  );
  final ranked = RankedJourneyInsight(
    insight: insight,
    actions: [action],
    factors: const JourneyRelevanceFactors(
      confidence: 40,
      actionability: 15,
      consequence: 8,
      temporalProximity: 0,
      repetitionPenalty: 0,
    ),
    originalIndex: 0,
  );

  return CompanionDecision(
    mode: CompanionMode.helpful,
    primary: ranked,
    reason: CompanionDecisionReason.helpfulDefault,
  );
}
