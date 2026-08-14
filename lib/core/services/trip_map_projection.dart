import '../../features/trips/models/itinerary/itinerary_item.dart';
import '../itinerary_ordering.dart';

class TripMapRoutePair {
  final ItineraryItem origin;
  final ItineraryItem destination;
  final String key;

  const TripMapRoutePair({
    required this.origin,
    required this.destination,
    required this.key,
  });
}

class TripMapProjection {
  final List<ItineraryItem> orderedItems;
  final List<ItineraryItem> mappedItems;
  final List<TripMapRoutePair> routePairs;

  const TripMapProjection({
    required this.orderedItems,
    required this.mappedItems,
    required this.routePairs,
  });

  factory TripMapProjection.fromItems(Iterable<ItineraryItem> source) {
    final orderedItems = orderItineraryItems(source);
    final mappedItems = orderedItems.where(hasValidCoordinates).toList();
    final itemsByDay = <DateTime, List<ItineraryItem>>{};

    for (final item in orderedItems) {
      itemsByDay.putIfAbsent(itineraryDay(item.date), () => []).add(item);
    }

    final routePairs = <TripMapRoutePair>[];
    var pairIndex = 0;

    for (final dayItems in itemsByDay.values) {
      for (var index = 0; index < dayItems.length - 1; index++) {
        final origin = dayItems[index];
        final destination = dayItems[index + 1];

        if (!hasValidCoordinates(origin) || !hasValidCoordinates(destination)) {
          continue;
        }

        routePairs.add(
          TripMapRoutePair(
            origin: origin,
            destination: destination,
            key: '${origin.id}|${destination.id}|${pairIndex++}',
          ),
        );
      }
    }

    return TripMapProjection(
      orderedItems: orderedItems,
      mappedItems: mappedItems,
      routePairs: routePairs,
    );
  }

  static bool hasValidCoordinates(ItineraryItem item) {
    final latitude = item.latitude;
    final longitude = item.longitude;

    return latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  static String markerKey(ItineraryItem item, int index) => '${item.id}|$index';
}
