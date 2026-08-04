import '../routing/assistant_navigation_target.dart';
import 'assistant_command_card.dart';

class WalletCommandCard extends AssistantCommandCard {
  const WalletCommandCard({
    required super.id,
    required super.title,
    required super.subtitle,
    super.metadata = const <String, Object?>{},
  }) : super(
          type: AssistantCommandCardType.wallet,
          actionLabel: 'Open Wallet',
          navigationTarget: AssistantNavigationTarget.wallet,
        );
}
