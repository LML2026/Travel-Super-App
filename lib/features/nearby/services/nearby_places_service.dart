import '../../../core/providers/travel_provider_contracts.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../providers/provider_gateway.dart';
import '../models/nearby_service_result.dart';
import '../models/nearby_service_metadata.dart';
import '../models/nearby_service_type.dart';
import 'nearby_service_engine.dart';

class NearbyPlacesQuery {
  const NearbyPlacesQuery({
    required this.location,
    required this.serviceType,
    this.limit = 12,
  });

  final String location;
  final NearbyServiceType serviceType;
  final int limit;
}

abstract interface class NearbyPlacesService {
  Future<List<NearbyServiceResult>> search(NearbyPlacesQuery query);
}

typedef NearbyBackendGetter = Future<Map<String, dynamic>> Function(
  String path, {
  Map<String, dynamic>? queryParameters,
});

class BackendNearbyPlacesService implements NearbyPlacesService {
  BackendNearbyPlacesService({
    ApiClient? apiClient,
    NearbyBackendGetter? backendGet,
    NearbyPlacesService? fallback,
  })  : _apiClient = apiClient ?? ApiClient(),
        _backendGet = backendGet,
        _fallback = fallback ?? const DemoNearbyPlacesService();

  final ApiClient _apiClient;
  final NearbyBackendGetter? _backendGet;
  final NearbyPlacesService _fallback;

  @override
  Future<List<NearbyServiceResult>> search(NearbyPlacesQuery query) async {
    try {
      final data = await (_backendGet?.call(
            ApiEndpoints.nearbyPlaces,
            queryParameters: <String, dynamic>{
              'city': query.location.trim(),
              'category': _backendCategory(query.serviceType),
            },
          ) ??
          _getBackend(query));

      final rawPlaces = data['places'];
      if (rawPlaces is! List) {
        throw const FormatException('Nearby places list is missing.');
      }

      return rawPlaces
          .whereType<Map>()
          .map((place) => _mapBackendPlace(
                Map<String, dynamic>.from(place),
                query,
              ))
          .take(query.limit)
          .toList(growable: false);
    } catch (_) {
      return _withUnavailableNotice(await _fallback.search(query));
    }
  }

  Future<Map<String, dynamic>> _getBackend(NearbyPlacesQuery query) async {
    final response = await _apiClient.get(
      ApiEndpoints.nearbyPlaces,
      queryParameters: <String, dynamic>{
        'city': query.location.trim(),
        'category': _backendCategory(query.serviceType),
      },
    );

    if (response.statusCode != 200 || response.data is! Map) {
      throw const FormatException('Nearby places backend unavailable.');
    }

    return Map<String, dynamic>.from(response.data as Map);
  }

