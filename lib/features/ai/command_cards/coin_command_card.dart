import '../routing/assistant_navigation_target.dart';
import 'assistant_command_card.dart';

class CoinCommandCard extends AssistantCommandCard {
  const CoinCommandCard({
    required super.id,
    required super.title,
    required super.subtitle,
    super.metadata = const <String, Object?>{},
  }) : super(
          type: AssistantCommandCardType.travelCoin,
          actionLabel: 'View Travel Coin',
          navigationTarget: AssistantNavigationTarget.travelCoin,
        );
}
