import '../../../core/providers/travel_provider_contracts.dart';
import '../../maps/models/places_prefill.dart';
import '../models/nearby_service_filter.dart';
import '../models/nearby_service_metadata.dart';
import '../models/nearby_service_type.dart';

class NearbyServiceEngine {
  const NearbyServiceEngine();

  PlacesPrefill buildPlacesPrefill({
    required NearbyServiceType serviceType,
    NearbyServiceFilter filter = const NearbyServiceFilter(),
  }) {
    return PlacesPrefill(
      query: buildQueryPreview(serviceType, filter),
      title: serviceType.metadata.label,
      note: serviceType.metadata.description,
      categories: categoriesFor(serviceType),
    );
  }

  Set<PlaceCategory> categoriesFor(NearbyServiceType serviceType) {
    switch (serviceType) {
      case NearbyServiceType.toilet:
        return const <PlaceCategory>{PlaceCategory.toilet};
      case NearbyServiceType.atm:
        return const <PlaceCategory>{PlaceCategory.atm};
      case NearbyServiceType.pharmacy:
        return const <PlaceCategory>{PlaceCategory.pharmacy};
      case NearbyServiceType.hospital:
        return const <PlaceCategory>{PlaceCategory.hospital};
      case NearbyServiceType.restaurant:
        return const <PlaceCategory>{PlaceCategory.restaurant};
      case NearbyServiceType.cafe:
        return const <PlaceCategory>{PlaceCategory.cafe};
      case NearbyServiceType.attraction:
        return const <PlaceCategory>{PlaceCategory.attraction};
      case NearbyServiceType.museum:
        return const <PlaceCategory>{PlaceCategory.museum};
      case NearbyServiceType.shopping:
        return const <PlaceCategory>{PlaceCategory.shopping};
      case NearbyServiceType.fuel:
        return const <PlaceCategory>{PlaceCategory.fuelStation};
      case NearbyServiceType.parking:
        return const <PlaceCategory>{PlaceCategory.parking};
      case NearbyServiceType.supermarket:
        return const <PlaceCategory>{PlaceCategory.supermarket};
      case NearbyServiceType.airport:
        return const <PlaceCategory>{PlaceCategory.airport};
      case NearbyServiceType.trainStation:
        return const <PlaceCategory>{PlaceCategory.trainStation};
      case NearbyServiceType.busStation:
        return const <PlaceCategory>{PlaceCategory.busStation};
      case NearbyServiceType.evCharging:
        return const <PlaceCategory>{PlaceCategory.evChargingStation};
      case NearbyServiceType.hotel:
        return const <PlaceCategory>{PlaceCategory.accommodation};
      case NearbyServiceType.taxi:
        return const <PlaceCategory>{PlaceCategory.taxiStand};
      case NearbyServiceType.transit:
        return const <PlaceCategory>{PlaceCategory.transportStation};
    }
  }

  String buildQueryPreview(
    NearbyServiceType serviceType,
    NearbyServiceFilter filter,
  ) {
    final segments = <String>[_baseQuery(serviceType)];

    if (filter.openNow) {
      segments.add('open now');
    }
    if (filter.freeOnly) {
      segments.add('free');
    }
    if (filter.wheelchairAccessible) {
      segments.add('wheelchair accessible');
    }
    if (filter.babyChanging) {
      segments.add('baby changing');
    }
    if (filter.maxDistanceMeters != null) {
      segments.add('within ${filter.maxDistanceMeters} m');
    }

    return segments.join(' ');
  }

  String _baseQuery(NearbyServiceType serviceType) {
    switch (serviceType) {
      case NearbyServiceType.toilet:
        return 'public toilets';
      case NearbyServiceType.atm:
        return 'atm';
      case NearbyServiceType.pharmacy:
        return 'pharmacy';
      case NearbyServiceType.hospital:
        return 'hospital';
      case NearbyServiceType.restaurant:
        return 'restaurant';
      case NearbyServiceType.cafe:
        return 'cafe';
      case NearbyServiceType.attraction:
        return 'things to do';
      case NearbyServiceType.museum:
        return 'museum';
      case NearbyServiceType.shopping:
        return 'shopping';
      case NearbyServiceType.fuel:
        return 'fuel station';
      case NearbyServiceType.parking:
        return 'parking';
      case NearbyServiceType.supermarket:
        return 'supermarket';
      case NearbyServiceType.airport:
        return 'airport';
      case NearbyServiceType.trainStation:
        return 'train station';
      case NearbyServiceType.busStation:
        return 'bus station';
      case NearbyServiceType.evCharging:
        return 'ev charging station';
      case NearbyServiceType.hotel:
        return 'hotel';
      case NearbyServiceType.taxi:
        return 'taxi stand';
      case NearbyServiceType.transit:
        return 'public transport station';
    }
  }
}
