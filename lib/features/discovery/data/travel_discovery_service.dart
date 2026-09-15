import '../domain/travel_discovery_models.dart';
import '../../flights/models/flight.dart';
import '../../flights/services/flight_service.dart';
import '../../hotels/models/hotel.dart';
import '../../hotels/models/hotel_search_request.dart';
import '../../hotels/services/hotel_api_service.dart';
import '../../nearby/models/nearby_service_result.dart';
import '../../nearby/models/nearby_service_type.dart';
import '../../nearby/services/nearby_places_service.dart';

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

class ProviderTravelDiscoveryService implements TravelDiscoveryService {
  ProviderTravelDiscoveryService({
    FlightService? flightService,
    HotelApiService? hotelService,
    NearbyPlacesService? nearbyService,
    DemoTravelDiscoveryService? fallbackService,
    Future<List<Flight>> Function(TravelDiscoveryQuery query)? flightSearch,
    Future<List<Hotel>> Function(HotelSearchRequest request)? hotelSearch,
  })  : _flightService = flightService ?? FlightService(),
        _hotelService = hotelService ?? HotelApiService(),
        _nearbyService = nearbyService,
        _fallbackService =
            fallbackService ?? const DemoTravelDiscoveryService(),
        _flightSearch = flightSearch,
        _hotelSearch = hotelSearch;

  final FlightService _flightService;
  final HotelApiService _hotelService;
  final NearbyPlacesService? _nearbyService;
  final DemoTravelDiscoveryService _fallbackService;
  final Future<List<Flight>> Function(TravelDiscoveryQuery query)?
      _flightSearch;
  final Future<List<Hotel>> Function(HotelSearchRequest request)? _hotelSearch;

  @override
  Future<List<TravelDiscoveryResult>> search(TravelDiscoveryQuery query) async {
    final fallback = await _fallbackService.search(query);
    final results = <TravelDiscoveryResult>[];
    results.addAll(await _searchFlights(query, fallback));
    results.addAll(await _searchHotels(query, fallback));
    results.addAll(await _searchPlaces(query, fallback));
    results.addAll(_byCategory(fallback, DiscoveryCategory.transport));
    return results;
  }

  Future<List<TravelDiscoveryResult>> _searchFlights(
    TravelDiscoveryQuery query,
    List<TravelDiscoveryResult> fallback,
  ) async {
    try {
      final flights = await (_flightSearch?.call(query) ??
          _flightService.searchFlights(
            from: query.origin,
            to: query.destination,
            departureDate: _date(query.startDate),
            returnDate: _date(query.endDate),
            passengers: query.travellers,
            cabinClass: query.cabinClass,
          ));
      if (flights.isNotEmpty) {
        final markFallback =
            _flightSearch == null && _flightService.lastSearchUsedFallback;
        return flights
            .map((flight) => _flightResult(
                  flight,
                  sourceOverride:
                      markFallback ? DiscoveryDataSource.fallback : null,
                ))
            .toList(growable: false);
      }
    } catch (_) {
      return _markFallback(fallback, DiscoveryCategory.flights);
    }
    return _markFallback(fallback, DiscoveryCategory.flights);
  }

  Future<List<TravelDiscoveryResult>> _searchHotels(
    TravelDiscoveryQuery query,
    List<TravelDiscoveryResult> fallback,
  ) async {
    final request = HotelSearchRequest(
      city: query.destination,
      checkInDate: query.startDate,
      checkOutDate: query.endDate,
      guests: query.travellers,
      rooms: query.rooms,
    );
    try {
      final hotels = await (_hotelSearch?.call(request) ??
          _hotelService.searchHotels(request));
      if (hotels.isNotEmpty) {
        final markFallback =
            _hotelSearch == null && _hotelService.lastSearchUsedFallback;
        return hotels
            .map((hotel) => _hotelResult(
                  hotel,
                  sourceOverride:
                      markFallback ? DiscoveryDataSource.fallback : null,
                ))
            .toList(growable: false);
      }
    } catch (_) {
      return _markFallback(fallback, DiscoveryCategory.hotels);
    }
    return _markFallback(fallback, DiscoveryCategory.hotels);
  }

  Future<List<TravelDiscoveryResult>> _searchPlaces(
    TravelDiscoveryQuery query,
    List<TravelDiscoveryResult> fallback,
  ) async {
    final service = _nearbyService;
    if (service == null) {
      return _markFallback(fallback, DiscoveryCategory.activities) +
          _markFallback(fallback, DiscoveryCategory.restaurants);
    }
    try {
      final places = [
        ...await service.search(NearbyPlacesQuery(
          location: query.destination,
          serviceType: NearbyServiceType.attraction,
          limit: 6,
        )),
        ...await service.search(NearbyPlacesQuery(
          location: query.destination,
          serviceType: NearbyServiceType.restaurant,
          limit: 6,
        )),
      ];
      if (places.isNotEmpty) {
        return places.map((place) => _placeResult(place, query)).toList();
      }
    } catch (_) {
      // Fall through to deterministic activity and restaurant suggestions.
    }
    return _markFallback(fallback, DiscoveryCategory.activities) +
        _markFallback(fallback, DiscoveryCategory.restaurants);
  }

