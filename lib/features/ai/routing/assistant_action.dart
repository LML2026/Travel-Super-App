import '../command_cards/assistant_command_card.dart';
import 'assistant_navigation_target.dart';

abstract class AssistantAction {
  const AssistantAction();
}

class NavigateAssistantAction extends AssistantAction {
  const NavigateAssistantAction(
    this.target, {
    this.parameters = const <String, Object?>{},
  });

  final AssistantNavigationTarget target;
  final Map<String, Object?> parameters;
}

class ReplyAssistantAction extends AssistantAction {
  const ReplyAssistantAction(this.message);

  final String message;
}

class ShowCommandCardAction extends AssistantAction {
  const ShowCommandCardAction({
    required this.message,
    required this.card,
  });

  final String message;
  final AssistantCommandCard card;
}

class UnsupportedAssistantAction extends AssistantAction {
  const UnsupportedAssistantAction(this.message);

  final String message;
}
