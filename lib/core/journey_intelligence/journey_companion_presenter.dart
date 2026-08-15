import 'companion_decision.dart';
import 'journey_insight.dart';

enum JourneyCompanionMessage { missingCoordinates, comingUp }

class JourneyCompanionViewModel {
  final CompanionMode mode;
  final JourneyCompanionMessage message;
  final Map<String, Object?> arguments;
  final JourneyActionType? action;
  final bool isAttention;

  const JourneyCompanionViewModel({
    required this.mode,
    required this.message,
    required this.arguments,
    required this.action,
    required this.isAttention,
  });
}

class JourneyCompanionPresenter {
  const JourneyCompanionPresenter._();

  static JourneyCompanionViewModel? present(CompanionDecision decision) {
    if (decision.mode == CompanionMode.silent) return null;

    final primary = decision.primary;
    if (primary == null) return null;

    final message = switch (primary.insight.message) {
      JourneyInsightMessage.missingCoordinates =>
        JourneyCompanionMessage.missingCoordinates,
      JourneyInsightMessage.nextScheduledStop =>
        JourneyCompanionMessage.comingUp,
      _ => null,
    };
    if (message == null) return null;

    return JourneyCompanionViewModel(
      mode: decision.mode,
      message: message,
      arguments: Map.unmodifiable(primary.insight.supportingData),
      action: primary.actions.isEmpty ? null : primary.actions.first,
      isAttention: primary.insight.type == JourneyInsightType.attention,
    );
  }
}
