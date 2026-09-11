import 'ai_planner_models.dart';

abstract interface class AiPlannerRepository {
  Stream<List<AiPlannerPlan>> watchPlanHistory(String tripId);

  Future<List<AiPlannerPlan>> getPlanHistory(String tripId);

  Future<void> savePlan(AiPlannerPlan plan);
}

abstract interface class AiPlannerPreferencesRepository {
  Future<AiPlannerPreferences?> getPreferences(String tripId);

  Future<void> savePreferences(
    String tripId,
    AiPlannerPreferences preferences,
  );
}
