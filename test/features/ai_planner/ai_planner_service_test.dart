import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/core/models/booking.dart';
import 'package:travel_super_app/features/ai_planner/domain/ai_planner_models.dart';
import 'package:travel_super_app/features/ai_planner/domain/ai_planner_repository.dart';
import 'package:travel_super_app/features/ai_planner/presentation/providers/ai_planner_provider.dart';
import 'package:travel_super_app/features/ai_planner/services/ai_planner_service.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip_activity.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_activity_repository.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_activity_provider.dart';

class _FakeTripActivityRepository implements TripActivityRepository {
  final added = <TripActivity>[];
  final updated = <TripActivity>[];
  final deleted = <String>[];

  @override
  Future<void> addActivity(TripActivity activity) async {
    added.add(activity);
  }

  @override
  Future<void> updateActivity(TripActivity activity) async {
    updated.add(activity);
  }

  @override
  Future<void> deleteActivity({
    required String tripId,
    required String activityId,
  }) async {
    deleted.add(activityId);
  }

  @override
  Stream<List<TripActivity>> watchActivities(String tripId) {
    return Stream.value(
        added.where((activity) => activity.tripId == tripId).toList());
  }
}

class _FakeAiPlannerRepository implements AiPlannerRepository {
  final plans = <AiPlannerPlan>[];

  @override
  Future<List<AiPlannerPlan>> getPlanHistory(String tripId) async {
    return plans.where((plan) => plan.tripId == tripId).toList(growable: false)
      ..sort((a, b) => (b.updatedAt ?? b.generatedAt)
          .compareTo(a.updatedAt ?? a.generatedAt));
  }

  @override
  Future<void> savePlan(AiPlannerPlan plan) async {
    final index = plans.indexWhere((existing) => existing.id == plan.id);
    if (index == -1) {
      plans.add(plan);
    } else {
      plans[index] = plan;
    }
  }

  @override
  Stream<List<AiPlannerPlan>> watchPlanHistory(String tripId) {
    return Stream.fromFuture(getPlanHistory(tripId));
  }
}

Trip _trip() {
  return Trip(
    id: 'trip-ai',
    title: 'Paris Getaway',
    destination: 'Paris',
    startDate: DateTime(2026, 9, 1),
    endDate: DateTime(2026, 9, 3),
    budget: 600,
    currency: 'GBP',
    travellers: 2,
  );
}

