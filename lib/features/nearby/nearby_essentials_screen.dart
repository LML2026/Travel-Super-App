import 'package:flutter/material.dart';
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
  State<NearbyEssentialsScreen> createState() =>
      _NearbyEssentialsScreenState();
}

class _NearbyEssentialsScreenState
    extends State<NearbyEssentialsScreen> {
  String _selectedType = 'public_bathroom';
  bool _isLoading = false;
  List<NearbyPlace> _places = [];

  static const _categories = <_NearbyCategory>[
    _NearbyCategory(
      label: 'Toilets',
      type: 'public_bathroom',
      icon: Icons.wc_outlined,
    ),
    _NearbyCategory(
      label: 'ATMs',
      type: 'atm',
      icon: Icons.atm_outlined,
    ),
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
    _search(_selectedType);
  }

  Future<void> _search(String type) async {
    setState(() {
      _selectedType = type;
      _isLoading = true;
    });

    try {
      final results = await NearbySearchService.search(
        latitude: widget.latitude,
        longitude: widget.longitude,
        placeType: type,
      );

      if (!mounted) return;

      setState(() {
        _places = results;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _places = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nearby search could not be completed.',
          ),
        ),
      );
    }
  }

  Set<Marker> get _markers {
    return {
      Marker(
        markerId: const MarkerId('search_center'),
        position: LatLng(
          widget.latitude,
          widget.longitude,
        ),
        infoWindow: const InfoWindow(
          title: 'Search centre',
        ),
      ),
      for (var i = 0; i < _places.length; i++)
        Marker(
          markerId: MarkerId(
            _places[i].id.isEmpty
                ? 'nearby_$i'
                : _places[i].id,
          ),
          position: LatLng(
            _places[i].latitude,
            _places[i].longitude,
          ),
          infoWindow: InfoWindow(
            title: _places[i].name,
            snippet: _places[i].address,
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Essentials'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 64,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];

                return FilterChip(
                  selected:
                      _selectedType == category.type,
                  avatar: Icon(
                    category.icon,
                    size: 18,
                  ),
                  label: Text(category.label),
                  onSelected: (_) =>
                      _search(category.type),
                );
              },
            ),
          ),
          Expanded(
            flex: 5,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.latitude,
                  widget.longitude,
                ),
                zoom: 15,
              ),
              markers: _markers,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
            ),
          ),
          Expanded(
            flex: 4,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _places.isEmpty
                    ? const Center(
                        child: Text(
                          'No nearby results found.',
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _places.length,
                        separatorBuilder: (_, _) =>
                            const Divider(),
                        itemBuilder: (context, index) {
                          final place = _places[index];

                          return ListTile(
                            leading: CircleAvatar(
                              child: Text('${index + 1}'),
                            ),
                            title: Text(
                              place.name.isEmpty
                                  ? 'Nearby place'
                                  : place.name,
                            ),
                            subtitle:
                                place.address.isEmpty
                                    ? null
                                    : Text(place.address),
                            trailing: const Icon(
                              Icons.location_on_outlined,
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
