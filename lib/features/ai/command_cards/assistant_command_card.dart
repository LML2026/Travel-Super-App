import '../routing/assistant_navigation_target.dart';

enum AssistantCommandCardType {
  wallet,
  coin,
  journey,
  profile,
  tripPlanner,
  translation,
}

class AssistantCommandCard {
  const AssistantCommandCard({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.navigationTarget,
  });

  final String id;
  final AssistantCommandCardType type;
  final String title;
  final String subtitle;
  final String actionLabel;
  final AssistantNavigationTarget navigationTarget;
}
