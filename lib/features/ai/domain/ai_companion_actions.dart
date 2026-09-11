enum AiCompanionActionType {
  today,
  next,
  nearby,
  weather,
  route,
  bookings,
  budget,
  readiness,
  translate,
  planTomorrow,
}

class AiCompanionAction {
  const AiCompanionAction(this.type, this.label, this.prompt);

  final AiCompanionActionType type;
  final String label;
  final String prompt;
}

class AiCompanionActionCatalog {
  const AiCompanionActionCatalog._();

  static List<AiCompanionAction> forTrip({required bool hasTrip}) {
    if (!hasTrip) return const [];
    return const [
      AiCompanionAction(AiCompanionActionType.today, 'Today', 'What should I do today?'),
      AiCompanionAction(AiCompanionActionType.next, 'Next', 'What is next?'),
      AiCompanionAction(AiCompanionActionType.nearby, 'Nearby', 'Find somewhere to eat near me.'),
      AiCompanionAction(AiCompanionActionType.weather, 'Weather', 'What should I do if it rains?'),
      AiCompanionAction(AiCompanionActionType.route, 'Route', 'How do I get to my hotel?'),
      AiCompanionAction(AiCompanionActionType.bookings, 'Bookings', 'Show my flight.'),
      AiCompanionAction(AiCompanionActionType.budget, 'Budget', 'How much have I spent?'),
      AiCompanionAction(AiCompanionActionType.readiness, 'Readiness', 'What do I still need to prepare?'),
      AiCompanionAction(AiCompanionActionType.translate, 'Translate', 'Translate this.'),
      AiCompanionAction(AiCompanionActionType.planTomorrow, 'Tomorrow', 'Plan tomorrow.'),
    ];
  }
}
