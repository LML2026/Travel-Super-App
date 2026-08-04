import 'package:flutter/material.dart';

import 'nearby_service_type.dart';

class NearbyServiceMetadata {
  const NearbyServiceMetadata({
    required this.type,
    required this.label,
    required this.icon,
    required this.description,
    required this.previewFilters,
    this.isMvp = false,
  });

  final NearbyServiceType type;
  final String label;
  final IconData icon;
  final String description;
  final List<String> previewFilters;
  final bool isMvp;
}

const Map<NearbyServiceType, NearbyServiceMetadata>
nearbyServiceMetadataByType = <NearbyServiceType, NearbyServiceMetadata>{
  NearbyServiceType.toilet: NearbyServiceMetadata(
    type: NearbyServiceType.toilet,
    label: 'Toilets',
    icon: Icons.wc_outlined,
    description: 'Public restrooms and practical comfort stops nearby.',
    previewFilters: <String>[
      'Open now',
      'Free',
      'Wheelchair',
      'Baby changing',
      'Within 500 m',
    ],
    isMvp: true,
  ),
  NearbyServiceType.atm: NearbyServiceMetadata(
    type: NearbyServiceType.atm,
    label: 'ATMs',
    icon: Icons.atm_outlined,
    description: 'Cash access and nearby ATM points.',
    previewFilters: <String>['Open now', 'Within 500 m', 'High rating'],
    isMvp: true,
  ),
  NearbyServiceType.pharmacy: NearbyServiceMetadata(
    type: NearbyServiceType.pharmacy,
    label: 'Pharmacies',
    icon: Icons.local_pharmacy_outlined,
    description: 'Medication, essentials, and open pharmacies.',
    previewFilters: <String>['Open now', 'Within 1 km', 'High rating'],
    isMvp: true,
  ),
  NearbyServiceType.hospital: NearbyServiceMetadata(
    type: NearbyServiceType.hospital,
    label: 'Hospitals',
    icon: Icons.local_hospital_outlined,
    description: 'Urgent medical support and nearby hospitals.',
    previewFilters: <String>['Emergency', 'Open now', 'Within 2 km'],
    isMvp: true,
  ),
  NearbyServiceType.restaurant: NearbyServiceMetadata(
    type: NearbyServiceType.restaurant,
    label: 'Restaurants',
    icon: Icons.restaurant_outlined,
    description: 'Sit-down dining and local food options.',
    previewFilters: <String>['Open now', 'High rating', 'Within 1 km'],
    isMvp: true,
  ),
  NearbyServiceType.cafe: NearbyServiceMetadata(
    type: NearbyServiceType.cafe,
    label: 'Cafes',
    icon: Icons.local_cafe_outlined,
    description: 'Coffee, quick breaks, and light snacks.',
    previewFilters: <String>['Open now', 'High rating', 'Within 500 m'],
    isMvp: true,
  ),
  NearbyServiceType.fuel: NearbyServiceMetadata(
    type: NearbyServiceType.fuel,
    label: 'Fuel',
    icon: Icons.local_gas_station_outlined,
    description: 'Fuel stations for road-trip and car hire scenarios.',
    previewFilters: <String>['Open now', 'Within 3 km'],
  ),
  NearbyServiceType.parking: NearbyServiceMetadata(
    type: NearbyServiceType.parking,
    label: 'Parking',
    icon: Icons.local_parking_outlined,
    description: 'Parking areas and drop-off options nearby.',
    previewFilters: <String>['Open now', 'Within 1 km'],
  ),
  NearbyServiceType.supermarket: NearbyServiceMetadata(
    type: NearbyServiceType.supermarket,
    label: 'Supermarkets',
    icon: Icons.local_grocery_store_outlined,
    description: 'Groceries, water, and daily supplies nearby.',
    previewFilters: <String>['Open now', 'Within 1 km'],
  ),
  NearbyServiceType.hotel: NearbyServiceMetadata(
    type: NearbyServiceType.hotel,
    label: 'Hotels',
    icon: Icons.hotel_outlined,
    description: 'Nearby stays and accommodation fallbacks.',
    previewFilters: <String>['Open now', 'High rating', 'Within 2 km'],
  ),
  NearbyServiceType.taxi: NearbyServiceMetadata(
    type: NearbyServiceType.taxi,
    label: 'Taxi',
    icon: Icons.local_taxi_outlined,
    description: 'Taxi pickup, ride access, and transport fallback.',
    previewFilters: <String>['Available now', 'Within 2 km'],
  ),
};

const List<NearbyServiceType> nearbyEssentialsMvpServices = <NearbyServiceType>[
  NearbyServiceType.toilet,
  NearbyServiceType.atm,
  NearbyServiceType.pharmacy,
  NearbyServiceType.hospital,
  NearbyServiceType.restaurant,
  NearbyServiceType.cafe,
];

extension NearbyServiceTypeMetadata on NearbyServiceType {
  NearbyServiceMetadata get metadata => nearbyServiceMetadataByType[this]!;
}
