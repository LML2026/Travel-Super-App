import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/travel_provider_contracts.dart';
import '../flights/models/flight.dart';
import '../flights/models/flight_search_request.dart';
import '../hotels/models/hotel.dart';
import '../hotels/models/hotel_search_request.dart';
import '../maps/services/google_maps_platform_service.dart';

abstract interface class ProviderGateway {
  Future<List<PlaceResult>> searchPlaces({
    required String query,
    Set<PlaceCategory> categories = const {},
    int limit = 20,
  });

  Future<List<Flight>> searchFlights(FlightSearchRequest request);

  Future<List<Hotel>> searchHotels(HotelSearchRequest request);

  Future<List<String>> searchActivities({required String destination});

  Future<String> translate({
    required String text,
    required String sourceLanguageCode,
    required String targetLanguageCode,
  });
}

class DemoProviderGateway implements ProviderGateway {
  const DemoProviderGateway();

  @override
  Future<List<PlaceResult>> searchPlaces({
    required String query,
    Set<PlaceCategory> categories = const {},
    int limit = 20,
  }) async {
    final category =
        categories.isEmpty ? PlaceCategory.attraction : categories.first;
    final cleanQuery = query.trim();
    final label = cleanQuery.isEmpty
        ? 'Local place'
        : '${cleanQuery[0].toUpperCase()}${cleanQuery.substring(1)}';

    return [
      PlaceResult(
        id: 'demo-place-${cleanQuery.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}',
        name: '$label suggestion',
        category: category,
        address: 'Demo result near your trip destination',
        description:
            'Local demo place data. Not live Google Places information.',
        dataSource: TravelDataSource.mock,
      ),
    ].take(limit).toList(growable: false);
  }

  @override
  Future<List<Flight>> searchFlights(FlightSearchRequest request) async =>
      const <Flight>[];

  @override
  Future<List<Hotel>> searchHotels(HotelSearchRequest request) async =>
      const <Hotel>[];

  @override
  Future<List<String>> searchActivities({required String destination}) async =>
      const <String>[];

  @override
  Future<String> translate({
    required String text,
    required String sourceLanguageCode,
    required String targetLanguageCode,
  }) async =>
      text;
}

class GoogleMapsProviderGateway implements ProviderGateway {
  GoogleMapsProviderGateway({
    GoogleMapsPlatformService? platformService,
    ProviderGateway? fallback,
  })  : _platformService = platformService ?? const GoogleMapsPlatformService(),
        _fallback = fallback ?? const DemoProviderGateway();

  final GoogleMapsPlatformService _platformService;
  final ProviderGateway _fallback;

  @override
  Future<List<PlaceResult>> searchPlaces({
    required String query,
    Set<PlaceCategory> categories = const {},
    int limit = 20,
  }) async {
    try {
      if (!await _platformService.isConfigured()) {
        return _fallback.searchPlaces(
          query: query,
          categories: categories,
          limit: limit,
        );
      }

      final raw = await _platformService.searchPlaces(
        query: query,
        categories: categories.map((category) => category.name).toSet(),
        limit: limit,
      );
      if (raw.isEmpty) {
        return _fallback.searchPlaces(
          query: query,
          categories: categories,
          limit: limit,
        );
      }
      return raw.map(_placeFromNative).toList(growable: false);
    } catch (_) {
      return _fallback.searchPlaces(
        query: query,
        categories: categories,
        limit: limit,
      );
    }
  }

  PlaceResult _placeFromNative(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    final types = (json['types'] as List<dynamic>?)?.whereType<String>();
    return PlaceResult(
      id: json['id'] as String? ?? 'google-place',
      name: json['name'] as String? ?? 'Google place',
      category: _categoryFor(types ?? const <String>[]),
      address: json['address'] as String?,
      location: location == null
          ? null
          : GeoPoint(
              (location['latitude'] as num?)?.toDouble() ?? 0,
              (location['longitude'] as num?)?.toDouble() ?? 0,
            ),
      rating: (json['rating'] as num?)?.toDouble(),
      priceLevel: json['priceLevel'] as String?,
      description: json['description'] as String?,
      dataSource: TravelDataSource.live,
      isOpenNow: json['isOpenNow'] as bool?,
    );
  }

  PlaceCategory _categoryFor(Iterable<String> types) {
    for (final type in types) {
      if (type.contains('restaurant')) return PlaceCategory.restaurant;
      if (type.contains('cafe')) return PlaceCategory.cafe;
      if (type.contains('museum')) return PlaceCategory.museum;
      if (type.contains('lodging')) return PlaceCategory.accommodation;
      if (type.contains('pharmacy')) return PlaceCategory.pharmacy;
      if (type.contains('hospital')) return PlaceCategory.hospital;
      if (type.contains('shopping')) return PlaceCategory.shopping;
      if (type.contains('transit')) return PlaceCategory.transportStation;
    }
    return PlaceCategory.attraction;
  }

  @override
  Future<List<Flight>> searchFlights(FlightSearchRequest request) =>
      _fallback.searchFlights(request);

  @override
  Future<List<Hotel>> searchHotels(HotelSearchRequest request) =>
      _fallback.searchHotels(request);

  @override
  Future<List<String>> searchActivities({required String destination}) =>
      _fallback.searchActivities(destination: destination);

  @override
  Future<String> translate({
    required String text,
    required String sourceLanguageCode,
    required String targetLanguageCode,
  }) =>
      _fallback.translate(
        text: text,
        sourceLanguageCode: sourceLanguageCode,
        targetLanguageCode: targetLanguageCode,
      );
}

final providerGatewayProvider = Provider<ProviderGateway>(
  (ref) => GoogleMapsProviderGateway(),
);