void main() {
  test('local planner generates budget-aware day plans from trip context',
      () async {
    const service = LocalAiPlannerService();
    final trip = _trip();

    final plan = await service.generatePlan(
      AiPlannerContext(
        trip: trip,
        activities: [
          TripActivity(
            id: 'activity-1',
            tripId: trip.id,
            title: 'Existing museum booking',
            scheduledAt: DateTime(2026, 9, 1, 9),
          ),
        ],
        bookings: [
          Booking.flight(
            id: 'booking-1',
            tripId: trip.id,
            userId: 'user-1',
            amount: 200,
            currency: 'GBP',
            metadata: {'departure': '2026-09-01T09:00:00'},
          ).copyWith(status: BookingStatus.confirmed),
        ],
        expenses: const [],
        preferences: const AiPlannerPreferences(
          interests: {'food', 'culture', 'relaxation'},
          pace: AiPlannerPace.balanced,
        ),
      ),
    );

    expect(plan.source, 'local-demo');
    expect(plan.days, hasLength(3));
    expect(plan.totalEstimatedCost, lessThanOrEqualTo(400));
    expect(plan.days.first.suggestions, hasLength(3));
    expect(
      plan.days.first.suggestions.first.startTime.hour,
      isNot(9),
      reason:
          'The local planner should avoid known booking/activity conflicts.',
    );
  });

  test('local planner responds to cheaper and rainy-day prompts', () async {
    const service = LocalAiPlannerService();
    final trip = _trip();

    final plan = await service.generatePlan(
      AiPlannerContext(
        trip: trip,
        activities: const [],
        bookings: const [],
        expenses: const [],
        preferences: const AiPlannerPreferences(),
        prompt: 'Give me a rainy-day plan and make it cheaper',
      ),
    );

    expect(plan.days.first.theme, contains('Rainy-day'));
    expect(
      plan.days
          .expand((day) => day.suggestions)
          .map((suggestion) => suggestion.category),
      contains('rainy-day'),
    );
  });

  test('planner controller accepts, rejects and replaces suggestions',
      () async {
    final repository = _FakeTripActivityRepository();
    final plannerRepository = _FakeAiPlannerRepository();
    final controller = AiPlannerController(
      tripId: 'trip-ai',
      service: const LocalAiPlannerService(),
      repository: plannerRepository,
      activityActions: TripActivityActions(repository),
    );
    final suggestion = AiPlannerSuggestion(
      id: 'suggestion-1',
      title: 'Local food hall',
      category: 'restaurant',
      location: 'Paris food quarter',
      startTime: DateTime(2026, 9, 1, 12),
      durationMinutes: 90,
      estimatedCost: 40,
      currency: 'GBP',
      notes: 'Budget-aware lunch.',
    );

    controller.state = AsyncData(
      AiPlannerPlan(
        generatedAt: DateTime(2026, 8, 19),
        summary: 'Plan',
        days: [
          AiPlannerDayPlan(
            date: DateTime(2026, 9, 1),
            theme: 'food',
            suggestions: [suggestion],
          ),
        ],
        totalEstimatedCost: 40,
        currency: 'GBP',
        source: 'local-demo',
      ),
    );

    await controller.acceptSuggestion(suggestion);
    expect(repository.added.single.title, 'Local food hall');
    expect(repository.added.single.status, 'AI planned');
    expect(
      controller.state.value!.days.single.suggestions.single.status,
      AiPlannerSuggestionStatus.accepted,
    );

    await controller.replaceSuggestion('suggestion-1');
    expect(
      controller.state.value!.days.single.suggestions.single.title,
      contains('Alternative'),
    );

    await controller.rejectSuggestion('suggestion-1');
    expect(
      controller.state.value!.days.single.suggestions.single.status,
      AiPlannerSuggestionStatus.rejected,
    );
    expect(plannerRepository.plans.single.days.single.suggestions.single.status,
        AiPlannerSuggestionStatus.rejected);
  });

  test('controller persists generated plans as history versions', () async {
    final activityRepository = _FakeTripActivityRepository();
    final plannerRepository = _FakeAiPlannerRepository();
    final controller = AiPlannerController(
      tripId: 'trip-ai',
      service: const LocalAiPlannerService(),
      repository: plannerRepository,
      activityActions: TripActivityActions(activityRepository),
    );
    final trip = _trip();
    final context = AiPlannerContext(
      trip: trip,
      activities: const [],
      bookings: const [],
      expenses: const [],
      preferences: const AiPlannerPreferences(),
    );

    await controller.generate(context);
    await controller.generate(context);

    expect(plannerRepository.plans, hasLength(2));
    expect(plannerRepository.plans.map((plan) => plan.version), [1, 2]);
    expect(plannerRepository.plans.last.contextFingerprint, isNotEmpty);
    expect(controller.state.value!.version, 2);
  });

  test('restoring an earlier plan keeps history and makes it active', () async {
    final activityRepository = _FakeTripActivityRepository();
    final plannerRepository = _FakeAiPlannerRepository();
    final controller = AiPlannerController(
      tripId: 'trip-ai',
      service: const LocalAiPlannerService(),
      repository: plannerRepository,
      activityActions: TripActivityActions(activityRepository),
    );
    final firstPlan = AiPlannerPlan(
      id: 'plan-1',
      tripId: 'trip-ai',
      version: 1,
      generatedAt: DateTime(2026, 8, 19, 10),
      updatedAt: DateTime(2026, 8, 19, 10),
      summary: 'Earlier plan',
      days: const [],
      totalEstimatedCost: 100,
      currency: 'GBP',
      source: 'local-demo',
    );
    final secondPlan = firstPlan.copyWith(
      id: 'plan-2',
      version: 2,
      generatedAt: DateTime(2026, 8, 19, 11),
      updatedAt: DateTime(2026, 8, 19, 11),
      summary: 'Newer plan',
    );
    await plannerRepository.savePlan(firstPlan);
    await plannerRepository.savePlan(secondPlan);

    await controller.restorePlan(firstPlan);

    expect(controller.state.value!.id, 'plan-1');
    expect(plannerRepository.plans, hasLength(2));
    final history = await plannerRepository.getPlanHistory('trip-ai');
    expect(history.first.id, 'plan-1');
  });

  test('context fingerprint detects material trip changes', () {
    final trip = _trip();
    final context = AiPlannerContext(
      trip: trip,
      activities: const [],
      bookings: const [],
      expenses: const [],
      preferences: const AiPlannerPreferences(),
    );
    final plan = AiPlannerPlan(
      id: 'plan-1',
      tripId: trip.id,
      generatedAt: DateTime(2026, 8, 19),
      summary: 'Plan',
      days: const [],
      totalEstimatedCost: 0,
      currency: 'GBP',
      source: 'local-demo',
      contextFingerprint: AiPlannerContextFingerprint.fromContext(context),
    );

    expect(AiPlannerContextFingerprint.hasChanged(plan, context), isFalse);
    expect(
      AiPlannerContextFingerprint.hasChanged(
        plan,
        AiPlannerContext(
          trip: trip.copyWith(budget: 700),
          activities: const [],
          bookings: const [],
          expenses: const [],
          preferences: const AiPlannerPreferences(),
        ),
      ),
      isTrue,
    );
  });

  test('accepting an already-added suggestion does not duplicate activity',
      () async {
    final activityRepository = _FakeTripActivityRepository();
    final plannerRepository = _FakeAiPlannerRepository();
    final controller = AiPlannerController(
      tripId: 'trip-ai',
      service: const LocalAiPlannerService(),
      repository: plannerRepository,
      activityActions: TripActivityActions(activityRepository),
    );
    final suggestion = AiPlannerSuggestion(
      id: 'suggestion-duplicate',
      title: 'Local food hall',
      category: 'restaurant',
      location: 'Paris food quarter',
      startTime: DateTime(2026, 9, 1, 12),
      durationMinutes: 90,
      estimatedCost: 40,
      currency: 'GBP',
      notes: 'Budget-aware lunch.',
    );
    await activityRepository.addActivity(
      TripActivity(
        id: 'activity-existing',
        tripId: 'trip-ai',
        title: suggestion.title,
        notes: 'AI Planner suggestion suggestion-duplicate.',
        scheduledAt: suggestion.startTime,
      ),
    );
    controller.state = AsyncData(
      AiPlannerPlan(
        id: 'plan-1',
        tripId: 'trip-ai',
        generatedAt: DateTime(2026, 8, 19),
        summary: 'Plan',
        days: [
          AiPlannerDayPlan(
            date: DateTime(2026, 9, 1),
            theme: 'food',
            suggestions: [suggestion],
          ),
        ],
        totalEstimatedCost: 40,
        currency: 'GBP',
        source: 'local-demo',
      ),
    );
    await plannerRepository.savePlan(controller.state.value!);
    await controller.generate(
      AiPlannerContext(
        trip: _trip(),
        activities: activityRepository.added,
        bookings: const [],
        expenses: const [],
        preferences: const AiPlannerPreferences(),
      ),
    );
    final regenerated = controller.state.value!;
    final duplicateTitles = regenerated.days
        .expand((day) => day.suggestions)
        .where((suggestion) => suggestion.title == 'Local food hall');

    expect(duplicateTitles, isEmpty);
  });
}
