import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/ai_planner/domain/ai_planner_models.dart';
import 'package:travel_super_app/features/ai_planner/domain/ai_planner_repository.dart';
import 'package:travel_super_app/features/ai_planner/presentation/providers/ai_planner_provider.dart';
import 'package:travel_super_app/features/ai_planner/services/ai_planner_service.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart';

void main() {
  test('planner preferences persist and restore per trip', () async {
    final repository = _PreferencesRepository();
    final updated = const AiPlannerPreferences(
      interests: {'food', 'nightlife'},
      pace: AiPlannerPace.packed,
      cheaperPlan: true,
    );

    final first = AiPlannerPreferencesController(
      tripId: 'trip-1',
      repository: repository,
    );
    first.update(updated);
    await Future<void>.delayed(Duration.zero);

    final reopened = AiPlannerPreferencesController(
      tripId: 'trip-1',
      repository: repository,
    );
    await reopened.load();

    expect(reopened.state.interests, updated.interests);
    expect(reopened.state.pace, AiPlannerPace.packed);
    expect(reopened.state.cheaperPlan, isTrue);

    final plan = await const LocalAiPlannerService().generatePlan(
      AiPlannerContext(
        trip: Trip(
          id: 'trip-1',
          title: 'Paris',
          destination: 'Paris',
          startDate: DateTime(2026, 9, 1),
          endDate: DateTime(2026, 9, 1),
          budget: 500,
        ),
        activities: const [],
        bookings: const [],
        expenses: const [],
        preferences: reopened.state,
      ),
    );
    expect(plan.days.single.suggestions, hasLength(4));
  });

  test(
      'unavailable preference persistence keeps defaults and selections usable',
      () async {
    final repository = _PreferencesRepository(fail: true);
    final controller = AiPlannerPreferencesController(
      tripId: 'trip-1',
      repository: repository,
    );

    await controller.load();
    controller.update(const AiPlannerPreferences(rainyDay: true));
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.rainyDay, isTrue);
  });
}

class _PreferencesRepository
    implements AiPlannerRepository, AiPlannerPreferencesRepository {
  _PreferencesRepository({this.fail = false});

  final bool fail;
  AiPlannerPreferences? preferences;

  @override
  Future<AiPlannerPreferences?> getPreferences(String tripId) async {
    if (fail) throw StateError('offline');
    return preferences;
  }

  @override
  Future<void> savePreferences(
    String tripId,
    AiPlannerPreferences value,
  ) async {
    if (fail) throw StateError('offline');
    preferences = value;
  }

  @override
  Future<List<AiPlannerPlan>> getPlanHistory(String tripId) async => const [];

  @override
  Future<void> savePlan(AiPlannerPlan plan) async {}

  @override
  Stream<List<AiPlannerPlan>> watchPlanHistory(String tripId) =>
      Stream.value(const []);
}
