import 'assistant_command_card.dart';
import '../routing/assistant_navigation_target.dart';

class JourneyCommandCard extends AssistantCommandCard {
  const JourneyCommandCard({
    required super.id,
    required super.title,
    required super.subtitle,
  }) : super(
          type: AssistantCommandCardType.journey,
          actionLabel: 'View Journey',
          navigationTarget: AssistantNavigationTarget.activeJourney,
        );
}
