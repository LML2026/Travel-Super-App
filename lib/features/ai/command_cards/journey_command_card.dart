import '../routing/assistant_navigation_target.dart';
import 'assistant_command_card.dart';

class JourneyCommandCard extends AssistantCommandCard {
  const JourneyCommandCard({
    required super.id,
    required super.title,
    required super.subtitle,
    super.metadata = const <String, Object?>{},
  }) : super(
          type: AssistantCommandCardType.journey,
          actionLabel: 'View Timeline',
          navigationTarget: AssistantNavigationTarget.activeJourney,
        );
}
