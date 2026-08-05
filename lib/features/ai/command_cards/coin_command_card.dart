import 'assistant_command_card.dart';
import '../routing/assistant_navigation_target.dart';

class CoinCommandCard extends AssistantCommandCard {
  const CoinCommandCard({
    required super.id,
    required super.title,
    required super.subtitle,
  }) : super(
          type: AssistantCommandCardType.coin,
          actionLabel: 'Open Travel Coin',
          navigationTarget: AssistantNavigationTarget.travelCoin,
        );
}
