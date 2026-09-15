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
  NearbyServiceType.attraction: NearbyServiceMetadata(
    type: NearbyServiceType.attraction,
    label: 'Attractions',
    icon: Icons.local_activity_outlined,
    description: 'Things to do, landmarks, and local experiences.',
    previewFilters: <String>['Top rated', 'Within 2 km'],
    isMvp: true,
  ),
  NearbyServiceType.museum: NearbyServiceMetadata(
    type: NearbyServiceType.museum,
    label: 'Museums',
    icon: Icons.museum_outlined,
    description: 'Museums, galleries, and cultural stops.',
    previewFilters: <String>['Open now', 'Top rated'],
    isMvp: true,
  ),
  NearbyServiceType.shopping: NearbyServiceMetadata(
    type: NearbyServiceType.shopping,
    label: 'Shopping',
    icon: Icons.shopping_bag_outlined,
    description: 'Markets, shops, and useful local retail.',
    previewFilters: <String>['Open now', 'Within 2 km'],
    isMvp: true,
  ),
  NearbyServiceType.fuel: NearbyServiceMetadata(
    type: NearbyServiceType.fuel,
    label: 'Petrol / Gas',
    icon: Icons.local_gas_station_outlined,
    description: 'Fuel stations for road-trip and car hire scenarios.',
    previewFilters: <String>['Open now', 'Within 3 km'],
    isMvp: true,
  ),
  NearbyServiceType.parking: NearbyServiceMetadata(
    type: NearbyServiceType.parking,
    label: 'Parking',
    icon: Icons.local_parking_outlined,
    description: 'Parking areas and drop-off options nearby.',
    previewFilters: <String>['Open now', 'Within 1 km'],
    isMvp: true,
  ),
  NearbyServiceType.supermarket: NearbyServiceMetadata(
    type: NearbyServiceType.supermarket,
    label: 'Supermarkets',
    icon: Icons.local_grocery_store_outlined,
    description: 'Groceries, water, and daily supplies nearby.',
    previewFilters: <String>['Open now', 'Within 1 km'],
    isMvp: true,
  ),
  NearbyServiceType.airport: NearbyServiceMetadata(
    type: NearbyServiceType.airport,
    label: 'Airports',
    icon: Icons.local_airport_outlined,
    description: 'Airport terminals and aviation hubs nearby.',
    previewFilters: <String>['Within 10 km', 'Transport links'],
    isMvp: true,
  ),
  NearbyServiceType.trainStation: NearbyServiceMetadata(
    type: NearbyServiceType.trainStation,
    label: 'Train stations',
    icon: Icons.train_outlined,
    description: 'Rail stations and train connections nearby.',
    previewFilters: <String>['Within 2 km', 'Transit links'],
    isMvp: true,
  ),
  NearbyServiceType.busStation: NearbyServiceMetadata(
    type: NearbyServiceType.busStation,
    label: 'Bus stations',
    icon: Icons.directions_bus_outlined,
    description: 'Bus stations and coach connections nearby.',
    previewFilters: <String>['Within 2 km', 'Transit links'],
    isMvp: true,
  ),
  NearbyServiceType.evCharging: NearbyServiceMetadata(
    type: NearbyServiceType.evCharging,
    label: 'EV charging',
    icon: Icons.ev_station_outlined,
    description: 'Electric vehicle charging points nearby.',
    previewFilters: <String>['Open now', 'Within 3 km'],
    isMvp: true,
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
    label: 'Taxi / transport',
    icon: Icons.local_taxi_outlined,
    description: 'Taxi pickup, ride access, and transport fallback.',
    previewFilters: <String>['Available now', 'Within 2 km'],
    isMvp: true,
  ),
  NearbyServiceType.transit: NearbyServiceMetadata(
    type: NearbyServiceType.transit,
    label: 'Transit',
    icon: Icons.directions_transit_outlined,
    description: 'Stations and public transport points nearby.',
    previewFilters: <String>['Within 1 km'],
    isMvp: true,
  ),
};

const List<NearbyServiceType> nearbyEssentialsMvpServices = <NearbyServiceType>[
  NearbyServiceType.toilet,
  NearbyServiceType.atm,
  NearbyServiceType.pharmacy,
  NearbyServiceType.hospital,
  NearbyServiceType.restaurant,
  NearbyServiceType.cafe,
  NearbyServiceType.attraction,
  NearbyServiceType.museum,
  NearbyServiceType.shopping,
  NearbyServiceType.supermarket,
  NearbyServiceType.parking,
  NearbyServiceType.fuel,
  NearbyServiceType.trainStation,
  NearbyServiceType.busStation,
  NearbyServiceType.airport,
  NearbyServiceType.evCharging,
  NearbyServiceType.taxi,
  NearbyServiceType.transit,
];

extension NearbyServiceTypeMetadata on NearbyServiceType {
  NearbyServiceMetadata get metadata => nearbyServiceMetadataByType[this]!;
}
