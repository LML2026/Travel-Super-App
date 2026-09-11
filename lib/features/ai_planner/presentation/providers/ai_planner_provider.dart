import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../trips/domain/entities/trip_activity.dart';
import '../../../trips/presentation/providers/trip_activity_provider.dart';
import '../../data/repositories/firestore_ai_planner_repository.dart';
import '../../domain/ai_planner_models.dart';
import '../../domain/ai_planner_repository.dart';
import '../../services/ai_planner_service.dart';

final aiPlannerServiceProvider = Provider<AiPlannerService>((ref) {
  return const LocalAiPlannerService();
});

typedef AiPlannerRepositoryFactory = AiPlannerRepository Function(
  String userId,
);

final aiPlannerRepositoryFactoryProvider =
    Provider<AiPlannerRepositoryFactory>((ref) {
  return (userId) => FirestoreAiPlannerRepository(userId: userId);
});

final aiPlannerRepositoryProvider = Provider<AiPlannerRepository>((ref) {
  final user = ref.watch(immediateCurrentUserProvider);
  if (user == null) {
    return const _UnauthenticatedAiPlannerRepository();
  }

  return ref.read(aiPlannerRepositoryFactoryProvider).call(user.uid);
});

final aiPlannerHistoryProvider =
    StreamProvider.family<List<AiPlannerPlan>, String>((ref, tripId) {
  return ref.watch(aiPlannerRepositoryProvider).watchPlanHistory(tripId);
});

final aiPlannerPreferencesProvider = StateNotifierProvider.autoDispose
    .family<AiPlannerPreferencesController, AiPlannerPreferences, String>(
  (ref, tripId) {
    final controller = AiPlannerPreferencesController(
      tripId: tripId,
      repository: ref.watch(aiPlannerRepositoryProvider),
    );
    controller.load();
    return controller;
  },
);

class AiPlannerPreferencesController
    extends StateNotifier<AiPlannerPreferences> {
  AiPlannerPreferencesController({
    required this.tripId,
    required AiPlannerRepository repository,
  })  : _repository = repository,
        super(const AiPlannerPreferences());

  final String tripId;
  final AiPlannerRepository _repository;

  Future<void> load() async {
    final preferencesRepository = _preferencesRepository;
    if (preferencesRepository == null) return;
    try {
      final restored = await preferencesRepository.getPreferences(tripId);
      if (mounted && restored != null) state = restored;
    } catch (_) {
      // Defaults remain usable when cloud persistence is unavailable.
    }
  }

  void update(AiPlannerPreferences preferences) {
    state = preferences;
    unawaited(_persist(preferences));
  }

  void restore(AiPlannerPreferences preferences) {
    state = preferences;
  }

  Future<void> _persist(AiPlannerPreferences preferences) async {
    final preferencesRepository = _preferencesRepository;
    if (preferencesRepository == null) return;
    try {
      await preferencesRepository.savePreferences(tripId, preferences);
    } catch (_) {
      // Keep the in-memory selection; generation and the UI remain usable.
    }
  }

  AiPlannerPreferencesRepository? get _preferencesRepository =>
      _repository is AiPlannerPreferencesRepository
          ? _repository as AiPlannerPreferencesRepository
          : null;
}

final aiPlannerControllerProvider = StateNotifierProvider.autoDispose
    .family<AiPlannerController, AsyncValue<AiPlannerPlan?>, String>(
  (ref, tripId) {
    return AiPlannerController(
      tripId: tripId,
      service: ref.watch(aiPlannerServiceProvider),
      repository: ref.watch(aiPlannerRepositoryProvider),
      activityActions: ref.watch(tripActivityActionsProvider),
    );
  },
);

class AiPlannerController extends StateNotifier<AsyncValue<AiPlannerPlan?>> {
  AiPlannerController({
    required this.tripId,
    required AiPlannerService service,
    required AiPlannerRepository repository,
    required TripActivityActions activityActions,
  })  : _service = service,
        _repository = repository,
        _activityActions = activityActions,
        super(const AsyncData(null));

  final String tripId;
  final AiPlannerService _service;
  final AiPlannerRepository _repository;
  final TripActivityActions _activityActions;
  AiPlannerContext? _lastContext;

