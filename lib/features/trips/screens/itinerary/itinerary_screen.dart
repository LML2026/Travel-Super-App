import 'package:flutter/material.dart';

import '../../../../core/itinerary_ordering.dart';
import '../../../../core/journey_intelligence/analyzers/missing_coordinate_analyzer.dart';
import '../../../../core/journey_intelligence/companion_policy.dart';
import '../../../../core/journey_intelligence/companion_policy_context.dart';
import '../../../../core/journey_intelligence/journey_analyzer.dart';
import '../../../../core/journey_intelligence/journey_companion_presenter.dart';
import '../../../../core/journey_intelligence/journey_context_builder.dart';
import '../../../../core/journey_intelligence/journey_clock.dart';
import '../../../../core/journey_intelligence/journey_insight.dart';
import '../../../../core/services/itinerary_optimizer.dart';
import '../../../../core/services/route_service.dart';
import '../../../../core/storage/itinerary_storage_service.dart';
import '../../../../core/widgets/app_attention_card.dart';
import '../../../../core/widgets/app_itinerary_item.dart';
import '../../../../core/widgets/app_journey_brief.dart';
import '../../../../core/widgets/app_journey_connector.dart';
import '../../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete itinerary item?'),
        content: Text('Delete "${item.title}" from this itinerary?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
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

  JourneyCompanionViewModel? get _companionViewModel {
    const analyzers = <JourneyAnalyzer>[MissingCoordinateAnalyzer()];
    final context = JourneyContextBuilder.build(
      trip: widget.trip,
      items: _items,
      clock: DateTime.now(),
      clockSource: JourneyClockSource.deviceLocal,
    );
    final insights = analyzers
        .expand((analyzer) => analyzer.analyze(context))
        .toList(growable: false);
    final decision = CompanionPolicy.decide(
      insights: insights,
      context: CompanionPolicyContext(
        clock: context.clock,
        availableActions: const {JourneyActionType.openMap},
      ),
    );

    return JourneyCompanionPresenter.present(decision);
  }

  void _openMap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TripMapScreen(
          trip: widget.trip,
          items: List<ItineraryItem>.from(_items),
          travelMode: _travelMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.trip.destination} ${l10n.itinerary}'),
        actions: [
          IconButton(
            tooltip: l10n.map,
            icon: const Icon(Icons.map_outlined),
            onPressed: _openMap,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        icon: const Icon(Icons.add),
        label: Text('${l10n.add} Item'),
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
    final l10n = AppLocalizations.of(context);
    final companion = _companionViewModel;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            _buildSummaryCard(context),
            const SizedBox(height: 12),
            _buildJourneyBrief(context),
            if (companion != null) ...[
              const SizedBox(height: 12),
              _buildCompanionSurface(context, companion),
            ],
            const SizedBox(height: 12),
            _buildTravelModeSelector(),
            const SizedBox(height: 28),

            for (final entry in grouped.entries) ...[
              _buildDayHeader(context, entry.key, entry.value),
              const SizedBox(height: 12),

              for (var i = 0; i < entry.value.length; i++) ...[
                AppItineraryItem(
                  item: entry.value[i],
                  categoryIcon: _categoryIcon(entry.value[i].category),
                  bookedLabel: 'Booked',
                  editLabel: l10n.edit,
                  deleteLabel: l10n.delete,
                  formatMinutes: (minutes) => '$minutes min',
                  onOpen: () => _editItem(entry.value[i]),
                  onEdit: () => _editItem(entry.value[i]),
                  onDelete: () => _deleteItem(entry.value[i]),
                ),
                if (i < entry.value.length - 1)
                  AppJourneyConnector(
                    durationMinutes:
                        _routes[_ItineraryRoutePair.keyFor(
                              entry.value[i],
                              entry.value[i + 1],
                            )]
                            ?.durationMinutes ??
                        entry.value[i].travelMinutesToNext,
                    distanceMetres:
                        _routes[_ItineraryRoutePair.keyFor(
                              entry.value[i],
                              entry.value[i + 1],
                            )]
                            ?.distanceMetres,
                    travelModeLabel:
                        _routes[_ItineraryRoutePair.keyFor(
                              entry.value[i],
                              entry.value[i + 1],
                            )] !=
                            null
                        ? _travelMode.label
                        : null,
                    formatMinutes: (minutes) => '$minutes min',
                    formatDistance: _formatRouteDistance,
                  ),
              ],

              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
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

  Widget _buildJourneyBrief(BuildContext context) {
    final firstItem = _items.isEmpty ? null : _items.first;
    final mappedCount = _items
        .where((item) => item.latitude != null && item.longitude != null)
        .length;
    final bookedCount = _items.where((item) => item.isBooked).length;
    final totalCost = _items.fold<double>(
      0,
      (total, item) => total + (item.estimatedCost ?? 0),
    );

    return AppJourneyBrief(
      title: 'Journey brief',
      lines: [
        AppJourneyBriefLine(
          icon: Icons.route_outlined,
          label: 'Stops',
          value: '${_items.length} planned',
        ),
        if (firstItem != null)
          AppJourneyBriefLine(
            icon: Icons.schedule_outlined,
            label: 'First stop',
            value: firstItem.time == null
                ? firstItem.title
                : '${firstItem.title} at ${firstItem.time}',
          ),
        if (mappedCount < _items.length)
          AppJourneyBriefLine(
            icon: Icons.location_off_outlined,
            label: 'Map coverage',
            value:
                '${_items.length - mappedCount} location(s) need coordinates',
          ),
        if (bookedCount > 0)
          AppJourneyBriefLine(
            icon: Icons.bookmark_outline,
            label: 'Booked',
            value: '$bookedCount item(s)',
          ),
        if (totalCost > 0)
          AppJourneyBriefLine(
            icon: Icons.payments_outlined,
            label: 'Estimated cost',
            value: '${widget.trip.currency} ${totalCost.toStringAsFixed(2)}',
          ),
      ],
    );
  }

  Widget _buildCompanionSurface(
    BuildContext context,
    JourneyCompanionViewModel companion,
  ) {
    final l10n = AppLocalizations.of(context);

    return AppAttentionCard(
      title: l10n.needsAttention,
      detail: switch (companion.message) {
        JourneyCompanionMessage.missingCoordinates =>
          l10n.locationsNeedCoordinates(companion.arguments['count']! as int),
        JourneyCompanionMessage.comingUp => '',
      },
      actionLabel: l10n.map,
      onAction: _openMap,
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
