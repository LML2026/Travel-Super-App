import 'assistant_command_card.dart';
import '../routing/assistant_navigation_target.dart';

class WalletCommandCard extends AssistantCommandCard {
  const WalletCommandCard({
    required super.id,
    required super.title,
    required super.subtitle,
  }) : super(
          type: AssistantCommandCardType.wallet,
          actionLabel: 'Open Wallet',
          navigationTarget: AssistantNavigationTarget.wallet,
        );
}
