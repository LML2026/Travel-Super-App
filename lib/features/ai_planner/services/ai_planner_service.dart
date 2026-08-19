import '../domain/ai_planner_models.dart';

abstract interface class AiPlannerService {
  Future<AiPlannerPlan> generatePlan(AiPlannerContext context);
}

class LocalAiPlannerService implements AiPlannerService {
  const LocalAiPlannerService();

  @override
  Future<AiPlannerPlan> generatePlan(AiPlannerContext context) async {
    final trip = context.trip;
    final days = _tripDays(trip.startDate, trip.endDate);
    final existingSpend = context.expenses.fold<double>(
      0,
      (total, expense) => total + expense.amount,
    );
    final confirmedBookings = context.bookings
        .where((booking) => booking.status.name == 'confirmed')
        .fold<double>(0, (total, booking) => total + booking.amount);
    final remainingBudget = (trip.budget - existingSpend - confirmedBookings)
        .clamp(0, trip.budget)
        .toDouble();
    final perDayBudget =
        days.isEmpty ? remainingBudget : remainingBudget / days.length;
    final prompt = context.prompt?.toLowerCase() ?? '';
    final cheaper =
        context.preferences.cheaperPlan || prompt.contains('cheaper');
    final rainy = context.preferences.rainyDay || prompt.contains('rainy');
    final nearHotel = prompt.contains('hotel');
    final afternoonOnly = prompt.contains('afternoon');
    final todayOnly = prompt.contains('today');
    final suggestionsPerDay = _suggestionsPerDay(context.preferences.pace);
    final acceptedTitles = context.activities
        .where((activity) =>
            activity.status == 'AI planned' ||
            (activity.notes ?? '').contains('AI Planner suggestion'))
        .map((activity) => activity.title)
        .toSet();

    final plans = <AiPlannerDayPlan>[];
    for (var dayIndex = 0; dayIndex < days.length; dayIndex++) {
      final date = days[dayIndex];
      if (todayOnly && !_sameDay(date, DateTime.now())) {
        continue;
      }

      final baseTimes =
          afternoonOnly ? const <int>[13, 15, 17] : const <int>[9, 12, 15, 18];
      final suggestions = <AiPlannerSuggestion>[];
      var slotCursor = 0;

      for (var index = 0;
          index < suggestionsPerDay && slotCursor < baseTimes.length;
          index++) {
        var startTime = DateTime(
          date.year,
          date.month,
          date.day,
          baseTimes[slotCursor],
        );
        slotCursor++;

        startTime = _avoidConflict(startTime, context);
        var idea = _ideaFor(
          context,
          dayIndex: dayIndex,
          itemIndex: index,
          rainy: rainy,
          cheaper: cheaper,
          nearHotel: nearHotel,
        );
        var replacementOffset = 0;
        while (acceptedTitles.contains(idea.title) && replacementOffset < 4) {
          replacementOffset++;
          idea = _ideaFor(
            context,
            dayIndex: dayIndex,
            itemIndex: index + replacementOffset,
            rainy: rainy,
            cheaper: cheaper,
            nearHotel: nearHotel,
          );
        }
        final cost = _costFor(
          idea.category,
          perDayBudget,
          cheaper: cheaper,
          travellers: trip.travellers,
        );

        suggestions.add(
          AiPlannerSuggestion(
            id: 'local-${trip.id}-${date.toIso8601String()}-$index',
            title: idea.title,
            category: idea.category,
            location: idea.location,
            startTime: startTime,
            durationMinutes: idea.durationMinutes,
            estimatedCost: cost,
            currency: trip.currency,
            notes: _notesFor(context, idea, cheaper: cheaper, rainy: rainy),
          ),
        );
      }

      plans.add(
        AiPlannerDayPlan(
          date: date,
          theme: _themeFor(context, dayIndex, rainy: rainy, cheaper: cheaper),
          suggestions: suggestions,
        ),
      );
    }

    final dayPlans = plans.isEmpty
        ? [
            AiPlannerDayPlan(
              date: DateTime.now(),
              theme: 'Today near ${trip.destination}',
              suggestions: [
                AiPlannerSuggestion(
                  id: 'local-${trip.id}-today',
                  title: 'Low-effort local highlights',
                  category: 'activity',
                  location: trip.destination,
                  startTime: DateTime.now().add(const Duration(hours: 1)),
                  durationMinutes: 120,
                  estimatedCost:
                      cheaper ? 0 : (15 * trip.travellers).toDouble(),
                  currency: trip.currency,
                  notes: 'A flexible plan based on your current trip context.',
                ),
              ],
            ),
          ]
        : plans;

    final total = dayPlans.fold<double>(
      0,
      (sum, day) => sum + day.estimatedCost,
    );

    return AiPlannerPlan(
      generatedAt: DateTime.now(),
      summary:
          'Local planner built a ${dayPlans.length}-day plan for ${trip.destination} using trip dates, travellers, budget, bookings and itinerary context.',
      days: dayPlans,
      totalEstimatedCost: total,
      currency: trip.currency,
      source: 'local-demo',
    );
  }

  List<DateTime> _tripDays(DateTime start, DateTime end) {
    final first = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    final count = last.difference(first).inDays + 1;
    return [
      for (var index = 0; index < count.clamp(1, 14); index++)
        first.add(Duration(days: index)),
    ];
  }

