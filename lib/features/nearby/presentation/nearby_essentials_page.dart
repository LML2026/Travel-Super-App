import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/travel_card.dart';
import '../../maps/models/places_prefill.dart';
import '../../saved_items/presentation/providers/saved_items_provider.dart';
import '../../trips/domain/entities/trip.dart';
import '../../trips/presentation/providers/trip_activity_provider.dart';
import '../../trips/presentation/providers/trip_provider.dart';
import '../models/nearby_service_filter.dart';
import '../models/nearby_service_metadata.dart';
import '../models/nearby_service_result.dart';
import '../models/nearby_service_type.dart';
import 'providers/nearby_places_provider.dart';
import '../services/nearby_places_service.dart';
import '../services/nearby_service_engine.dart';

class NearbyEssentialsPage extends ConsumerStatefulWidget {
  const NearbyEssentialsPage({
    this.initialService,
    super.key,
  });

  final NearbyServiceType? initialService;

  @override
  ConsumerState<NearbyEssentialsPage> createState() =>
      _NearbyEssentialsPageState();
}

class _NearbyEssentialsPageState extends ConsumerState<NearbyEssentialsPage> {
  final _locationController = TextEditingController();
  NearbyServiceType _selectedService = nearbyEssentialsMvpServices.first;
  NearbyServiceFilter _filter = const NearbyServiceFilter();
  Future<List<NearbyServiceResult>>? _resultsFuture;
  String? _selectedTripId;
  String _submittedLocation = '';