  NearbyServiceResult _mapBackendPlace(
    Map<String, dynamic> place,
    NearbyPlacesQuery query,
  ) {
    final distanceKm = (place['distanceKm'] as num?)?.toDouble();
    return NearbyServiceResult(
      id: place['id'] as String? ??
          'backend-nearby-${query.serviceType.name}-${(place['name'] ?? '').toString().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}',
      name: place['name'] as String? ?? query.serviceType.metadata.label,
      serviceType: query.serviceType,
      categoryLabel: query.serviceType.metadata.label,
      address: (place['address'] as String?)?.trim().isNotEmpty == true
          ? (place['address'] as String).trim()
          : distanceKm == null
              ? 'Near ${query.location}'
              : '${distanceKm.toStringAsFixed(1)} km from ${query.location}',
      latitude: (place['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (place['longitude'] as num?)?.toDouble() ?? 0,
      source: NearbyDataSource.backend,
      sourceMetadata: const <String, Object?>{
        'provider': 'ITAREVO nearby backend',
      },
      distanceMeters: distanceKm == null ? null : distanceKm * 1000,
      rating: (place['rating'] as num?)?.toDouble(),
      isOpenNow: place['isOpenNow'] as bool?,
      openStatusSource: place['isOpenNow'] == null
          ? OpenStatusSource.unknown
          : OpenStatusSource.provider,
      metadata: <String, Object?>{
        if (place['type'] != null) 'type': place['type'],
        if (place['description'] != null) 'description': place['description'],
      },
    );
  }

  List<NearbyServiceResult> _withUnavailableNotice(
    List<NearbyServiceResult> fallback,
  ) {
    return fallback
        .map((place) => NearbyServiceResult(
              id: place.id,
              name: place.name,
              serviceType: place.serviceType,
              categoryLabel: place.categoryLabel,
              address: place.address,
              latitude: place.latitude,
              longitude: place.longitude,
              source: place.source,
              sourceMetadata: <String, Object?>{
                ...place.sourceMetadata,
                'liveUnavailable': true,
              },
              distanceMeters: place.distanceMeters,
              rating: place.rating,
              isOpenNow: place.isOpenNow,
              openingHours: place.openingHours,
              openStatusSource: place.openStatusSource,
              wheelchairAccessible: place.wheelchairAccessible,
              hasAccessibleToilet: place.hasAccessibleToilet,
              hasBabyChanging: place.hasBabyChanging,
              metadata: place.metadata,
            ))
        .toList(growable: false);
  }

  String _backendCategory(NearbyServiceType serviceType) {
    return switch (serviceType) {
      NearbyServiceType.toilet => 'toilets',
      NearbyServiceType.atm => 'atms',
      NearbyServiceType.pharmacy => 'pharmacies',
      NearbyServiceType.hospital => 'hospitals',
      NearbyServiceType.restaurant => 'restaurants',
      NearbyServiceType.cafe => 'cafes',
      NearbyServiceType.attraction => 'attractions',
      NearbyServiceType.fuel => 'petrol',
      NearbyServiceType.supermarket => 'supermarkets',
      NearbyServiceType.airport => 'airports',
      NearbyServiceType.trainStation => 'trainStation',
      NearbyServiceType.busStation => 'busStation',
      NearbyServiceType.evCharging => 'evCharging',
      NearbyServiceType.taxi => 'taxi',
      NearbyServiceType.transit => 'transport',
      _ => serviceType.name,
    };
  }
}

class GoogleNearbyPlacesService implements NearbyPlacesService {
  GoogleNearbyPlacesService({
    required ProviderGateway gateway,
    NearbyPlacesService? fallback,
  })  : _gateway = gateway,
        _fallback = fallback ?? const DemoNearbyPlacesService();

  final ProviderGateway _gateway;
  final NearbyPlacesService _fallback;
  static const _engine = NearbyServiceEngine();

  @override
  Future<List<NearbyServiceResult>> search(NearbyPlacesQuery query) async {
    final location = query.location.trim().isEmpty
        ? 'your destination'
        : query.location.trim();
    try {
      final places = await _gateway.searchPlaces(
        query: '${query.serviceType.metadata.label} near $location',
        categories: _engine.categoriesFor(query.serviceType),
        limit: query.limit,
      );
      final mapped = places.map(_map).toList(growable: false);
      if (mapped.any((place) => place.source == NearbyDataSource.google)) {
        return mapped.take(query.limit).toList(growable: false);
      }
      return _fallback.search(query);
    } catch (_) {
      return _fallback.search(query);
    }
  }

  NearbyServiceResult _map(PlaceResult place) {
    final location = place.location;
    return NearbyServiceResult(
      id: place.id,
      name: place.name,
      serviceType: _serviceTypeFor(place.category),
      categoryLabel: place.category.name,
      address: place.address ?? 'Address unavailable',
      latitude: location?.latitude ?? 0,
      longitude: location?.longitude ?? 0,
      source: place.dataSource == TravelDataSource.live
          ? NearbyDataSource.google
          : NearbyDataSource.fallback,
      sourceMetadata: <String, Object?>{
        'provider': place.dataSource == TravelDataSource.live
            ? 'Google Places'
            : 'Demo',
      },
      rating: place.rating,
      isOpenNow: place.isOpenNow,
      openStatusSource: place.isOpenNow == null
          ? OpenStatusSource.unknown
          : OpenStatusSource.provider,
      metadata: <String, Object?>{
        'priceLevel': place.priceLevel,
        'description': place.description,
      },
    );
  }

  NearbyServiceType _serviceTypeFor(PlaceCategory category) {
    return switch (category) {
      PlaceCategory.restaurant => NearbyServiceType.restaurant,
      PlaceCategory.cafe => NearbyServiceType.cafe,
      PlaceCategory.museum => NearbyServiceType.museum,
      PlaceCategory.shopping => NearbyServiceType.shopping,
      PlaceCategory.pharmacy => NearbyServiceType.pharmacy,
      PlaceCategory.hospital => NearbyServiceType.hospital,
      PlaceCategory.atm => NearbyServiceType.atm,
      PlaceCategory.supermarket => NearbyServiceType.supermarket,
      PlaceCategory.parking => NearbyServiceType.parking,
      PlaceCategory.fuelStation => NearbyServiceType.fuel,
      PlaceCategory.airport => NearbyServiceType.airport,
      PlaceCategory.trainStation => NearbyServiceType.trainStation,
      PlaceCategory.busStation => NearbyServiceType.busStation,
      PlaceCategory.evChargingStation => NearbyServiceType.evCharging,
      PlaceCategory.taxiStand => NearbyServiceType.taxi,
      PlaceCategory.transportStation => NearbyServiceType.transit,
      _ => NearbyServiceType.attraction,
    };
  }
}

class DemoNearbyPlacesService implements NearbyPlacesService {
  const DemoNearbyPlacesService();

  @override
  Future<List<NearbyServiceResult>> search(NearbyPlacesQuery query) async {
    final location = query.location.trim().isEmpty
        ? 'your destination'
        : query.location.trim();
    final label = query.serviceType.metadata.label;
    final names = switch (query.serviceType) {
      NearbyServiceType.restaurant => const ['Old Town Kitchen', 'Local Table'],
      NearbyServiceType.cafe => const ['Roastery Corner', 'Morning Cup'],
      NearbyServiceType.attraction => const [
          'City Highlights Walk',
          'Heritage Square'
        ],
      NearbyServiceType.museum => const [
          'City History Museum',
          'Modern Gallery'
        ],
      NearbyServiceType.shopping => const ['Central Market', 'Riverside Shops'],
      NearbyServiceType.pharmacy => const [
          'Central Pharmacy',
          'Travel Health Pharmacy'
        ],
      NearbyServiceType.hospital => const [
          'City Medical Centre',
          'General Hospital'
        ],
      NearbyServiceType.atm => const ['Central ATM', 'Travel Money ATM'],
      NearbyServiceType.supermarket => const [
          'Market Hall',
          'Freshway Supermarket'
        ],
      NearbyServiceType.transit => const [
          'Central Transit Station',
          'City Bus Interchange'
        ],
      _ => ['$label near $location'],
    };

    return names
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          return NearbyServiceResult(
            id: 'demo-nearby-${query.serviceType.name}-${index + 1}-${location.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}',
            name: entry.value,
            serviceType: query.serviceType,
            categoryLabel: label,
            address: 'Demo result near $location',
            latitude: 0,
            longitude: 0,
            source: NearbyDataSource.fallback,
            sourceMetadata: const <String, Object?>{
              'provider': 'ITAREVO Demo Places',
            },
            rating: 4.2 - (index * 0.1),
            isOpenNow: null,
            metadata: const <String, Object?>{
              'description':
                  'Demo place data. Check live provider details before relying on opening status.',
            },
          );
        })
        .take(query.limit)
        .toList(growable: false);
  }
}