  int _suggestionsPerDay(AiPlannerPace pace) {
    switch (pace) {
      case AiPlannerPace.relaxed:
        return 2;
      case AiPlannerPace.balanced:
        return 3;
      case AiPlannerPace.packed:
        return 4;
    }
  }

  DateTime _avoidConflict(DateTime proposed, AiPlannerContext context) {
    var resolved = proposed;
    for (final activity in context.activities) {
      final scheduled = activity.scheduledAt;
      if (scheduled == null || !_sameDay(scheduled, resolved)) {
        continue;
      }
      if ((scheduled.hour - resolved.hour).abs() < 2) {
        resolved = resolved.add(const Duration(hours: 2));
      }
    }

    for (final booking in context.bookings) {
      for (final raw in booking.metadata.values) {
        final parsed = DateTime.tryParse(raw.toString());
        if (parsed == null || !_sameDay(parsed, resolved)) {
          continue;
        }
        if ((parsed.hour - resolved.hour).abs() < 2) {
          resolved = resolved.add(const Duration(hours: 2));
        }
      }
    }
    return resolved;
  }

  _PlannerIdea _ideaFor(
    AiPlannerContext context, {
    required int dayIndex,
    required int itemIndex,
    required bool rainy,
    required bool cheaper,
    required bool nearHotel,
  }) {
    final destination = context.trip.destination;
    final interests = context.preferences.interests;
    final pool = <_PlannerIdea>[
      if (rainy)
        _PlannerIdea(
          title: '$destination covered market and gallery loop',
          category: 'rainy-day',
          location: nearHotel ? 'Near your hotel' : '$destination centre',
          durationMinutes: 150,
        ),
      if (cheaper)
        _PlannerIdea(
          title: '$destination free viewpoints and neighbourhood walk',
          category: 'free',
          location: nearHotel ? 'Hotel neighbourhood' : destination,
          durationMinutes: 120,
        ),
      if (interests.contains('food'))
        _PlannerIdea(
          title: 'Local food hall and signature snack stop',
          category: 'restaurant',
          location: nearHotel ? 'Near your hotel' : '$destination food quarter',
          durationMinutes: 90,
        ),
      if (interests.contains('culture'))
        _PlannerIdea(
          title: '$destination culture highlights route',
          category: 'culture',
          location: '$destination old town',
          durationMinutes: 150,
        ),
      if (interests.contains('nightlife'))
        _PlannerIdea(
          title: 'Evening music and cocktail district',
          category: 'nightlife',
          location: '$destination nightlife district',
          durationMinutes: 150,
        ),
      if (interests.contains('relaxation'))
        _PlannerIdea(
          title: 'Slow park, cafe and wellness break',
          category: 'relaxation',
          location: '$destination green space',
          durationMinutes: 120,
        ),
      if (interests.contains('shopping'))
        _PlannerIdea(
          title: 'Independent shops and design stores',
          category: 'shopping',
          location: '$destination shopping streets',
          durationMinutes: 120,
        ),
      _PlannerIdea(
        title: '$destination landmark walk',
        category: 'activity',
        location: destination,
        durationMinutes: 120,
      ),
      _PlannerIdea(
        title: 'Neighbourhood restaurant with local dishes',
        category: 'restaurant',
        location: '$destination centre',
        durationMinutes: 90,
      ),
    ];

    final offset = dayIndex * 2 + itemIndex;
    return pool[offset % pool.length];
  }

  double _costFor(
    String category,
    double perDayBudget, {
    required bool cheaper,
    required int travellers,
  }) {
    if (category == 'free') {
      return 0;
    }
    final base = switch (category) {
      'restaurant' => 22.0,
      'nightlife' => 28.0,
      'shopping' => 35.0,
      'rainy-day' => 18.0,
      'culture' => 16.0,
      _ => 12.0,
    };
    final scaled = base * travellers * (cheaper ? 0.55 : 1);
    final cap = perDayBudget <= 0 ? scaled : perDayBudget * 0.55;
    return scaled.clamp(0, cap).roundToDouble();
  }

  String _themeFor(
    AiPlannerContext context,
    int dayIndex, {
    required bool rainy,
    required bool cheaper,
  }) {
    if (rainy) {
      return 'Rainy-day comfort plan';
    }
    if (cheaper) {
      return 'Budget-conscious local day';
    }
    final interests = context.preferences.interests.toList(growable: false);
    if (interests.isEmpty) {
      return 'Balanced discovery day ${dayIndex + 1}';
    }
    return '${interests[dayIndex % interests.length]} discovery day';
  }

  String _notesFor(
    AiPlannerContext context,
    _PlannerIdea idea, {
    required bool cheaper,
    required bool rainy,
  }) {
    final parts = <String>[
      'Recommended for ${context.trip.travellers} traveller${context.trip.travellers == 1 ? '' : 's'}.',
      if (cheaper) 'Prioritises lower-cost choices.',
      if (rainy) 'Keeps most of the plan indoors or weather-flexible.',
      if (context.preferences.familyFriendly) 'Family-friendly pacing applied.',
      if (context.preferences.accessibility)
        'Choose step-free routes and accessible venues where available.',
      'Category: ${idea.category}.',
    ];
    return parts.join(' ');
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _PlannerIdea {
  const _PlannerIdea({
    required this.title,
    required this.category,
    required this.location,
    required this.durationMinutes,
  });

  final String title;
  final String category;
  final String location;
  final int durationMinutes;
}