  @override
  void initState() {
    super.initState();
    _selectedService =
        widget.initialService ?? nearbyEssentialsMvpServices.first;
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _search() {
    final location = _locationController.text.trim();
    if (location.isEmpty) {
      setState(() => _resultsFuture = null);
      return;
    }
    setState(() {
      _submittedLocation = location;
      _resultsFuture =
          ref.read(nearbyPlacesServiceProvider).search(NearbyPlacesQuery(
                location: location,
                serviceType: _selectedService,
              ));
    });
  }

  void _selectService(NearbyServiceType service) {
    setState(() {
      _selectedService = service;
      _resultsFuture = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Essentials'),
        actions: [
          IconButton(
            tooltip: 'Open saved places',
            icon: const Icon(Icons.bookmarks_outlined),
            onPressed: () => context.pushSavedItems(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TravelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Explore around your trip',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                    'Nearby results with a clear demo fallback when live search is unavailable.'),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _locationController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    labelText: 'Destination or map location',
                    hintText: 'e.g. Lisbon city centre',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    suffixIcon: IconButton(
                      tooltip: 'Search nearby',
                      onPressed: _search,
                      icon: const Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                trips.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text(
                      'Trip context unavailable. Enter a location to search.'),
                  data: (items) => _TripContextPicker(
                    trips: items,
                    selectedTripId: _selectedTripId,
                    onChanged: (trip) {
                      setState(() {
                        _selectedTripId = trip.id;
                        if (_locationController.text.trim().isEmpty) {
                          _locationController.text = trip.destination;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('What are you looking for?',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: nearbyEssentialsMvpServices.map((service) {
              return ChoiceChip(
                selected: service == _selectedService,
                label: Text(service.metadata.label),
                avatar: Icon(service.metadata.icon, size: 18),
                onSelected: (_) => _selectService(service),
              );
            }).toList(growable: false),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              FilterChip(
                label: const Text('Open now'),
                selected: _filter.openNow,
                onSelected: (value) =>
                    setState(() => _filter = _filter.copyWith(openNow: value)),
              ),
              FilterChip(
                label: const Text('Top rated'),
                selected: _filter.minRating != null,
                onSelected: (value) => setState(() =>
                    _filter = _filter.copyWith(minRating: value ? 4 : null)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_resultsFuture == null)
            _NearbyEmpty(
              service: _selectedService,
              onSearch: _search,
            )
          else
            _Results(
              future: _resultsFuture!,
              location: _submittedLocation,
              selectedTripId: _selectedTripId,
              onSave: (place) => _save(place),
              onDetails: (place) => _showDetails(place),
              onAddToTrip: (place) => _addToTrip(place),
            ),
        ],
      ),
    );
  }

  Future<void> _save(NearbyServiceResult place) async {
    await ref
        .read(savedItemsControllerProvider.notifier)
        .saveNearbyPlace(place);
    if (mounted) _message('${place.name} saved');
  }

  Future<void> _addToTrip(NearbyServiceResult place) async {
    final tripId = _selectedTripId;
    if (tripId == null || tripId.isEmpty) {
      _message('Select a trip before adding this place.');
      return;
    }
    await ref.read(tripActivityActionsProvider).addActivity(
          tripId: tripId,
          title: place.name,
          location: place.address,
          notes: '${place.categoryLabel}. Source: ${_sourceLabel(place)}.',
          scheduledAt: null,
          status: 'Place planned',
        );
    if (mounted) _message('${place.name} added to your trip');
  }

  void _showDetails(NearbyServiceResult place) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Wrap(
          runSpacing: 10,
          children: [
            Row(children: [
              Expanded(
                  child: Text(place.name,
                      style: Theme.of(context).textTheme.titleLarge)),
              IconButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.close)),
            ]),
            Text(place.address),
            Text('${place.categoryLabel} • ${_sourceLabel(place)}'),
            if (place.rating != null)
              Text('Rating ${place.rating!.toStringAsFixed(1)} / 5'),
            if (place.isOpenNow != null)
              Text(place.isOpenNow! ? 'Open now' : 'Closed now'),
            if (place.metadata['description'] is String)
              Text(place.metadata['description']! as String),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Map & route'),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    context.pushMaps(
                      prefill: PlacesPrefill(
                        query: place.name,
                        locationHint: place.address,
                        title: place.name,
                        categories: const NearbyServiceEngine()
                            .categoriesFor(place.serviceType),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Add to trip'),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _addToTrip(place);
                  },
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  String _sourceLabel(NearbyServiceResult place) => switch (place.source) {
        NearbyDataSource.google => 'Live Google Places',
        NearbyDataSource.backend => 'Nearby results',
        _ => 'Demo place data',
      };

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

class _TripContextPicker extends StatelessWidget {
  const _TripContextPicker(
      {required this.trips,
      required this.selectedTripId,
      required this.onChanged});
  final List<Trip> trips;
  final String? selectedTripId;
  final ValueChanged<Trip> onChanged;

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty)
      return const Text('No trips yet. Search any destination above.');
    final current =
        trips.where((trip) => trip.id == selectedTripId).firstOrNull ??
            trips.first;
    return DropdownButtonFormField<String>(
      initialValue: current.id,
      decoration: const InputDecoration(labelText: 'Trip context'),
      items: trips
          .map((trip) => DropdownMenuItem(
              value: trip.id,
              child: Text('${trip.destination} • ${trip.title}')))
          .toList(growable: false),
      onChanged: (id) {
        final match = trips.where((trip) => trip.id == id).firstOrNull;
        if (match != null) onChanged(match);
      },
    );
  }
}

class _NearbyEmpty extends StatelessWidget {
  const _NearbyEmpty({required this.service, required this.onSearch});
  final NearbyServiceType service;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) => TravelCard(
        child: Column(children: [
          Icon(service.metadata.icon, size: 42),
          const SizedBox(height: 10),
          Text('Search for ${service.metadata.label.toLowerCase()} nearby',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(service.metadata.description, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(
              onPressed: onSearch,
              icon: const Icon(Icons.search),
              label: const Text('Search destination')),
        ]),
      );
}

class _Results extends ConsumerWidget {
  const _Results(
      {required this.future,
      required this.location,
      required this.selectedTripId,
      required this.onSave,
      required this.onDetails,
      required this.onAddToTrip});
  final Future<List<NearbyServiceResult>> future;
  final String location;
  final String? selectedTripId;
  final ValueChanged<NearbyServiceResult> onSave;
  final ValueChanged<NearbyServiceResult> onDetails;
  final ValueChanged<NearbyServiceResult> onAddToTrip;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      FutureBuilder<List<NearbyServiceResult>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) return const _NearbyError();
          final places = snapshot.data ?? const <NearbyServiceResult>[];
          if (places.isEmpty)
            return const _NearbyError(
                message: 'No places found. Try a wider destination search.');
          final showingFallback = places.any((place) =>
              place.sourceMetadata['liveUnavailable'] == true ||
              place.source == NearbyDataSource.fallback);
          final saved =
              ref.watch(savedItemsControllerProvider).valueOrNull ?? const [];
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Places near $location',
                    style: Theme.of(context).textTheme.titleMedium),
                if (showingFallback) ...[
                  const SizedBox(height: 8),
                  const Text(
                      'Live nearby results unavailable — showing fallback results.'),
                ],
                const SizedBox(height: 8),
                ...places.map((place) {
                  final isSaved = saved.any((item) => item.id == place.id);
                  return _PlaceCard(
                      place: place,
                      isSaved: isSaved,
                      canAdd: selectedTripId != null,
                      onSave: onSave,
                      onDetails: onDetails,
                      onAddToTrip: onAddToTrip);
                }),
              ]);
        },
      );
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard(
      {required this.place,
      required this.isSaved,
      required this.canAdd,
      required this.onSave,
      required this.onDetails,
      required this.onAddToTrip});
  final NearbyServiceResult place;
  final bool isSaved;
  final bool canAdd;
  final ValueChanged<NearbyServiceResult> onSave;
  final ValueChanged<NearbyServiceResult> onDetails;
  final ValueChanged<NearbyServiceResult> onAddToTrip;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(place.name,
                      style: Theme.of(context).textTheme.titleMedium)),
              if (place.rating != null)
                Chip(
                    avatar: const Icon(Icons.star, size: 15),
                    label: Text(place.rating!.toStringAsFixed(1))),
            ]),
            Text(place.address, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Wrap(spacing: 8, children: [
              Text(
                  switch (place.source) {
                    NearbyDataSource.google => 'Live Google Places',
                    NearbyDataSource.backend => 'Nearby results',
                    _ => 'Demo fallback',
                  },
                  style: Theme.of(context).textTheme.labelSmall),
              if (place.isOpenNow != null)
                Text(place.isOpenNow! ? 'Open now' : 'Closed',
                    style: Theme.of(context).textTheme.labelSmall),
            ]),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 6, children: [
              TextButton.icon(
                  onPressed: () => onDetails(place),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Details')),
              TextButton.icon(
                  onPressed: () => onSave(place),
                  icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                  label: Text(isSaved ? 'Saved' : 'Save')),
              if (canAdd)
                TextButton.icon(
                    onPressed: () => onAddToTrip(place),
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: const Text('Add to trip')),
            ]),
          ]),
        ),
      );
}

class _NearbyError extends StatelessWidget {
  const _NearbyError(
      {this.message =
          'Live search is unavailable right now. Try again or review the demo fallback.'});
  final String message;
  @override
  Widget build(BuildContext context) => TravelCard(
          child: Column(children: [
        const Icon(Icons.place_outlined, size: 40),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center)
      ]));
}
