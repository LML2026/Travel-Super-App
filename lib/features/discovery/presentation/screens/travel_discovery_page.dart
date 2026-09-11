import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../trips/domain/entities/trip.dart';
import '../../../trips/presentation/providers/trip_provider.dart';
import '../../../../core/utils/user_facing_error.dart';
import '../../domain/travel_discovery_models.dart';
import '../providers/travel_discovery_provider.dart';

class TravelDiscoveryPage extends ConsumerStatefulWidget {
  const TravelDiscoveryPage({super.key});

  @override
  ConsumerState<TravelDiscoveryPage> createState() =>
      _TravelDiscoveryPageState();
}

class _TravelDiscoveryPageState extends ConsumerState<TravelDiscoveryPage> {
  final _originController = TextEditingController(text: 'LHR');
  final _destinationController = TextEditingController(text: 'Paris');
  DateTime _startDate = DateTime.now().add(const Duration(days: 14));
  DateTime _endDate = DateTime.now().add(const Duration(days: 17));
  int _travellers = 2;
  int _rooms = 1;
  String _cabinClass = 'economy';
  String _interest = 'culture';
  String _cuisine = 'local';
  DiscoveryCategory? _categoryFilter;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool start}) async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      initialDate: start ? _startDate : _endDate,
    );
    if (selected == null) {
      return;
    }
    setState(() {
      if (start) {
        _startDate = selected;
        if (!_endDate.isAfter(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 1));
        }
      } else {
        _endDate = selected;
      }
    });
  }

  Future<void> _search() async {
    if (_destinationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a destination.')),
      );
      return;
    }
    await ref.read(travelDiscoveryControllerProvider.notifier).search(
          TravelDiscoveryQuery(
            destination: _destinationController.text,
            origin: _originController.text,
            startDate: _startDate,
            endDate: _endDate,
            travellers: _travellers,
            rooms: _rooms,
            cabinClass: _cabinClass,
            interest: _interest,
            cuisine: _cuisine,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final discoveryState = ref.watch(travelDiscoveryControllerProvider);
    final tripsAsync = ref.watch(tripsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Discovery'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeroPanel(onSearch: _search),
          const SizedBox(height: 12),
          _SearchPanel(
            originController: _originController,
            destinationController: _destinationController,
            startDate: _startDate,
            endDate: _endDate,
            travellers: _travellers,
            rooms: _rooms,
            cabinClass: _cabinClass,
            interest: _interest,
            cuisine: _cuisine,
            onStartDate: () => _pickDate(start: true),
            onEndDate: () => _pickDate(start: false),
            onTravellersChanged: (value) => setState(() => _travellers = value),
            onRoomsChanged: (value) => setState(() => _rooms = value),
            onCabinClassChanged: (value) => setState(() => _cabinClass = value),
            onInterestChanged: (value) => setState(() => _interest = value),
            onCuisineChanged: (value) => setState(() => _cuisine = value),
            onSearch: _search,
          ),
          const SizedBox(height: 12),
          tripsAsync.when(
            data: (trips) => _TripSelector(
              trips: trips,
              selectedTripId: discoveryState.valueOrNull?.selectedTripId,
              onChanged: (tripId) {
                ref
                    .read(travelDiscoveryControllerProvider.notifier)
                    .selectTrip(tripId);
              },
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Sign in to add bookings to a trip.'),
          ),
          const SizedBox(height: 12),
          _CategoryFilter(
            selected: _categoryFilter,
            onChanged: (category) => setState(() => _categoryFilter = category),
          ),
          const SizedBox(height: 12),
          discoveryState.when(
            loading: () => const _LoadingResults(),
            error: (error, _) => _ErrorResults(
              message: UserFacingError.message(
                error,
                fallback:
                    'Discovery is unavailable right now. Try again shortly.',
              ),
            ),
            data: (state) {
              final results = _categoryFilter == null
                  ? state.results
                  : state.results
                      .where((result) => result.category == _categoryFilter)
                      .toList(growable: false);
              if (results.isEmpty) {
                return const _EmptyResults();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CompareStrip(state: state),
                  const SizedBox(height: 8),
                  Text(
                    '${results.length} options found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  for (final result in results)
                    _DiscoveryResultCard(
                      result: result,
                      saved: state.savedIds.contains(result.id),
                      comparing: state.compareIds.contains(result.id),
                      onSave: () => ref
                          .read(travelDiscoveryControllerProvider.notifier)
                          .toggleSave(result.id),
                      onCompare: () => ref
                          .read(travelDiscoveryControllerProvider.notifier)
                          .toggleCompare(result.id),
                      onDetails: () => _showDetails(result),
                      onPrimaryAction: () => _primaryAction(result),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _primaryAction(TravelDiscoveryResult result) async {
    final controller = ref.read(travelDiscoveryControllerProvider.notifier);
    try {
      if (result.isBookable) {
        final link = await controller.linkBookableResult(result);
        if (!link.isSuccess) {
          throw StateError(
              link.message ?? 'We could not add this to your trip.');
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              link.wasAlreadyLinked
                  ? 'This item is already linked to your trip.'
                  : 'Travel plan added to your trip.',
            ),
          ),
        );
      } else {
        await controller.addToTrip(result);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to trip itinerary.')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(UserFacingError.message(
            error,
            fallback: 'We could not add this to your trip.',
          )),
        ),
      );
    }
  }

  Future<void> _showDetails(TravelDiscoveryResult result) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_iconFor(result.category)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(result.subtitle),
            const SizedBox(height: 12),
            Text(result.details),
            const SizedBox(height: 12),
            Text('Provider: ${result.provider}'),
            Text('Source: ${result.source.label}'),
            Text('Location: ${result.location}'),
            Text('Duration: ${result.duration}'),
            Text(
              'Estimated price: ${result.currency} ${result.price.toStringAsFixed(0)}',
            ),
            if (result.category == DiscoveryCategory.restaurants)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                    'Demo restaurant data only. Not live reservation availability.'),
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _primaryAction(result);
              },
              icon: Icon(result.isBookable
                  ? Icons.confirmation_num_outlined
                  : Icons.add_location_alt_outlined),
              label:
                  Text(result.isBookable ? 'Add plan to trip' : 'Add to Trip'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              child: Icon(Icons.travel_explore),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover, compare and book',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Flights, hotels, transport, activities and restaurants in one trip-aware flow.',
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onSearch,
              icon: const Icon(Icons.search),
              tooltip: 'Search',
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.originController,
    required this.destinationController,
    required this.startDate,
    required this.endDate,
    required this.travellers,
    required this.rooms,
    required this.cabinClass,
    required this.interest,
    required this.cuisine,
    required this.onStartDate,
    required this.onEndDate,
    required this.onTravellersChanged,
    required this.onRoomsChanged,
    required this.onCabinClassChanged,
    required this.onInterestChanged,
    required this.onCuisineChanged,
    required this.onSearch,
  });

  final TextEditingController originController;
  final TextEditingController destinationController;
  final DateTime startDate;
  final DateTime endDate;
  final int travellers;
  final int rooms;
  final String cabinClass;
  final String interest;
  final String cuisine;
  final VoidCallback onStartDate;
  final VoidCallback onEndDate;
  final ValueChanged<int> onTravellersChanged;
  final ValueChanged<int> onRoomsChanged;
  final ValueChanged<String> onCabinClassChanged;
  final ValueChanged<String> onInterestChanged;
  final ValueChanged<String> onCuisineChanged;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: originController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Origin',
                      prefixIcon: Icon(Icons.flight_takeoff),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: destinationController,
                    decoration: const InputDecoration(
                      labelText: 'Destination',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: 'Start',
                    value: dateFormat.format(startDate),
                    onTap: onStartDate,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DateButton(
                    label: 'End',
                    value: dateFormat.format(endDate),
                    onTap: onEndDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _Stepper(
                    label: 'Travellers',
                    value: travellers,
                    min: 1,
                    onChanged: onTravellersChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Stepper(
                    label: 'Rooms',
                    value: rooms,
                    min: 1,
                    onChanged: onRoomsChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: cabinClass,
                    decoration: const InputDecoration(labelText: 'Cabin'),
                    items: const [
                      DropdownMenuItem(
                          value: 'economy', child: Text('Economy')),
                      DropdownMenuItem(
                          value: 'business', child: Text('Business')),
                      DropdownMenuItem(value: 'first', child: Text('First')),
                    ],
                    onChanged: (value) =>
                        onCabinClassChanged(value ?? 'economy'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: interest,
                    decoration: const InputDecoration(labelText: 'Interest'),
                    items: const [
                      DropdownMenuItem(
                          value: 'culture', child: Text('Culture')),
                      DropdownMenuItem(value: 'food', child: Text('Food')),
                      DropdownMenuItem(value: 'family', child: Text('Family')),
                      DropdownMenuItem(
                          value: 'relaxation', child: Text('Relaxation')),
                    ],
                    onChanged: (value) => onInterestChanged(value ?? 'culture'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: cuisine,
              decoration:
                  const InputDecoration(labelText: 'Restaurant cuisine'),
              items: const [
                DropdownMenuItem(value: 'local', child: Text('Local')),
                DropdownMenuItem(
                    value: 'vegetarian', child: Text('Vegetarian')),
                DropdownMenuItem(value: 'seafood', child: Text('Seafood')),
                DropdownMenuItem(value: 'casual', child: Text('Casual')),
              ],
              onChanged: (value) => onCuisineChanged(value ?? 'local'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onSearch,
              icon: const Icon(Icons.travel_explore),
              label: const Text('Search Everything'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripSelector extends StatelessWidget {
  const _TripSelector({
    required this.trips,
    required this.selectedTripId,
    required this.onChanged,
  });

  final List<Trip> trips;
  final String? selectedTripId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Create a trip to add bookings and itinerary items.'),
        ),
      );
    }
    final selected = selectedTripId ?? trips.first.id;
    if (selectedTripId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onChanged(selected));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<String>(
          initialValue: selected,
          decoration: const InputDecoration(
            labelText: 'Add bookings to trip',
            prefixIcon: Icon(Icons.luggage_outlined),
          ),
          items: [
            for (final trip in trips)
              DropdownMenuItem(
                value: trip.id,
                child: Text('${trip.title} · ${trip.destination}'),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.selected, required this.onChanged});

  final DiscoveryCategory? selected;
  final ValueChanged<DiscoveryCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: selected == null,
            onSelected: (_) => onChanged(null),
          ),
          const SizedBox(width: 8),
          for (final category in DiscoveryCategory.values) ...[
            ChoiceChip(
              avatar: Icon(_iconFor(category), size: 18),
              label: Text(_labelFor(category)),
              selected: selected == category,
              onSelected: (_) => onChanged(category),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _CompareStrip extends StatelessWidget {
  const _CompareStrip({required this.state});

  final TravelDiscoveryState state;

  @override
  Widget build(BuildContext context) {
    final comparing = state.results
        .where((result) => state.compareIds.contains(result.id))
        .toList(growable: false);
    if (comparing.length < 2) {
      return const SizedBox.shrink();
    }
    final cheapest = comparing.reduce((a, b) => a.price <= b.price ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Compare selected options',
                style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            for (final result in comparing)
              Text(
                '${result.title}: ${result.currency} ${result.price.toStringAsFixed(0)}'
                '${result.id == cheapest.id ? ' · best price' : ' · +${(result.price - cheapest.price).toStringAsFixed(0)}'}',
              ),
          ],
        ),
      ),
    );
  }
}

class _DiscoveryResultCard extends StatelessWidget {
  const _DiscoveryResultCard({
    required this.result,
    required this.saved,
    required this.comparing,
    required this.onSave,
    required this.onCompare,
    required this.onDetails,
    required this.onPrimaryAction,
  });

  final TravelDiscoveryResult result;
  final bool saved;
  final bool comparing;
  final VoidCallback onSave;
  final VoidCallback onCompare;
  final VoidCallback onDetails;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('EEE HH:mm');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(child: Icon(_iconFor(result.category))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(result.subtitle),
                      Text(result.source.label),
                      Text(
                          '${result.location} · ${timeFormat.format(result.startTime)}'),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${result.currency} ${result.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    Text('★ ${result.rating.toStringAsFixed(1)}'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: Icon(saved ? Icons.favorite : Icons.favorite_border),
                  label: Text(saved ? 'Saved' : 'Save'),
                  onPressed: onSave,
                ),
                ActionChip(
                  avatar: Icon(comparing
                      ? Icons.compare_arrows
                      : Icons.compare_arrows_outlined),
                  label: Text(comparing ? 'Comparing' : 'Compare'),
                  onPressed: onCompare,
                ),
                ActionChip(
                  avatar: const Icon(Icons.info_outline),
                  label: const Text('Details'),
                  onPressed: onDetails,
                ),
                FilledButton.icon(
                  onPressed: onPrimaryAction,
                  icon: Icon(result.isBookable
                      ? Icons.confirmation_num_outlined
                      : Icons.add_location_alt_outlined),
                  label: Text(
                      result.isBookable ? 'Add plan to trip' : 'Add to Trip'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.event_outlined),
      label: Text('$label: $value'),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.min,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Row(
        children: [
          IconButton(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text('$value'),
          IconButton(
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}

class _LoadingResults extends StatelessWidget {
  const _LoadingResults();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(),
            SizedBox(height: 12),
            Text('Searching demo travel providers...'),
          ],
        ),
      ),
    );
  }
}

class _ErrorResults extends StatelessWidget {
  const _ErrorResults({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('Discovery failed: $message'),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
            'Search to discover flights, hotels, transport, activities and restaurants.'),
      ),
    );
  }
}

IconData _iconFor(DiscoveryCategory category) {
  switch (category) {
    case DiscoveryCategory.flights:
      return Icons.flight_takeoff;
    case DiscoveryCategory.hotels:
      return Icons.hotel_outlined;
    case DiscoveryCategory.transport:
      return Icons.local_taxi_outlined;
    case DiscoveryCategory.activities:
      return Icons.explore_outlined;
    case DiscoveryCategory.restaurants:
      return Icons.restaurant_outlined;
  }
}

String _labelFor(DiscoveryCategory category) {
  switch (category) {
    case DiscoveryCategory.flights:
      return 'Flights';
    case DiscoveryCategory.hotels:
      return 'Hotels';
    case DiscoveryCategory.transport:
      return 'Transport';
    case DiscoveryCategory.activities:
      return 'Activities';
    case DiscoveryCategory.restaurants:
      return 'Restaurants';
  }
}
