import '../features/trips/models/itinerary/itinerary_item.dart';

List<ItineraryItem> orderItineraryItems(Iterable<ItineraryItem> source) {
  final items = source.toList();
  final completeOrderByDay = <DateTime, bool>{};
  final originalPositions = <String, int>{
    for (var index = 0; index < items.length; index++) items[index].id: index,
  };

  for (final item in items) {
    final day = itineraryDay(item.date);
    completeOrderByDay[day] =
        (completeOrderByDay[day] ?? true) && item.orderIndex != null;
  }

  items.sort((first, second) {
    final firstDay = itineraryDay(first.date);
    final secondDay = itineraryDay(second.date);
    final dateComparison = firstDay.compareTo(secondDay);

    if (dateComparison != 0) return dateComparison;

    if (completeOrderByDay[firstDay] == true) {
      final orderComparison = first.orderIndex!.compareTo(second.orderIndex!);
      if (orderComparison != 0) return orderComparison;
    }

    final timeComparison = (first.time ?? '').compareTo(second.time ?? '');
    if (timeComparison != 0) return timeComparison;

    return originalPositions[first.id]!.compareTo(
      originalPositions[second.id]!,
    );
  });

  return items;
}

DateTime itineraryDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);