  TravelDiscoveryResult _flightResult(
    Flight flight, {
    DiscoveryDataSource? sourceOverride,
  }) {
    return TravelDiscoveryResult(
      id: flight.id,
      category: DiscoveryCategory.flights,
      title: '${flight.airline} ${flight.flightNumber}',
      subtitle:
          '${flight.origin} -> ${flight.destination} · ${flight.stops == 0 ? 'Direct' : '${flight.stops} stop'} · ${flight.cabinClass}',
      provider: _flightProvider(flight.dataSource),
      location: '${flight.origin} -> ${flight.destination}',
      startTime: DateTime.tryParse(flight.departureAt) ?? DateTime.now(),
      endTime: DateTime.tryParse(flight.arrivalAt) ?? DateTime.now(),
      duration: flight.duration,
      price: flight.amount,
      currency: flight.currency,
      rating: 0,
      details: 'Flight offer from ${_flightProvider(flight.dataSource)}.',
      source: sourceOverride ?? _flightSource(flight.dataSource),
      metadata: {
        'airline': flight.airline,
        'airlineLogo': flight.airlineLogo,
        'flightNumber': flight.flightNumber,
        'departure': flight.origin,
        'arrival': flight.destination,
        'stops': flight.stops,
        'cabinClass': flight.cabinClass,
      },
    );
  }

  TravelDiscoveryResult _hotelResult(
    Hotel hotel, {
    DiscoveryDataSource? sourceOverride,
  }) {
    return TravelDiscoveryResult(
      id: hotel.id,
      category: DiscoveryCategory.hotels,
      title: hotel.name,
      subtitle: '${hotel.nights} nights · ${hotel.city}',
      provider: _hotelProvider(hotel.dataSource),
      location: hotel.address,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(Duration(days: hotel.nights)),
      duration: '${hotel.nights} nights',
      price: hotel.totalPrice,
      currency: hotel.currency,
      rating: hotel.rating,
      details: hotel.description,
      source: sourceOverride ?? _hotelSource(hotel.dataSource),
      metadata: {
        'hotelName': hotel.name,
        'city': hotel.city,
        'image': hotel.image,
        'roomType': hotel.roomType,
        'amenities': hotel.amenities,
      },
    );
  }

  TravelDiscoveryResult _placeResult(
    NearbyServiceResult place,
    TravelDiscoveryQuery query,
  ) {
    final category = place.serviceType == NearbyServiceType.restaurant
        ? DiscoveryCategory.restaurants
        : DiscoveryCategory.activities;
    final source = switch (place.source) {
      NearbyDataSource.google => DiscoveryDataSource.live,
      NearbyDataSource.backend => DiscoveryDataSource.backend,
      _ => DiscoveryDataSource.fallback,
    };
    return TravelDiscoveryResult(
      id: place.id,
      category: category,
      title: place.name,
      subtitle: '${place.categoryLabel} · ${place.address}',
      provider: place.sourceMetadata['provider']?.toString() ?? source.label,
      location: place.address,
      startTime: DateTime(
          query.startDate.year,
          query.startDate.month,
          query.startDate.day,
          category == DiscoveryCategory.restaurants ? 19 : 10),
      endTime: DateTime(
          query.startDate.year,
          query.startDate.month,
          query.startDate.day,
          category == DiscoveryCategory.restaurants ? 21 : 12),
      duration: category == DiscoveryCategory.restaurants ? '2h' : '2h',
      price: 0,
      currency: 'GBP',
      rating: place.rating ?? 0,
      details: place.metadata['description']?.toString() ??
          'Place details from ${source.label}.',
      source: source,
      metadata: {
        'latitude': place.latitude,
        'longitude': place.longitude,
        'category': place.categoryLabel,
      },
    );
  }

  List<TravelDiscoveryResult> _markFallback(
    List<TravelDiscoveryResult> results,
    DiscoveryCategory category,
  ) {
    return _byCategory(results, category)
        .map((result) => TravelDiscoveryResult(
              id: result.id,
              category: result.category,
              title: result.title,
              subtitle: result.subtitle,
              provider: result.provider,
              location: result.location,
              startTime: result.startTime,
              endTime: result.endTime,
              duration: result.duration,
              price: result.price,
              currency: result.currency,
              rating: result.rating,
              details: result.details,
              metadata: result.metadata,
              source: DiscoveryDataSource.fallback,
            ))
        .toList(growable: false);
  }

  List<TravelDiscoveryResult> _byCategory(
    List<TravelDiscoveryResult> results,
    DiscoveryCategory category,
  ) =>
      results.where((result) => result.category == category).toList();

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  String _flightProvider(FlightDataSource source) => switch (source) {
        FlightDataSource.duffelTest => 'Duffel TEST',
        FlightDataSource.backend => 'Backend flights',
        FlightDataSource.demo => 'ITAREVO Demo Flights',
      };

  DiscoveryDataSource _flightSource(FlightDataSource source) =>
      switch (source) {
        FlightDataSource.duffelTest => DiscoveryDataSource.test,
        FlightDataSource.backend => DiscoveryDataSource.backend,
        FlightDataSource.demo => DiscoveryDataSource.demo,
      };

  String _hotelProvider(HotelDataSource source) => switch (source) {
        HotelDataSource.duffelStays => 'Duffel Stays',
        HotelDataSource.backend => 'Backend hotels',
        HotelDataSource.amadeusTest => 'Amadeus TEST',
        HotelDataSource.demo => 'ITAREVO Demo Hotels',
      };

  DiscoveryDataSource _hotelSource(HotelDataSource source) => switch (source) {
        HotelDataSource.duffelStays => DiscoveryDataSource.test,
        HotelDataSource.backend => DiscoveryDataSource.backend,
        HotelDataSource.amadeusTest => DiscoveryDataSource.test,
        HotelDataSource.demo => DiscoveryDataSource.demo,
      };
}
