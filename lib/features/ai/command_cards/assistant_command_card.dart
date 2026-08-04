import '../routing/assistant_navigation_target.dart';

enum AssistantCommandCardType {
  wallet,
  travelCoin,
  journey,
  profile,
  tripPlanner,
  translation,
  confirmation,
}

class AssistantCommandCard {
  const AssistantCommandCard({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.actionLabel,
    this.navigationTarget,
    this.metadata = const <String, Object?>{},
    this.requiresConfirmation = false,
  });

  final String id;
  final AssistantCommandCardType type;
  final String title;
  final String? subtitle;
  final String actionLabel;
  final AssistantNavigationTarget? navigationTarget;
  final Map<String, Object?> metadata;
  final bool requiresConfirmation;
}
