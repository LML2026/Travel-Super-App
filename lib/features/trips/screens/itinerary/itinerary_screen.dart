import 'package:flutter/material.dart';

import '../../../../core/itinerary_ordering.dart';
import '../../../../core/services/itinerary_optimizer.dart';
import '../../../../core/services/route_service.dart';
import '../../../../core/storage/itinerary_storage_service.dart';
import '../../models/itinerary/itinerary_item.dart';
import '../../models/trip.dart';
import 'add_itinerary_item_screen.dart';
import 'edit_itinerary_item_screen.dart';
import '../map/trip_map_screen.dart';

class ItineraryScreen extends StatefulWidget {
  final Trip trip;

  const ItineraryScreen({super.key, required this.trip});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final List<ItineraryItem> _items = [];
  final ItineraryStorageService _storage = ItineraryStorageService();
  final Map<String, RouteResult> _routes = {};
  final Set<DateTime> _optimizingDays = {};

  bool _isLoading = true;
  TravelMode _travelMode = TravelMode.walking;
  int _routeLoadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _storage.loadItems(widget.trip.id);

    if (!mounted) return;

    setState(() {
      _items
        ..clear()
        ..addAll(items);

      _sortItems();
      _isLoading = false;
    });

    _loadRoutes();
  }

  void _sortItems() {
    final ordered = orderItineraryItems(_items);
    _items
      ..clear()
      ..addAll(ordered);
  }

  Future<void> _persistItems() async {
    await _storage.saveItems(widget.trip.id, _items);
  }

  Future<void> _addItem() async {
    final item = await Navigator.of(context).push<ItineraryItem>(
      MaterialPageRoute(
        builder: (_) => AddItineraryItemScreen(trip: widget.trip),
      ),
    );

    if (item == null || !mounted) return;

    setState(() {
      _items.add(item);
      _sortItems();
    });

    await _persistItems();
    await _loadRoutes();
  }

  Future<void> _editItem(ItineraryItem item) async {
    final updatedItem = await Navigator.of(context).push<ItineraryItem>(
      MaterialPageRoute(
        builder: (_) => EditItineraryItemScreen(trip: widget.trip, item: item),
      ),
    );

    if (updatedItem == null || !mounted) return;

    final index = _items.indexWhere(
      (existingItem) => existingItem.id == item.id,
    );

    if (index < 0) return;

    setState(() {
      _items[index] = updatedItem;
      _sortItems();
    });

    await _persistItems();
    await _loadRoutes();
  }

  Future<void> _deleteItem(ItineraryItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete itinerary item?'),
        content: Text('Delete "${item.title}" from this itinerary?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    final updatedItems = _items
        .where((existingItem) => existingItem.id != item.id)
        .toList();

    await _storage.saveItems(widget.trip.id, updatedItems);

    if (!mounted) return;

    setState(() {
      _items
        ..clear()
        ..addAll(updatedItems);

      _sortItems();
    });

    await _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    final generation = ++_routeLoadGeneration;
    final routes = <String, RouteResult>{};

    await Future.wait(
      _routePairs().map((pair) async {
        final route = await RouteService.calculate(
          originLatitude: pair.origin.latitude!,
          originLongitude: pair.origin.longitude!,
          destinationLatitude: pair.destination.latitude!,
          destinationLongitude: pair.destination.longitude!,
          travelMode: _travelMode,
        );

        if (route != null) routes[pair.key] = route;
      }),
    );

    if (!mounted || generation != _routeLoadGeneration) return;

    setState(() {
      _routes
        ..clear()
        ..addAll(routes);
    });
  }

  Future<RouteResult?> _lookupOptimizationRoute(
    ItineraryItem origin,
    ItineraryItem destination,
    TravelMode travelMode,
  ) {
    return RouteService.calculate(
      originLatitude: origin.latitude!,
      originLongitude: origin.longitude!,
      destinationLatitude: destination.latitude!,
      destinationLongitude: destination.longitude!,
      travelMode: travelMode,
    );
  }

  Future<void> _optimizeDay(DateTime date) async {
    final day = itineraryDay(date);
    if (_optimizingDays.contains(day)) return;

    setState(() => _optimizingDays.add(day));

    final result = await ItineraryOptimizer.optimizeDay(
      items: List<ItineraryItem>.from(_items),
      day: day,
      travelMode: _travelMode,
      routeLookup: _lookupOptimizationRoute,
    );

    if (!mounted) return;
    setState(() => _optimizingDays.remove(day));

    if (result == null) return;

    final shouldApply = await _showOptimizationPreview(result);
    if (shouldApply != true || !mounted) return;

    final replacements = <String, ItineraryItem>{
      for (var index = 0; index < result.suggestedDayItems.length; index++)
        result.suggestedDayItems[index].id: result.suggestedDayItems[index]
            .copyWith(orderIndex: index),
    };

    setState(() {
      for (var index = 0; index < _items.length; index++) {
        final replacement = replacements[_items[index].id];
        if (replacement != null) _items[index] = replacement;
      }
      _sortItems();
      _routes.clear();
    });

    await _persistItems();
    await _loadRoutes();
  }

  Future<bool?> _showOptimizationPreview(ItineraryOptimizationResult result) {
    final unmappedCount = result.suggestedDayItems
        .where((item) => item.latitude == null || item.longitude == null)
        .length;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suggested order'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (
                var index = 0;
                index < result.suggestedDayItems.length;
                index++
              )
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${index + 1}. ${result.suggestedDayItems[index].title}',
                  ),
                ),
              const SizedBox(height: 12),
              if (result.hasReliableDurations) ...[
                Text('Current travel: ${result.currentDurationMinutes} min'),
                Text(
                  'Suggested travel: ${result.suggestedDurationMinutes} min',
                ),
                Text('Potential saving: ${result.savingMinutes} min'),
              ] else
                const Text('Estimated route improvement available.'),
              if (unmappedCount > 0) ...[
                const SizedBox(height: 12),
                Text(
                  '$unmappedCount unmapped '
                  '${unmappedCount == 1 ? 'stop was' : 'stops were'} kept '
                  'in the existing position and excluded from route estimates.',
                ),
              ],
              const SizedBox(height: 12),
              const Text('Activity times will remain unchanged.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Apply suggested order'),
          ),
        ],
      ),
    );
  }

  List<_ItineraryRoutePair> _routePairs() {
    final pairs = <_ItineraryRoutePair>[];

    for (final items in _groupItemsByDate().values) {
      for (var index = 0; index < items.length - 1; index++) {
        final origin = items[index];
        final destination = items[index + 1];

        if (origin.latitude == null ||
            origin.longitude == null ||
            destination.latitude == null ||
            destination.longitude == null) {
          continue;
        }

        pairs.add(
          _ItineraryRoutePair(origin: origin, destination: destination),
        );
      }
    }

    return pairs;
  }

  String _formatRouteDistance(int metres) {
    if (metres < 1000) return '$metres m';

    return '${(metres / 1000).toStringAsFixed(1)} km';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  int _dayNumber(DateTime date) {
    final start = DateTime(
      widget.trip.departureDate.year,
      widget.trip.departureDate.month,
      widget.trip.departureDate.day,
    );

    final current = DateTime(date.year, date.month, date.day);

    return current.difference(start).inDays + 1;
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant_outlined;

      case 'transport':
        return Icons.directions_transit_outlined;

      case 'hotel':
        return Icons.hotel_outlined;

      case 'shopping':
        return Icons.shopping_bag_outlined;

      case 'attraction':
        return Icons.photo_camera_outlined;

      default:
        return Icons.place_outlined;
    }
  }

  double get _totalEstimatedCost {
    return _items.fold<double>(
      0,
      (total, item) => total + (item.estimatedCost ?? 0),
    );
  }

  Map<DateTime, List<ItineraryItem>> _groupItemsByDate() {
    final grouped = <DateTime, List<ItineraryItem>>{};

    for (final item in _items) {
      final date = DateTime(item.date.year, item.date.month, item.date.day);

      grouped.putIfAbsent(date, () => []);

      grouped[date]!.add(item);
    }

    final sortedDates = grouped.keys.toList()..sort();

    return {for (final date in sortedDates) date: grouped[date]!};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.trip.destination} Itinerary'),
        actions: [
          IconButton(
            tooltip: 'Trip Map',
            icon: const Icon(Icons.map_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TripMapScreen(
                    trip: widget.trip,
                    items: List<ItineraryItem>.from(_items),
                    travelMode: _travelMode,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? _buildEmptyState(context)
          : _buildTimeline(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.route_outlined, size: 72),
            const SizedBox(height: 20),
            Text(
              'No itinerary items yet',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Add activities, restaurants, transport, attractions and bookings for ${widget.trip.destination}.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final grouped = _groupItemsByDate();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        _buildSummaryCard(context),
        const SizedBox(height: 12),
        _buildTravelModeSelector(),
        const SizedBox(height: 28),

        for (final entry in grouped.entries) ...[
          _buildDayHeader(context, entry.key, entry.value),
          const SizedBox(height: 12),

          for (var i = 0; i < entry.value.length; i++)
            _buildTimelineItem(
              context,
              entry.value[i],
              routeToNext: i < entry.value.length - 1
                  ? _routes[_ItineraryRoutePair.keyFor(
                      entry.value[i],
                      entry.value[i + 1],
                    )]
                  : null,
              isLast: i == entry.value.length - 1,
            ),

          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildTravelModeSelector() {
    return SegmentedButton<TravelMode>(
      segments: const [
        ButtonSegment(
          value: TravelMode.walking,
          icon: Icon(Icons.directions_walk),
          label: Text('Walking'),
        ),
        ButtonSegment(
          value: TravelMode.driving,
          icon: Icon(Icons.directions_car_outlined),
          label: Text('Driving'),
        ),
      ],
      selected: {_travelMode},
      onSelectionChanged: (selection) {
        setState(() {
          _travelMode = selection.first;
          _routes.clear();
        });
        _loadRoutes();
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final bookedCount = _items.where((item) => item.isBooked).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: _SummaryValue(
                label: 'Plans',
                value: _items.length.toString(),
              ),
            ),
            Expanded(
              child: _SummaryValue(
                label: 'Booked',
                value: bookedCount.toString(),
              ),
            ),
            Expanded(
              child: _SummaryValue(
                label: 'Est. cost',
                value:
                    '${widget.trip.currency} ${_totalEstimatedCost.toStringAsFixed(0)}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayHeader(
    BuildContext context,
    DateTime date,
    List<ItineraryItem> items,
  ) {
    final day = itineraryDay(date);
    final mappedCount = items
        .where((item) => item.latitude != null && item.longitude != null)
        .length;
    final isOptimizing = _optimizingDays.contains(day);

    return Row(
      children: [
        CircleAvatar(radius: 20, child: Text('${_dayNumber(date)}')),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Day ${_dayNumber(date)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatDate(date),
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
        if (mappedCount >= 3)
          TextButton.icon(
            onPressed: isOptimizing ? null : () => _optimizeDay(day),
            icon: isOptimizing
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_outlined),
            label: Text(isOptimizing ? 'Optimizing...' : 'Optimize day'),
          ),
      ],
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    ItineraryItem item, {
    required RouteResult? routeToNext,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 58,
            child: Column(
              children: [
                Text(
                  item.time ?? '—',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 2,
                  height: isLast ? 20 : 120,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _editItem(item),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            child: Icon(_categoryIcon(item.category), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (item.isBooked) const Chip(label: Text('Booked')),
                          IconButton(
                            tooltip: 'Delete item',
                            onPressed: () => _deleteItem(item),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        item.category,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      if (item.location.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 18),
                            const SizedBox(width: 6),
                            Expanded(child: Text(item.location)),
                          ],
                        ),
                      ],

                      if (item.estimatedCost != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.payments_outlined, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.trip.currency} '
                              '${item.estimatedCost!.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ],

                      if (item.notes.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          item.notes,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],

                      if (routeToNext != null) ...[
                        const Divider(height: 24),
                        Row(
                          children: [
                            Icon(
                              _travelMode == TravelMode.walking
                                  ? Icons.directions_walk
                                  : Icons.directions_car_outlined,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${routeToNext.durationMinutes} min '
                              '${_travelMode.label} · '
                              '${_formatRouteDistance(routeToNext.distanceMetres)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItineraryRoutePair {
  final ItineraryItem origin;
  final ItineraryItem destination;

  const _ItineraryRoutePair({required this.origin, required this.destination});

  String get key => keyFor(origin, destination);

  static String keyFor(ItineraryItem origin, ItineraryItem destination) {
    return '${origin.id}|${destination.id}';
  }
}

class _SummaryValue extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