  Future<void> generate(AiPlannerContext context) async {
    _lastContext = context;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final history = await _repository.getPlanHistory(tripId);
      final generated = await _service.generatePlan(context);
      final version = history.fold<int>(
            0,
            (highest, plan) => plan.version > highest ? plan.version : highest,
          ) +
          1;
      final plan = generated.copyWith(
        id: const Uuid().v4(),
        tripId: tripId,
        version: version,
        generatedAt: generated.generatedAt,
        updatedAt: generated.generatedAt,
        contextFingerprint: AiPlannerContextFingerprint.fromContext(context),
        preferences: context.preferences,
        prompt: context.prompt,
      );
      await _persistPreferences(context.preferences);
      await _repository.savePlan(plan);
      return plan;
    });
  }

  Future<void> _persistPreferences(AiPlannerPreferences preferences) async {
    final preferencesRepository = _repository is AiPlannerPreferencesRepository
        ? _repository as AiPlannerPreferencesRepository
        : null;
    if (preferencesRepository == null) return;
    try {
      await preferencesRepository.savePreferences(tripId, preferences);
    } catch (_) {
      // Preference persistence must not prevent a plan from being generated.
    }
  }

  Future<void> replan({String? prompt}) async {
    final context = _lastContext;
    if (context == null) {
      return;
    }
    await generate(
      AiPlannerContext(
        trip: context.trip,
        activities: context.activities,
        bookings: context.bookings,
        expenses: context.expenses,
        preferences: context.preferences,
        prompt: prompt ?? context.prompt,
      ),
    );
  }

  Future<void> acceptSuggestion(AiPlannerSuggestion suggestion) async {
    if (suggestion.status == AiPlannerSuggestionStatus.accepted) {
      return;
    }

    if (!_alreadyAcceptedIntoItinerary(suggestion)) {
      await _activityActions.addActivity(
        tripId: tripId,
        title: suggestion.title,
        location: suggestion.location,
        notes:
            'AI Planner suggestion ${suggestion.id}. ${suggestion.notes} Estimated cost: ${suggestion.currency} ${suggestion.estimatedCost.toStringAsFixed(2)}.',
        scheduledAt: suggestion.startTime,
        cost: suggestion.estimatedCost,
        currency: suggestion.currency,
        status: 'AI planned',
      );
    }
    await _updateSuggestion(
      suggestion.id,
      (current) => current.copyWith(status: AiPlannerSuggestionStatus.accepted),
    );
  }

  Future<void> rejectSuggestion(String suggestionId) {
    return _updateSuggestion(
      suggestionId,
      (current) => current.copyWith(status: AiPlannerSuggestionStatus.rejected),
    );
  }

  Future<void> replaceSuggestion(String suggestionId) {
    return _updateSuggestion(suggestionId, (current) {
      final cheaper = (current.estimatedCost * 0.75).roundToDouble();
      return current.copyWith(
        title: _replacementTitle(current),
        startTime: current.startTime.add(const Duration(hours: 1)),
        estimatedCost: cheaper,
        notes:
            '${current.notes} Replaced with a lighter alternative at the same destination.',
        status: AiPlannerSuggestionStatus.proposed,
      );
    });
  }

  Future<void> restorePlan(AiPlannerPlan plan) async {
    final restored = plan.copyWith(updatedAt: DateTime.now());
    await _repository.savePlan(restored);
    state = AsyncData(restored);
  }

  void setActivePlan(AiPlannerPlan plan) {
    _lastContext = null;
    state = AsyncData(plan);
  }

  Future<void> _updateSuggestion(
    String suggestionId,
    AiPlannerSuggestion Function(AiPlannerSuggestion current) update,
  ) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final days = current.days.map((day) {
      return day.copyWith(
        suggestions: day.suggestions.map((suggestion) {
          if (suggestion.id != suggestionId) {
            return suggestion;
          }
          return update(suggestion);
        }).toList(growable: false),
      );
    }).toList(growable: false);

    final updated = current.copyWith(
      days: days,
      updatedAt: DateTime.now(),
      totalEstimatedCost: days.fold<double>(
        0,
        (total, day) => total + day.estimatedCost,
      ),
    );
    await _repository.savePlan(updated);
    state = AsyncData(updated);
  }

  String _replacementTitle(AiPlannerSuggestion suggestion) {
    if (suggestion.category == 'restaurant') {
      return 'Alternative local cafe and street food stop';
    }
    if (suggestion.category == 'culture') {
      return 'Alternative museum and heritage walk';
    }
    if (suggestion.category == 'rainy-day') {
      return 'Alternative indoor market and gallery plan';
    }
    return 'Alternative ${suggestion.category} experience';
  }

  bool _alreadyAcceptedIntoItinerary(AiPlannerSuggestion suggestion) {
    final activities = _lastContext?.activities ?? const <TripActivity>[];
    return activities.any((activity) {
      final notes = activity.notes?.toString() ?? '';
      final sameSuggestion =
          notes.contains('AI Planner suggestion ${suggestion.id}');
      final sameSlot = activity.title == suggestion.title &&
          activity.scheduledAt == suggestion.startTime;
      return sameSuggestion || sameSlot;
    });
  }
}

class AiPlannerContextFingerprint {
  const AiPlannerContextFingerprint._();

  static String fromContext(AiPlannerContext context) {
    final trip = context.trip;
    final bookings = [...context.bookings]
      ..sort((a, b) => a.id.compareTo(b.id));
    final activities = [...context.activities]
      ..sort((a, b) => a.id.compareTo(b.id));

    return [
      trip.id,
      trip.startDate.toIso8601String(),
      trip.endDate.toIso8601String(),
      trip.budget.toStringAsFixed(2),
      for (final booking in bookings)
        [
          booking.id,
          booking.type.name,
          booking.status.name,
          booking.amount.toStringAsFixed(2),
          booking.currency,
          booking.metadata.toString(),
        ].join(':'),
      for (final activity in activities)
        [
          activity.id,
          activity.title,
          activity.scheduledAt?.toIso8601String() ?? '',
          activity.cost?.toStringAsFixed(2) ?? '',
          activity.status ?? '',
        ].join(':'),
      context.travelContext?.fingerprint ?? '',
    ].join('|');
  }

  static bool hasChanged(AiPlannerPlan plan, AiPlannerContext context) {
    return plan.contextFingerprint.isNotEmpty &&
        plan.contextFingerprint != fromContext(context);
  }
}

class _UnauthenticatedAiPlannerRepository implements AiPlannerRepository {
  const _UnauthenticatedAiPlannerRepository();

  @override
  Future<List<AiPlannerPlan>> getPlanHistory(String tripId) async {
    return const [];
  }

  @override
  Future<void> savePlan(AiPlannerPlan plan) async {}

  @override
  Stream<List<AiPlannerPlan>> watchPlanHistory(String tripId) {
    return Stream.value(const []);
  }
}
