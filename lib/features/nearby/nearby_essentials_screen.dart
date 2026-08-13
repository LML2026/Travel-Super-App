import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/services/nearby_search_service.dart';

class NearbyEssentialsScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const NearbyEssentialsScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<NearbyEssentialsScreen> createState() => _NearbyEssentialsScreenState();
}

class _NearbyEssentialsScreenState extends State<NearbyEssentialsScreen> {
  String _selectedType = 'public_bathroom';
  bool _isLoading = false;
  bool _isLocating = true;
  bool _usingCurrentLocation = false;
  bool _hasRequestedPermission = false;
  String? _locationMessage;
  List<_NearbyResult> _results = [];
  GoogleMapController? _mapController;
  late double _searchLatitude;
  late double _searchLongitude;

  static const _categories = <_NearbyCategory>[
    _NearbyCategory(
      label: 'Toilets',
      type: 'public_bathroom',
      icon: Icons.wc_outlined,
    ),
    _NearbyCategory(label: 'ATMs', type: 'atm', icon: Icons.atm_outlined),
    _NearbyCategory(
      label: 'Pharmacy',
      type: 'pharmacy',
      icon: Icons.local_pharmacy_outlined,
    ),
    _NearbyCategory(
      label: 'Hospital',
      type: 'hospital',
      icon: Icons.local_hospital_outlined,
    ),
    _NearbyCategory(
      label: 'Supermarket',
      type: 'supermarket',
      icon: Icons.shopping_cart_outlined,
    ),
    _NearbyCategory(
      label: 'Transport',
      type: 'transit_station',
      icon: Icons.directions_transit_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchLatitude = widget.latitude;
    _searchLongitude = widget.longitude;
    _useCurrentLocation();
  }

  @override
  void dispose() {
    _mapController = null;
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _locationMessage = null;
    });

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        await _useTripLocation(
          'Location services are disabled. Using the trip location.',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        if (_hasRequestedPermission) {
          await _useTripLocation(
            'Location permission was denied. Using the trip location.',
          );
          return;
        }

        _hasRequestedPermission = true;
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        await _useTripLocation(
          'Location permission was denied. Using the trip location.',
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        await _useTripLocation(
          'Location permission is blocked in settings. Using the trip location.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      if (!mounted) return;

      setState(() {
        _searchLatitude = position.latitude;
        _searchLongitude = position.longitude;
        _usingCurrentLocation = true;
        _isLocating = false;
        _locationMessage = null;
      });

      await _focusSearchCentre();
      await _search(_selectedType);
    } catch (_) {
      await _useTripLocation(
        'Current location is unavailable. Using the trip location.',
      );
    }
  }

  Future<void> _useTripLocation(String message) async {
    if (!mounted) return;

    setState(() {
      _searchLatitude = widget.latitude;
      _searchLongitude = widget.longitude;
      _usingCurrentLocation = false;
      _isLocating = false;
      _locationMessage = message;
    });

    await _focusSearchCentre();
    await _search(_selectedType);
  }

  Future<void> _focusSearchCentre() async {
    final controller = _mapController;

    if (!mounted || controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(_searchLatitude, _searchLongitude), 15),
    );
  }

  Future<void> _search(String type) async {
    setState(() {
      _selectedType = type;
      _isLoading = true;
    });

    try {
      final places = await NearbySearchService.search(
        latitude: _searchLatitude,
        longitude: _searchLongitude,
        placeType: type,
      );
      final results =
          places
              .map(
                (place) => _NearbyResult(
                  place: place,
                  distanceMetres: Geolocator.distanceBetween(
                    _searchLatitude,
                    _searchLongitude,
                    place.latitude,
                    place.longitude,
                  ),
                ),
              )
              .toList()
            ..sort(
              (first, second) =>
                  first.distanceMetres.compareTo(second.distanceMetres),
            );

      if (!mounted) return;

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _results = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nearby search could not be completed.')),
      );
    }
  }

  String _markerIdFor(NearbyPlace place, int index) {
    return place.id.isEmpty ? 'nearby_$index' : place.id;
  }

  Future<void> _focusResult(NearbyPlace place, int index) async {
    final controller = _mapController;

    if (!mounted || controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(place.latitude, place.longitude), 17),
    );

    if (!mounted || _mapController != controller) return;

    await controller.showMarkerInfoWindow(MarkerId(_markerIdFor(place, index)));
  }

  Future<void> _openDirections(NearbyPlace place) async {
    final opened = await NearbySearchService.openDirections(place);

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Directions are currently available on web.'),
        ),
      );
    }
  }

  String _formatDistance(double metres) {
    if (metres < 1000) return '${metres.round()} m';

    return '${(metres / 1000).toStringAsFixed(1)} km';
  }

  Set<Marker> get _markers {
    return {
      Marker(
        markerId: const MarkerId('search_center'),
        position: LatLng(_searchLatitude, _searchLongitude),
        infoWindow: InfoWindow(
          title: _usingCurrentLocation
              ? 'Your current location'
              : 'Trip location',
        ),
      ),
      for (var i = 0; i < _results.length; i++)
        Marker(
          markerId: MarkerId(_markerIdFor(_results[i].place, i)),
          position: LatLng(
            _results[i].place.latitude,
            _results[i].place.longitude,
          ),
          infoWindow: InfoWindow(
            title: _results[i].place.name,
            snippet: _results[i].place.address,
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Essentials')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      _usingCurrentLocation
                          ? Icons.my_location
                          : Icons.location_on_outlined,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _usingCurrentLocation
                                ? 'Your current location'
                                : 'Trip location',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (_locationMessage != null)
                            Text(
                              _locationMessage!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    if (_isLocating)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      TextButton.icon(
                        onPressed: _useCurrentLocation,
                        icon: const Icon(Icons.gps_fixed, size: 18),
                        label: const Text('Use my location'),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 64,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];

                return FilterChip(
                  selected: _selectedType == category.type,
                  avatar: Icon(category.icon, size: 18),
                  label: Text(category.label),
                  onSelected: _isLocating
                      ? null
                      : (_) => _search(category.type),
                );
              },
            ),
          ),
          Expanded(
            flex: 5,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(_searchLatitude, _searchLongitude),
                zoom: 15,
              ),
              markers: _markers,
              myLocationEnabled: _usingCurrentLocation,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
          ),
          Expanded(
            flex: 4,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                ? const Center(child: Text('No nearby results found.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _results.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final result = _results[index];
                      final place = result.place;

                      return ListTile(
                        onTap: () => _focusResult(place, index),
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(
                          place.name.isEmpty ? 'Nearby place' : place.name,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (place.address.isNotEmpty) Text(place.address),
                            Text(
                              _formatDistance(result.distanceMetres),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          tooltip: 'Directions',
                          icon: const Icon(Icons.directions_outlined),
                          onPressed: () => _openDirections(place),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NearbyResult {
  final NearbyPlace place;
  final double distanceMetres;

  const _NearbyResult({required this.place, required this.distanceMetres});
}

class _NearbyCategory {
  final String label;
  final String type;
  final IconData icon;

  const _NearbyCategory({
    required this.label,
    required this.type,
    required this.icon,
  });
}
