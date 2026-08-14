import 'dart:math' as math;

import '../../features/trips/models/itinerary/itinerary_item.dart';
import '../itinerary_ordering.dart';
import 'route_service.dart';

typedef OptimizationRouteLookup =
    Future<RouteResult?> Function(
      ItineraryItem origin,
      ItineraryItem destination,
      TravelMode travelMode,
    );

class ItineraryOptimizationResult {
  final List<ItineraryItem> currentDayItems;
  final List<ItineraryItem> suggestedDayItems;
  final int? currentDurationMinutes;
  final int? suggestedDurationMinutes;

  const ItineraryOptimizationResult({
    required this.currentDayItems,
    required this.suggestedDayItems,
    required this.currentDurationMinutes,
    required this.suggestedDurationMinutes,
  });

  bool get hasReliableDurations =>
      currentDurationMinutes != null && suggestedDurationMinutes != null;

  int? get savingMinutes => hasReliableDurations
      ? currentDurationMinutes! - suggestedDurationMinutes!
      : null;
}

class ItineraryOptimizer {
  const ItineraryOptimizer._();

  static Future<ItineraryOptimizationResult?> optimizeDay({
    required List<ItineraryItem> items,
    required DateTime day,
    required TravelMode travelMode,
    required OptimizationRouteLookup routeLookup,
  }) async {
    final targetDay = itineraryDay(day);
    final currentDayItems = orderItineraryItems(
      items.where((item) => itineraryDay(item.date) == targetDay),
    );
    final mappedItems = currentDayItems.where(_isMapped).toList();

    if (mappedItems.length < 3) return null;

    final suggestedMappedItems = <ItineraryItem>[mappedItems.first];
    final remaining = mappedItems.skip(1).toList();

    while (remaining.isNotEmpty) {
      final origin = suggestedMappedItems.last;
      ItineraryItem? best;
      double? bestCost;

      for (final candidate in remaining) {
        final route = await routeLookup(origin, candidate, travelMode);
        final cost =
            route?.durationMinutes.toDouble() ??
            _fallbackMinutes(origin, candidate, travelMode);

        if (best == null ||
            cost < bestCost! ||
            (cost == bestCost && candidate.id.compareTo(best.id) < 0)) {
          best = candidate;
          bestCost = cost;
        }
      }

      suggestedMappedItems.add(best!);
      remaining.remove(best);
    }

    final suggestedDayItems = List<ItineraryItem>.from(currentDayItems);
    var mappedIndex = 0;

    for (var index = 0; index < suggestedDayItems.length; index++) {
      if (_isMapped(suggestedDayItems[index])) {
        suggestedDayItems[index] = suggestedMappedItems[mappedIndex++];
      }
    }

    final currentDuration = await _totalReliableDuration(
      mappedItems,
      travelMode,
      routeLookup,
    );
    final suggestedDuration = await _totalReliableDuration(
      suggestedMappedItems,
      travelMode,
      routeLookup,
    );
    final suggestionIsSlower =
        currentDuration != null &&
        suggestedDuration != null &&
        suggestedDuration > currentDuration;

    return ItineraryOptimizationResult(
      currentDayItems: currentDayItems,
      suggestedDayItems: suggestionIsSlower
          ? currentDayItems
          : suggestedDayItems,
      currentDurationMinutes: currentDuration,
      suggestedDurationMinutes: suggestionIsSlower
          ? currentDuration
          : suggestedDuration,
    );
  }

  static Future<int?> _totalReliableDuration(
    List<ItineraryItem> mappedItems,
    TravelMode travelMode,
    OptimizationRouteLookup routeLookup,
  ) async {
    var total = 0;

    for (var index = 0; index < mappedItems.length - 1; index++) {
      final route = await routeLookup(
        mappedItems[index],
        mappedItems[index + 1],
        travelMode,
      );

      if (route == null) return null;
      total += route.durationMinutes;
    }

    return total;
  }

  static bool _isMapped(ItineraryItem item) =>
      item.latitude != null && item.longitude != null;

  static double _fallbackMinutes(
    ItineraryItem origin,
    ItineraryItem destination,
    TravelMode travelMode,
  ) {
    final metres = _straightLineMetres(origin, destination);
    final metresPerMinute = travelMode == TravelMode.walking ? 80.0 : 500.0;
    return metres / metresPerMinute;
  }

  static double _straightLineMetres(
    ItineraryItem origin,
    ItineraryItem destination,
  ) {
    const earthRadiusMetres = 6371000.0;
    final firstLatitude = _radians(origin.latitude!);
    final secondLatitude = _radians(destination.latitude!);
    final latitudeDelta = _radians(destination.latitude! - origin.latitude!);
    final longitudeDelta = _radians(destination.longitude! - origin.longitude!);
    final a =
        math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
        math.cos(firstLatitude) *
            math.cos(secondLatitude) *
            math.sin(longitudeDelta / 2) *
            math.sin(longitudeDelta / 2);

    return earthRadiusMetres * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _radians(double degrees) => degrees * math.pi / 180;
}
