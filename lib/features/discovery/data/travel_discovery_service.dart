import '../domain/travel_discovery_models.dart';

abstract interface class TravelDiscoveryService {
  Future<List<TravelDiscoveryResult>> search(TravelDiscoveryQuery query);
}

class DemoTravelDiscoveryService implements TravelDiscoveryService {
  const DemoTravelDiscoveryService();

  @override
  Future<List<TravelDiscoveryResult>> search(TravelDiscoveryQuery query) async {
    final destination =
        query.destination.trim().isEmpty ? 'Paris' : query.destination.trim();
    final origin = query.origin.trim().isEmpty ? 'LHR' : query.origin.trim();
    final currency = 'GBP';
    final start = query.startDate;
    final nights =
        query.endDate.difference(query.startDate).inDays.clamp(1, 14);

    return [
      TravelDiscoveryResult(
        id: 'demo-flight-fast-${origin.toUpperCase()}-$destination',
        category: DiscoveryCategory.flights,
        title: 'ITAREVO Air ${origin.toUpperCase()} to $destination',
        subtitle:
            'Direct flight · ${query.cabinClass} · ${query.travellers} traveller${query.travellers == 1 ? '' : 's'}',
        provider: 'ITAREVO Demo Flights',
        location: '$origin -> $destination',
        startTime: DateTime(start.year, start.month, start.day, 9, 20),
        endTime: DateTime(start.year, start.month, start.day, 11, 5),
        duration: '1h 45m',
        price: 138.0 * query.travellers,
        currency: currency,
        rating: 4.4,
        details:
            'Demo fare. Includes cabin baggage and free same-day trip linking.',
        metadata: {
          'airline': 'ITAREVO Air',
          'flightNumber': 'IT${start.day}20',
          'departure': origin.toUpperCase(),
          'arrival': destination,
          'stops': 0,
        },
      ),
      TravelDiscoveryResult(
        id: 'demo-flight-value-${origin.toUpperCase()}-$destination',
        category: DiscoveryCategory.flights,
        title: 'ValueJet ${origin.toUpperCase()} to $destination',
        subtitle: '1 stop · lower fare · ${query.cabinClass}',
        provider: 'ITAREVO Demo Flights',
        location: '$origin -> $destination',
        startTime: DateTime(start.year, start.month, start.day, 13, 10),
        endTime: DateTime(start.year, start.month, start.day, 16, 30),
        duration: '3h 20m',
        price: 94.0 * query.travellers,
        currency: currency,
        rating: 4.0,
        details: 'Demo fare. Best price but longer journey.',
        metadata: {
          'airline': 'ValueJet',
          'flightNumber': 'VJ${start.day}41',
          'departure': origin.toUpperCase(),
          'arrival': destination,
          'stops': 1,
        },
      ),
      TravelDiscoveryResult(
        id: 'demo-hotel-central-$destination',
        category: DiscoveryCategory.hotels,
        title: '$destination Central House',
        subtitle:
            '$nights nights · ${query.rooms} room${query.rooms == 1 ? '' : 's'} · breakfast available',
        provider: 'ITAREVO Demo Hotels',
        location: '$destination centre',
        startTime: DateTime(start.year, start.month, start.day, 15),
        endTime: DateTime(
            query.endDate.year, query.endDate.month, query.endDate.day, 11),
        duration: '$nights nights',
        price: 152.0 * nights * query.rooms,
        currency: currency,
        rating: 4.6,
        details:
            'Demo hotel result with central location, Wi-Fi and flexible cancellation.',
        metadata: {
          'hotelName': '$destination Central House',
          'city': destination,
          'roomType': 'Classic room',
          'amenities': 'Wi-Fi, Breakfast, Flexible cancellation',
        },
      ),
      TravelDiscoveryResult(
        id: 'demo-hotel-boutique-$destination',
        category: DiscoveryCategory.hotels,
        title: '$destination Boutique Stay',
        subtitle: '$nights nights · design hotel · near restaurants',
        provider: 'ITAREVO Demo Hotels',
        location: '$destination old town',
        startTime: DateTime(start.year, start.month, start.day, 15),
        endTime: DateTime(
            query.endDate.year, query.endDate.month, query.endDate.day, 11),
        duration: '$nights nights',
        price: 118.0 * nights * query.rooms,
        currency: currency,
        rating: 4.3,
        details:
            'Demo hotel result. Lower total price with compact rooms and strong location.',
        metadata: {
          'hotelName': '$destination Boutique Stay',
          'city': destination,
          'roomType': 'Compact double',
          'amenities': 'Wi-Fi, Walkable area',
        },
      ),
      TravelDiscoveryResult(
        id: 'demo-transport-airport-$destination',
        category: DiscoveryCategory.transport,
        title: 'Airport transfer to hotel',
        subtitle:
            'Private transfer · ${query.travellers} passenger${query.travellers == 1 ? '' : 's'}',
        provider: 'ITAREVO Demo Transport',
        location: '$destination airport',
        startTime: DateTime(start.year, start.month, start.day, 11, 45),
        endTime: DateTime(start.year, start.month, start.day, 12, 25),
        duration: '40 min',
        price: 42.0 + (query.travellers * 3),
        currency: currency,
        rating: 4.5,
        details:
            'Demo ground transport option. Estimated fare, not live availability.',
        metadata: {
          'providerName': 'ITAREVO Transfer',
          'pickup': '$destination airport',
          'destination': '$destination hotel area',
        },
      ),
      TravelDiscoveryResult(
        id: 'demo-activity-${query.interest}-$destination',
        category: DiscoveryCategory.activities,
        title: '${_titleCase(query.interest)} highlights walk',
        subtitle: 'Guided local experience · flexible start',
        provider: 'ITAREVO Demo Experiences',
        location: '$destination centre',
        startTime: DateTime(
            start.year, start.month, start.day + (nights > 1 ? 1 : 0), 10),
        endTime: DateTime(
            start.year, start.month, start.day + (nights > 1 ? 1 : 0), 12),
        duration: '2h',
        price: 28.0 * query.travellers,
        currency: currency,
        rating: 4.7,
        details:
            'Demo attraction suggestion based on your selected interest. Add it directly to trip activities.',
        metadata: {
          'category': query.interest,
        },
      ),
      TravelDiscoveryResult(
        id: 'demo-restaurant-${query.cuisine}-$destination',
        category: DiscoveryCategory.restaurants,
        title: '${_titleCase(query.cuisine)} table near the centre',
        subtitle: 'Restaurant visit · typical availability varies',
        provider: 'ITAREVO Demo Restaurants',
        location: '$destination dining district',
        startTime: DateTime(start.year, start.month, start.day, 19, 30),
        endTime: DateTime(start.year, start.month, start.day, 21),
        duration: '1h 30m',
        price: 34.0 * query.travellers,
        currency: currency,
        rating: 4.4,
        details:
            'Demo restaurant suggestion. This is not live reservation availability.',
        metadata: {
          'cuisine': query.cuisine,
          'priceLevel': '££',
          'opening': 'Typical dinner hours',
        },
      ),
    ];
  }

  String _titleCase(String value) {
    if (value.isEmpty) {
      return 'Local';
    }
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}
