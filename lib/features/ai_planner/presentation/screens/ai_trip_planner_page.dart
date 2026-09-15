import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/user_facing_error.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/booking.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../trips/domain/entities/trip.dart';
import '../../../trips/domain/entities/trip_activity.dart';
import '../../../trips/presentation/providers/trip_activity_provider.dart';
import '../../../trips/presentation/providers/trip_bookings_provider.dart';
import '../../../weather/providers/weather_provider.dart';
import '../../../saved_items/presentation/providers/saved_items_provider.dart';
import '../../../trip_readiness/presentation/providers/trip_readiness_provider.dart';
import '../../../ai/domain/ai_travel_context.dart';
import '../../domain/ai_planner_models.dart';
import '../providers/ai_planner_provider.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class AiTripPlannerPage extends ConsumerWidget {
  const AiTripPlannerPage({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(tripActivitiesProvider(trip.id)).valueOrNull ??
        const <TripActivity>[];
    final bookings = ref.watch(tripBookingsProvider(trip.id)).valueOrNull ??
        const <Booking>[];
    final expenses = ref.watch(tripExpensesProvider(trip.id)).valueOrNull ??
        const <Expense>[];
    final weather = ref.watch(weatherProvider(trip.destination)).valueOrNull;
    final savedItems =
        ref.watch(savedItemsControllerProvider).valueOrNull ?? const [];
    final readiness = ref.watch(tripReadinessSummaryProvider(trip.id));
    final preferences = ref.watch(aiPlannerPreferencesProvider(trip.id));
    final planState = ref.watch(aiPlannerControllerProvider(trip.id));
    final historyState = ref.watch(aiPlannerHistoryProvider(trip.id));
    final latestPersistedPlan = historyState.valueOrNull?.isEmpty == false
        ? historyState.valueOrNull!.first
        : null;
    final activePlan = planState.valueOrNull;
    final currentContext = AiPlannerContext(
      trip: trip,
      activities: activities,
      bookings: bookings,
      expenses: expenses,
      preferences: preferences,
      travelContext: AiTravelContext.fromTripData(
        trip: trip,
        activities: activities,
        bookings: bookings,
        expenses: expenses,
        eventSummaries: [
          ...bookings
              .map((booking) => '${booking.type.name} ${booking.status.name}'),
          ...activities.where((activity) => activity.scheduledAt != null).map(
              (activity) => '${activity.title} at ${activity.scheduledAt}'),
        ],
        savedPlaces: savedItems
            .where((item) => item.isTripActivity)
            .map((item) => item.title)
            .toList(growable: false),
        weatherSummary: weather == null
            ? null
            : '${weather.description}, ${weather.tempC.toStringAsFixed(0)}°C',
        readinessSummary:
            '${readiness.completedCount}/${readiness.totalCount} tasks complete',
      ),
    );
    final contextChanged = activePlan != null &&
        AiPlannerContextFingerprint.hasChanged(activePlan, currentContext);

    if (activePlan == null && latestPersistedPlan != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(aiPlannerControllerProvider(trip.id).notifier)
            .setActivePlan(latestPersistedPlan);
        ref
            .read(aiPlannerPreferencesProvider(trip.id).notifier)
            .restore(latestPersistedPlan.preferences);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.ui('aiTravelPlanner')),
        actions: [
          TextButton.icon(
            onPressed: () => _generate(
              ref,
              activities: activities,
              bookings: bookings,
              expenses: expenses,
              preferences: preferences,
              travelContext: currentContext.travelContext,
              prompt: 'Replan with latest trip context',
            ),
            icon: const Icon(Icons.autorenew),
            label: Text(context.ui('replan')),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TripContextCard(
            trip: trip,
            activities: activities,
            bookings: bookings,
            expenses: expenses,
          ),
          const SizedBox(height: 12),
          _PreferencesCard(
            tripId: trip.id,
            preferences: preferences,
            onChanged: (updated) {
              ref
                  .read(aiPlannerPreferencesProvider(trip.id).notifier)
                  .update(updated);
            },
          ),
          const SizedBox(height: 12),
          _PromptActions(
            onPrompt: (prompt) => _generate(
              ref,
              activities: activities,
              bookings: bookings,
              expenses: expenses,
              preferences: _preferencesForPrompt(preferences, prompt),
              prompt: prompt,
              travelContext: currentContext.travelContext,
            ),
          ),
          const SizedBox(height: 12),
          if (contextChanged) ...[
            _TripChangedBanner(
              onUpdatePlan: () => _generate(
                ref,
                activities: activities,
                bookings: bookings,
                expenses: expenses,
                preferences: preferences,
                prompt: 'Update plan after trip context changed',
                travelContext: currentContext.travelContext,
              ),
            ),
            const SizedBox(height: 12),
          ],
          FilledButton.icon(
            onPressed: () => _generate(
              ref,
              activities: activities,
              bookings: bookings,
              expenses: expenses,
              preferences: preferences,
              travelContext: currentContext.travelContext,
            ),
            icon: const Icon(Icons.auto_awesome),
            label: Text(context.ui('generatePlan')),
          ),
          const SizedBox(height: 16),
          historyState.when(
            data: (history) => _PlanHistoryCard(
              activePlanId: activePlan?.id,
              history: history,
              onRestore: (plan) async {
                await ref
                    .read(aiPlannerControllerProvider(trip.id).notifier)
                    .restorePlan(plan);
                ref
                    .read(aiPlannerPreferencesProvider(trip.id).notifier)
                    .restore(plan.preferences);
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          planState.when(
            data: (plan) {
              if (plan == null) {
                return const _EmptyPlannerState();
              }
              return _GeneratedPlanView(trip: trip, plan: plan);
            },
            loading: () => const _PlannerLoadingState(),
            error: (error, _) => _PlannerErrorState(
              message: UserFacingError.message(
                error,
                fallback: 'The planner could not generate a plan. Try again.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generate(
    WidgetRef ref, {
    required List<TripActivity> activities,
    required List<Booking> bookings,
    required List<Expense> expenses,
    required AiPlannerPreferences preferences,
    AiTravelContext? travelContext,
    String? prompt,
  }) {
    return ref.read(aiPlannerControllerProvider(trip.id).notifier).generate(
          AiPlannerContext(
            trip: trip,
            activities: activities,
            bookings: bookings,
            expenses: expenses,
            preferences: preferences,
            prompt: prompt,
            travelContext: travelContext,
          ),
        );
  }

  AiPlannerPreferences _preferencesForPrompt(
    AiPlannerPreferences preferences,
    String prompt,
  ) {
    final lower = prompt.toLowerCase();
    return preferences.copyWith(
      cheaperPlan: lower.contains('cheaper'),
      rainyDay: lower.contains('rainy'),
    );
  }
}

class _TripContextCard extends StatelessWidget {
  const _TripContextCard({
    required this.trip,
    required this.activities,
    required this.bookings,
    required this.expenses,
  });

  final Trip trip;
  final List<TripActivity> activities;
  final List<Booking> bookings;
  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy');
    final spent =
        expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    final booked =
        bookings.fold<double>(0, (sum, booking) => sum + booking.amount);
    final remaining = trip.budget - spent - booked;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trip.destination,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
                '${formatter.format(trip.startDate)} - ${formatter.format(trip.endDate)}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ContextChip(
                  icon: Icons.group_outlined,
                  label: '${trip.travellers} travellers',
                ),
                _ContextChip(
                  icon: Icons.event_note_outlined,
                  label: '${activities.length} itinerary items',
                ),
                _ContextChip(
                  icon: Icons.confirmation_num_outlined,
                  label: '${bookings.length} bookings',
                ),
                _ContextChip(
                  icon: Icons.account_balance_wallet_outlined,
                  label:
                      '${trip.currency} ${remaining.clamp(0, trip.budget).toStringAsFixed(0)} remaining',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({
    required this.tripId,
    required this.preferences,
    required this.onChanged,
  });

  final String tripId;
  final AiPlannerPreferences preferences;
  final ValueChanged<AiPlannerPreferences> onChanged;

  static const _interests = <String>[
    'food',
    'culture',
    'nightlife',
    'family',
    'relaxation',
    'shopping',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Planning Preferences',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final interest in _interests)
                  FilterChip(
                    label: Text(interest),
                    selected: preferences.interests.contains(interest),
                    onSelected: (selected) {
                      final next = {...preferences.interests};
                      selected ? next.add(interest) : next.remove(interest);
                      onChanged(preferences.copyWith(interests: next));
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<AiPlannerPace>(
              segments: [
                ButtonSegment(
                  value: AiPlannerPace.relaxed,
                  icon: Icon(Icons.spa_outlined),
                  label: Text(context.ui('relaxed')),
                ),
                ButtonSegment(
                  value: AiPlannerPace.balanced,
                  icon: Icon(Icons.balance_outlined),
                  label: Text(context.ui('balanced')),
                ),
                ButtonSegment(
                  value: AiPlannerPace.packed,
                  icon: Icon(Icons.directions_run),
                  label: Text(context.ui('packed')),
                ),
              ],
              selected: {preferences.pace},
              onSelectionChanged: (selection) {
                onChanged(preferences.copyWith(pace: selection.single));
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.ui('accessibilityAware')),
              value: preferences.accessibility,
              onChanged: (value) =>
                  onChanged(preferences.copyWith(accessibility: value)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.ui('familyFriendly')),
              value: preferences.familyFriendly,
              onChanged: (value) =>
                  onChanged(preferences.copyWith(familyFriendly: value)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptActions extends StatelessWidget {
  const _PromptActions({required this.onPrompt});

  final ValueChanged<String> onPrompt;

  @override
  Widget build(BuildContext context) {
    const prompts = [
      'What should I do today?',
      'Plan my afternoon',
      'Find something near my hotel',
      'Make today cheaper',
      'Give me a rainy-day plan',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contextual Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final prompt in prompts)
                  ActionChip(
                    avatar: const Icon(Icons.auto_awesome, size: 18),
                    label: Text(prompt),
                    onPressed: () => onPrompt(prompt),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneratedPlanView extends ConsumerWidget {
  const _GeneratedPlanView({required this.trip, required this.plan});

  final Trip trip;
  final AiPlannerPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatedAt = plan.updatedAt ?? plan.generatedAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome),
                const SizedBox(width: 12),
                Expanded(child: Text(plan.summary)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${plan.currency} ${plan.totalEstimatedCost.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'v${plan.version} updated ${DateFormat('dd MMM HH:mm').format(updatedAt)}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final day in plan.days) _DayPlanCard(tripId: trip.id, day: day),
      ],
    );
  }
}

class _DayPlanCard extends ConsumerWidget {
  const _DayPlanCard({required this.tripId, required this.day});

  final String tripId;
  final AiPlannerDayPlan day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = DateFormat('EEE d MMM');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${formatter.format(day.date)} - ${day.theme}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                Text('${day.estimatedCost.toStringAsFixed(0)} ${context.ui('estimatedAbbrev')}'),
              ],
            ),
            const SizedBox(height: 8),
            for (final suggestion in day.suggestions)
              _SuggestionTile(tripId: tripId, suggestion: suggestion),
          ],
        ),
      ),
    );
  }
}

class _SuggestionTile extends ConsumerWidget {
  const _SuggestionTile({required this.tripId, required this.suggestion});

  final String tripId;
  final AiPlannerSuggestion suggestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = DateFormat('HH:mm').format(suggestion.startTime);
    final accepted = suggestion.status == AiPlannerSuggestionStatus.accepted;
    final rejected = suggestion.status == AiPlannerSuggestionStatus.rejected;

    return Opacity(
      opacity: rejected ? 0.55 : 1,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(child: Text(time)),
        title: Text(suggestion.title),
        subtitle: Text(
          '${suggestion.location} | ${suggestion.durationMinutes} min | ${suggestion.currency} ${suggestion.estimatedCost.toStringAsFixed(0)}\n${suggestion.notes}',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          enabled: !accepted,
          onSelected: (value) async {
            final controller =
                ref.read(aiPlannerControllerProvider(tripId).notifier);
            if (value == 'accept') {
              await controller.acceptSuggestion(suggestion);
            } else if (value == 'reject') {
              await controller.rejectSuggestion(suggestion.id);
            } else if (value == 'replace') {
              await controller.replaceSuggestion(suggestion.id);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'accept', child: Text(context.ui('acceptAndAdd'))),
            PopupMenuItem(value: 'replace', child: Text(context.ui('replace'))),
            PopupMenuItem(value: 'reject', child: Text(context.ui('reject'))),
          ],
          child: accepted
              ? Chip(
                  avatar: const Icon(Icons.check, size: 18),
                  label: Text(context.ui('added')),
                )
              : const Icon(Icons.more_vert),
        ),
      ),
    );
  }
}

class _TripChangedBanner extends StatelessWidget {
  const _TripChangedBanner({required this.onUpdatePlan});

  final VoidCallback onUpdatePlan;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.change_circle_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(context.ui('tripChangedUpdatePlan')),
            ),
            FilledButton(
              onPressed: onUpdatePlan,
              child: Text(context.ui('update')),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanHistoryCard extends StatelessWidget {
  const _PlanHistoryCard({
    required this.activePlanId,
    required this.history,
    required this.onRestore,
  });

  final String? activePlanId;
  final List<AiPlannerPlan> history;
  final ValueChanged<AiPlannerPlan> onRestore;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            for (final plan in history.take(5))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text('v${plan.version}')),
                title: Text(
                  DateFormat('dd MMM yyyy, HH:mm')
                      .format(plan.updatedAt ?? plan.generatedAt),
                ),
                subtitle: Text(
                  '${plan.currency} ${plan.totalEstimatedCost.toStringAsFixed(0)} estimated · ${_planSourceLabel(plan.source)}',
                ),
                trailing: activePlanId == plan.id
                    ? Chip(label: Text(context.ui('current')))
                    : TextButton(
                        onPressed: () => onRestore(plan),
                        child: Text(context.ui('restore')),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

String _planSourceLabel(String source) {
  final normalized = source.toLowerCase();
  if (normalized.contains('live') || normalized.contains('backend')) {
    return source;
  }
  return 'Local demo plan';
}

class _ContextChip extends StatelessWidget {
  const _ContextChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _EmptyPlannerState extends StatelessWidget {
  const _EmptyPlannerState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Generate a day-by-day plan using this trip, bookings, budget and existing itinerary.',
        ),
      ),
    );
  }
}

class _PlannerLoadingState extends StatelessWidget {
  const _PlannerLoadingState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(),
            SizedBox(height: 12),
            Text(context.ui('buildingTripAwareItinerary')),
          ],
        ),
      ),
    );
  }
}

class _PlannerErrorState extends StatelessWidget {
  const _PlannerErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('${context.ui('plannerFailed')}: $message'),
      ),
    );
  }
}
