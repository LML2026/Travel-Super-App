import '../../features/trips/models/itinerary/itinerary_item.dart';
import '../../features/trips/models/trip.dart';
import '../itinerary_ordering.dart';

enum TripOverviewStatus { upcoming, inProgress, completed }

class TripOverviewDay {
  final DateTime date;
  final List<ItineraryItem> items;

  const TripOverviewDay({required this.date, required this.items});
}

class TripOverviewSummary {
  final Trip trip;
  final List<ItineraryItem> orderedItems;
  final List<TripOverviewDay> days;
  final TripOverviewStatus status;
  final int durationDays;
  final int? daysUntilStart;
  final int planCount;
  final int bookedCount;
  final double estimatedCost;
  final bool hasEstimatedCost;
  final int mappedCount;
  final ItineraryItem? nextPlan;

  const TripOverviewSummary({
    required this.trip,
    required this.orderedItems,
    required this.days,
    required this.status,
    required this.durationDays,
    required this.daysUntilStart,
    required this.planCount,
    required this.bookedCount,
    required this.estimatedCost,
    required this.hasEstimatedCost,
    required this.mappedCount,
    required this.nextPlan,
  });

  double? get budgetProgress =>
      trip.budget > 0 && hasEstimatedCost ? estimatedCost / trip.budget : null;

  double get overBudget => trip.budget > 0 && estimatedCost > trip.budget
      ? estimatedCost - trip.budget
      : 0;
}

class TripOverviewService {
  const TripOverviewService._();

  static TripOverviewSummary build({
    required Trip trip,
    required List<ItineraryItem> items,
    required DateTime now,
  }) {
    final orderedItems = orderItineraryItems(items);
    final today = _day(now);
    final departure = _day(trip.departureDate);
    final returnDate = _day(trip.returnDate);
    final status = today.isBefore(departure)
        ? TripOverviewStatus.upcoming
        : today.isAfter(returnDate)
        ? TripOverviewStatus.completed
        : TripOverviewStatus.inProgress;
    final grouped = <DateTime, List<ItineraryItem>>{};

    for (final item in orderedItems) {
      grouped.putIfAbsent(_day(item.date), () => []).add(item);
    }

    final days = grouped.entries
        .map((entry) => TripOverviewDay(date: entry.key, items: entry.value))
        .toList(growable: false);
    final estimatedItems = orderedItems.where(
      (item) => item.estimatedCost != null,
    );
    final estimatedCost = estimatedItems.fold<double>(
      0,
      (total, item) => total + item.estimatedCost!,
    );

    return TripOverviewSummary(
      trip: trip,
      orderedItems: orderedItems,
      days: days,
      status: status,
      durationDays: returnDate.difference(departure).inDays + 1,
      daysUntilStart: status == TripOverviewStatus.upcoming
          ? departure.difference(today).inDays
          : null,
      planCount: orderedItems.length,
      bookedCount: orderedItems.where((item) => item.isBooked).length,
      estimatedCost: estimatedCost,
      hasEstimatedCost: estimatedItems.isNotEmpty,
      mappedCount: orderedItems
          .where((item) => item.latitude != null && item.longitude != null)
          .length,
      nextPlan: _nextPlan(orderedItems, status, now),
    );
  }

  static ItineraryItem? _nextPlan(
    List<ItineraryItem> orderedItems,
    TripOverviewStatus status,
    DateTime now,
  ) {
    if (orderedItems.isEmpty || status == TripOverviewStatus.completed) {
      return null;
    }

    final chronologicalItems = List<ItineraryItem>.from(orderedItems);
    final existingPositions = <String, int>{
      for (var index = 0; index < chronologicalItems.length; index++)
        chronologicalItems[index].id: index,
    };

    chronologicalItems.sort((first, second) {
      final dateComparison = _day(first.date).compareTo(_day(second.date));
      if (dateComparison != 0) return dateComparison;

      final timeComparison = (first.time ?? '').compareTo(second.time ?? '');
      if (timeComparison != 0) return timeComparison;

      return existingPositions[first.id]!.compareTo(
        existingPositions[second.id]!,
      );
    });

    if (status == TripOverviewStatus.upcoming) {
      return chronologicalItems.first;
    }

    final today = _day(now);

    for (final item in chronologicalItems) {
      final itemDay = _day(item.date);
      if (itemDay.isAfter(today)) return item;
      if (itemDay != today) continue;

      final itemTime = _dateTimeFor(item);
      if (itemTime == null || !itemTime.isBefore(now)) return item;
    }

    return null;
  }

  static DateTime? _dateTimeFor(ItineraryItem item) {
    final value = item.time;
    if (value == null) return null;

    final parts = value.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    return DateTime(
      item.date.year,
      item.date.month,
      item.date.day,
      hour,
      minute,
    );
  }

  static DateTime _day(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
