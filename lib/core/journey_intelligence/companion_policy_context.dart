import 'dart:collection';

import 'journey_insight.dart';

class CompanionPolicyContext {
  final DateTime clock;
  final Set<JourneyActionType> availableActions;
  final Set<String> dismissedInsightIds;
  final Set<String> cooldownInsightIds;
  final Map<String, int> repetitionCounts;
  final bool companionEnabled;
  final bool proactiveEnabled;
  final Set<String> materialConsequenceInsightIds;
  final Set<String> temporallyRelevantInsightIds;

  CompanionPolicyContext({
    required this.clock,
    Set<JourneyActionType> availableActions = const {},
    Set<String> dismissedInsightIds = const {},
    Set<String> cooldownInsightIds = const {},
    Map<String, int> repetitionCounts = const {},
    this.companionEnabled = true,
    this.proactiveEnabled = false,
    Set<String> materialConsequenceInsightIds = const {},
    Set<String> temporallyRelevantInsightIds = const {},
  }) : availableActions = UnmodifiableSetView(Set.of(availableActions)),
       dismissedInsightIds = UnmodifiableSetView(Set.of(dismissedInsightIds)),
       cooldownInsightIds = UnmodifiableSetView(Set.of(cooldownInsightIds)),
       repetitionCounts = UnmodifiableMapView(Map.of(repetitionCounts)),
       materialConsequenceInsightIds = UnmodifiableSetView(
         Set.of(materialConsequenceInsightIds),
       ),
       temporallyRelevantInsightIds = UnmodifiableSetView(
         Set.of(temporallyRelevantInsightIds),
       );
}
