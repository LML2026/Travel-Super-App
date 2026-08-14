import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/services/route_service.dart';
import '../../../nearby/nearby_essentials_screen.dart';
import '../../models/itinerary/itinerary_item.dart';
import '../../models/trip.dart';

class TripMapScreen extends StatefulWidget {
  final Trip trip;
  final List<ItineraryItem> items;
  final TravelMode travelMode;

  const TripMapScreen({
    super.key,
    required this.trip,
    required this.items,
    this.travelMode = TravelMode.walking,
  });

  @override
  State<TripMapScreen> createState() => _TripMapScreenState();
}

class _TripMapScreenState extends State<TripMapScreen> {
  GoogleMapController? _mapController;
  final Map<String, RouteResult> _routes = {};

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  List<ItineraryItem> get _locatedItems {
    return widget.items
        .where((item) => item.latitude != null && item.longitude != null)
        .toList();
  }

  Set<Marker> get _markers {
    final items = _locatedItems;

    return {
      for (var i = 0; i < items.length; i++)
        Marker(
          markerId: MarkerId(items[i].id),
          position: LatLng(items[i].latitude!, items[i].longitude!),
          infoWindow: InfoWindow(
            title: '${i + 1}. ${items[i].title}',
            snippet: items[i].location.isEmpty
                ? items[i].category
                : items[i].location,
          ),
        ),
    };
  }

  Set<Polyline> get _polylines {
    return {
      for (final entry in _routes.entries)
        if (entry.value.points.length >= 2)
          Polyline(
            polylineId: PolylineId(entry.key),
            points: entry.value.points
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList(growable: false),
            color: Theme.of(context).colorScheme.primary,
            width: 5,
          ),
    };
  }

  Future<void> _loadRoutes() async {
    final routes = <String, RouteResult>{};

    await Future.wait(
      _routePairs().map((pair) async {
        final route = await RouteService.calculate(
          originLatitude: pair.origin.latitude!,
          originLongitude: pair.origin.longitude!,
          destinationLatitude: pair.destination.latitude!,
          destinationLongitude: pair.destination.longitude!,
          travelMode: widget.travelMode,
        );

        if (route != null) routes[pair.key] = route;
      }),
    );

    if (!mounted) return;

    setState(() {
      _routes
        ..clear()
        ..addAll(routes);
    });
  }

  List<_MapRoutePair> _routePairs() {
    final sortedItems = List<ItineraryItem>.from(widget.items)
      ..sort((first, second) {
        final dateComparison = first.date.compareTo(second.date);

        if (dateComparison != 0) return dateComparison;

        return (first.time ?? '').compareTo(second.time ?? '');
      });
    final pairs = <_MapRoutePair>[];

    for (var index = 0; index < sortedItems.length - 1; index++) {
      final origin = sortedItems[index];
      final destination = sortedItems[index + 1];
      final sameDay =
          origin.date.year == destination.date.year &&
          origin.date.month == destination.date.month &&
          origin.date.day == destination.date.day;

      if (!sameDay ||
          origin.latitude == null ||
          origin.longitude == null ||
          destination.latitude == null ||
          destination.longitude == null) {
        continue;
      }

      pairs.add(_MapRoutePair(origin: origin, destination: destination));
    }

    return pairs;
  }

  LatLng get _initialPosition {
    final items = _locatedItems;

    if (items.isNotEmpty) {
      return LatLng(items.first.latitude!, items.first.longitude!);
    }

    return const LatLng(48.8566, 2.3522);
  }

  Future<void> _fitAllMarkers() async {
    final controller = _mapController;
    final items = _locatedItems;

    if (!mounted || controller == null || items.isEmpty) return;

    if (items.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(items.first.latitude!, items.first.longitude!),
          14,
        ),
      );
      return;
    }

    var minLat = items.first.latitude!;
    var maxLat = items.first.latitude!;
    var minLng = items.first.longitude!;
    var maxLng = items.first.longitude!;

    for (final item in items.skip(1)) {
      final lat = item.latitude!;
      final lng = item.longitude!;

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    if (!mounted || _mapController != controller) return;

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        70,
      ),
    );
  }

  void _openNearby() {
    final items = _locatedItems;

    if (items.isEmpty) return;

    final centre = items.first;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NearbyEssentialsScreen(
          latitude: centre.latitude!,
          longitude: centre.longitude!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locatedItems = _locatedItems;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.trip.destination} Map'),
        actions: [
          if (locatedItems.isNotEmpty)
            IconButton(
              tooltip: 'Nearby Essentials',
              icon: const Icon(Icons.near_me_outlined),
              onPressed: _openNearby,
            ),
          if (locatedItems.isNotEmpty)
            IconButton(
              tooltip: 'Show all stops',
              icon: const Icon(Icons.center_focus_strong),
              onPressed: _fitAllMarkers,
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: locatedItems.isEmpty ? 4 : 13,
            ),
            markers: _markers,
            polylines: _polylines,
            mapType: MapType.normal,
            compassEnabled: true,
            zoomControlsEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;

              if (locatedItems.isNotEmpty) {
                Future.delayed(
                  const Duration(milliseconds: 500),
                  _fitAllMarkers,
                );
              }
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.route_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        locatedItems.isEmpty
                            ? 'No mapped itinerary stops yet'
                            : '${locatedItems.length} mapped '
                                  '${locatedItems.length == 1 ? 'stop' : 'stops'}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapRoutePair {
  final ItineraryItem origin;
  final ItineraryItem destination;

  const _MapRoutePair({required this.origin, required this.destination});

  String get key => '${origin.id}|${destination.id}';
}
