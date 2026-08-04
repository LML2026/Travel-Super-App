import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/providers/travel_provider_contracts.dart';
import '../../../providers/provider_gateway.dart';
import '../../../trips/domain/entities/trip.dart';
import '../../../trips/presentation/providers/trip_provider.dart';
import '../../../trips/presentation/widgets/map_card.dart';
import '../../models/live_location.dart';
import '../../models/places_prefill.dart';
import '../../models/selected_place.dart';
import '../../providers/live_location_provider.dart';
import '../../services/map_link_service.dart';

class MapsHubPage extends ConsumerStatefulWidget {
  const MapsHubPage({
    this.prefill,
    super.key,
  });

  final PlacesPrefill? prefill;

  @override
  ConsumerState<MapsHubPage> createState() => _MapsHubPageState();
}

class _MapsHubPageState extends ConsumerState<MapsHubPage> {
  final MapLinkService _mapLinkService = const MapLinkService();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedTripId;
  String? _submittedQuery;
  Future<List<PlaceResult>>? _placeResultsFuture;

  @override
  void initState() {
    super.initState();
    final prefill = widget.prefill;
    if (prefill != null && prefill.query.trim().isNotEmpty) {
      _searchController.text = prefill.query;
      _runSearch(prefill.query);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(tripsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps'),
      ),
      body: tripsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(error.toString()),
          ),
        ),
        data: (trips) {
          if (trips.isEmpty) {
            return _EmptyMapsState(onOpenTrips: () => context.pushTrips());
          }

          final selectedTrip = _resolveSelectedTrip(trips);
          final currentLocationAsync = ref.watch(liveLocationProvider);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MapsIntroCard(
                tripCount: trips.length,
                selectedTrip: selectedTrip,
                onOpenTrips: () => context.pushTrips(),
                onOpenTransport: () => context.pushTransport(),
              ),
              const SizedBox(height: 12),
              _LiveLocationCard(
                currentLocationAsync: currentLocationAsync,
                onRefresh: () => ref.invalidate(liveLocationProvider),
                onUseInSearch: (location) {
                  _searchController.text = location.coordinatesLabel;
                  return _launch(
                    _mapLinkService.directionsUri(
                      origin: location.coordinatesLabel,
                      destination: selectedTrip.destination,
                      travelMode: 'walking',
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _TripSelectorCard(
                trips: trips,
                selectedTripId: selectedTrip.id,
                onChanged: (tripId) {
                  setState(() {
                    _selectedTripId = tripId;
                  });
                },
              ),
              const SizedBox(height: 12),
              const MapCard(),
              const SizedBox(height: 12),
              _SearchCard(
                controller: _searchController,
                mapLinkService: _mapLinkService,
                onSearchSubmitted: _runSearch,
              ),
              if (widget.prefill != null) ...[
                const SizedBox(height: 12),
                _AiPlacesPrefillBanner(prefill: widget.prefill!),
              ],
              if (_placeResultsFuture != null) ...[
                const SizedBox(height: 12),
                _PlacesResultsSection(
                  future: _placeResultsFuture!,
                  query: _submittedQuery ?? '',
                  prefill: widget.prefill,
                  onAddToTrip: (place) => Navigator.of(context).pop(place),
                  onOpenMap: (place) => _launch(
                    _mapLinkService.searchUri(
                      place.address.isNotEmpty ? place.address : place.name,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _runSearch(String value) {
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _submittedQuery = null;
        _placeResultsFuture = null;
      });
      return;
    }

    final categories = widget.prefill?.categories ?? const <PlaceCategory>{};

    setState(() {
      _submittedQuery = query;
      _placeResultsFuture = ref.read(providerGatewayProvider).searchPlaces(
            query: query,
            categories: categories,
            limit: 8,
          );
    });
  }

  Trip _resolveSelectedTrip(List<Trip> trips) {
    final selectedTripId = _selectedTripId;
    if (selectedTripId != null) {
      for (final trip in trips) {
        if (trip.id == selectedTripId) {
          return trip;
        }
      }
    }

    final now = DateTime.now();
    final upcomingTrips = trips.where((trip) => trip.endDate.isAfter(now)).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final selected = upcomingTrips.isNotEmpty ? upcomingTrips.first : trips.first;

    if (_selectedTripId != selected.id) {
      _selectedTripId = selected.id;
    }

    return selected;
  }

  Future<void> _launch(Uri uri) async {
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (success || !mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open map link.')),
    );
  }
}

class _EmptyMapsState extends StatelessWidget {
  const _EmptyMapsState({required this.onOpenTrips});

  final VoidCallback onOpenTrips;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              'No trips available for maps yet.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Create a trip to see map routes, hotels, airports, and nearby places here.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onOpenTrips,
              icon: const Icon(Icons.luggage_outlined),
              label: const Text('Open Trips'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapsIntroCard extends StatelessWidget {
  const _MapsIntroCard({
    required this.tripCount,
    required this.selectedTrip,
    required this.onOpenTrips,
    required this.onOpenTransport,
  });

  final int tripCount;
  final Trip selectedTrip;
  final VoidCallback onOpenTrips;
  final VoidCallback onOpenTransport;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.map_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Maps hub for $tripCount trip${tripCount == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${selectedTrip.destination} is the active map context. Open routes, nearby places, and handoffs from one place.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onOpenTrips,
                  icon: const Icon(Icons.luggage_outlined),
                  label: const Text('All trips'),
                ),
                FilledButton.tonalIcon(
                  onPressed: onOpenTransport,
                  icon: const Icon(Icons.alt_route_outlined),
                  label: const Text('Transport hub'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TripSelectorCard extends StatelessWidget {
  const _TripSelectorCard({
    required this.trips,
    required this.selectedTripId,
    required this.onChanged,
  });

  final List<Trip> trips;
  final String selectedTripId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip context',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedTripId,
              decoration: const InputDecoration(
                labelText: 'Selected trip',
                border: OutlineInputBorder(),
              ),
              items: trips
                  .map(
                    (trip) => DropdownMenuItem<String>(
                      value: trip.id,
                      child: Text('${trip.destination} • ${trip.title}'),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.controller,
    required this.mapLinkService,
    required this.onSearchSubmitted,
  });

  final TextEditingController controller;
  final MapLinkService mapLinkService;
  final ValueChanged<String> onSearchSubmitted;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search the map',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Search a place, station, or venue',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                final query = value.trim();
                if (query.isEmpty) {
                  return;
                }
                onSearchSubmitted(query);
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => onSearchSubmitted(controller.text),
                icon: const Icon(Icons.search),
                label: const Text('Search in app'),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SearchChip(
                  label: 'Pharmacy',
                  onTap: () => _openQuery('pharmacy near me'),
                ),
                _SearchChip(
                  label: 'ATM',
                  onTap: () => _openQuery('ATM near me'),
                ),
                _SearchChip(
                  label: 'Restaurant',
                  onTap: () => _openQuery('restaurants near me'),
                ),
                _SearchChip(
                  label: 'Gate',
                  onTap: () => _openQuery('airport gate directions'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openQuery(String query) async {
    await launchUrl(
      mapLinkService.searchUri(query),
      mode: LaunchMode.externalApplication,
    );
  }
}

class _SearchChip extends StatelessWidget {
  const _SearchChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _LiveLocationCard extends StatelessWidget {
  const _LiveLocationCard({
    required this.currentLocationAsync,
    required this.onRefresh,
    required this.onUseInSearch,
  });

  final AsyncValue<LiveLocation> currentLocationAsync;
  final VoidCallback onRefresh;
  final Future<void> Function(LiveLocation location) onUseInSearch;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.my_location_outlined),
                const SizedBox(width: 8),
                Text(
                  'Live location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            currentLocationAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Location unavailable: $error'),
              data: (location) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Coordinates: ${location.coordinatesLabel}'),
                  const SizedBox(height: 4),
                  Text('Accuracy: ${location.accuracy.toStringAsFixed(1)} m'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () => onUseInSearch(location),
                        icon: const Icon(Icons.navigation_outlined),
                        label: const Text('Use in route'),
                      ),
                      OutlinedButton.icon(
                        onPressed: onRefresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiPlacesPrefillBanner extends StatelessWidget {
  const _AiPlacesPrefillBanner({required this.prefill});

  final PlacesPrefill prefill;

  @override
  Widget build(BuildContext context) {
    final scheduledAt = prefill.scheduledAt;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    prefill.title ?? 'AI suggested place search',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Suggested search: ${prefill.query}'),
            if (prefill.categories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: prefill.categories
                      .map((category) => Chip(label: Text(category.name)))
                      .toList(growable: false),
                ),
              ),
            if (prefill.locationHint != null && prefill.locationHint!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Location hint: ${prefill.locationHint}'),
              ),
            if (scheduledAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Suggested time: ${scheduledAt.toLocal()}'),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlacesResultsSection extends StatelessWidget {
  const _PlacesResultsSection({
    required this.future,
    required this.query,
    required this.prefill,
    required this.onAddToTrip,
    required this.onOpenMap,
  });

  final Future<List<PlaceResult>> future;
  final String query;
  final PlacesPrefill? prefill;
  final ValueChanged<SelectedPlace> onAddToTrip;
  final ValueChanged<SelectedPlace> onOpenMap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<PlaceResult>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text('Could not load places: ${snapshot.error}');
            }

            final places = snapshot.data ?? const <PlaceResult>[];
            if (places.isEmpty) {
              return Text('No places found for "$query".');
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nearby results',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                ...places.map((place) {
                  final selected = SelectedPlace(
                    name: place.name,
                    address: place.address ?? '',
                    latitude: place.location?.latitude,
                    longitude: place.location?.longitude,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  place.name,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (place.rating != null)
                                Chip(label: Text(place.rating!.toStringAsFixed(1))),
                            ],
                          ),
                          if ((place.address ?? '').isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(place.address!),
                          ],
                          if ((place.description ?? '').isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(place.description!),
                          ],
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => onOpenMap(selected),
                                icon: const Icon(Icons.map_outlined),
                                label: const Text('Open Map'),
                              ),
                              if (prefill != null)
                                FilledButton.icon(
                                  onPressed: () => onAddToTrip(selected),
                                  icon: const Icon(Icons.bookmark_add_outlined),
                                  label: const Text('Add to Trip'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}