import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/utils/user_facing_error.dart';
import '../../../flights/models/saved_flight.dart';
import '../../../flights/providers/flight_provider.dart';
import '../../../hotels/models/saved_hotel.dart';
import '../../../hotels/providers/hotel_provider.dart';
import '../../../taxi/domain/entities/taxi_saved_ride.dart';
import '../../../taxi/presentation/providers/taxi_hub_provider.dart';
import '../../../trips/domain/entities/trip.dart';
import '../../../trips/presentation/providers/trip_provider.dart';
import '../../domain/saved_item.dart';
import '../providers/saved_items_provider.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class SavedItemsPage extends ConsumerStatefulWidget {
  const SavedItemsPage({super.key});

  @override
  ConsumerState<SavedItemsPage> createState() => _SavedItemsPageState();
}

class _SavedItemsPageState extends ConsumerState<SavedItemsPage> {
  SavedItemCategory? _category;
  String? _selectedTripId;

  @override
  Widget build(BuildContext context) {
    final savedItemsAsync = ref.watch(savedItemsControllerProvider);
    final flightsAsync = ref.watch(savedFlightsProvider);
    final hotelsAsync = ref.watch(savedHotelsProvider);
    final tripsAsync = ref.watch(tripsProvider);
    final effectiveTripId =
        _selectedTripId ?? _firstTripId(tripsAsync.valueOrNull);
    final ridesAsync = effectiveTripId == null
        ? null
        : ref.watch(taxiSavedRidesForTripProvider(effectiveTripId));

    return Scaffold(
      appBar: AppBar(title: Text(context.ui('savedItems'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          tripsAsync.when(
            data: (trips) => DropdownButtonFormField<String>(
              initialValue: effectiveTripId,
              decoration: InputDecoration(
                labelText: context.ui('tripForSavedTransportActions'),
              ),
              items: [
                for (final trip in trips)
                  DropdownMenuItem(
                    value: trip.id,
                    child: Text('${trip.title} · ${trip.destination}'),
                  ),
              ],
              onChanged: (value) => setState(() => _selectedTripId = value),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) =>
                Text(context.ui('signInAddSavedItems')),
          ),
          const SizedBox(height: 12),
          _CategoryFilter(
            selected: _category,
            onChanged: (value) => setState(() => _category = value),
          ),
          const SizedBox(height: 12),
          savedItemsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text(UserFacingError.message(
              error,
              fallback: 'Saved items are unavailable right now.',
            )),
            data: (items) {
              final filtered = _category == null
                  ? items
                  : items.where((item) => item.category == _category).toList();
              return _DiscoverySavedSection(
                items: filtered,
                tripId: effectiveTripId,
                onRemove: (item) => ref
                    .read(savedItemsControllerProvider.notifier)
                    .remove(item.id),
                onBook: (_) => context.pushTravelDiscovery(),
                onAddToTrip: (item) async {
                  final tripId = effectiveTripId;
                  if (tripId == null) return;
                  await ref
                      .read(savedItemsControllerProvider.notifier)
                      .addToTrip(item: item, tripId: tripId);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.title} ${context.ui('addedToTripSuffix')}')),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
          _SavedFlightsSection(
            flights: flightsAsync.valueOrNull ?? const [],
            isLoading: flightsAsync.isLoading,
            onOpen: context.pushSavedFlightDetails,
            onRemove: (flight) =>
                ref.read(removeSavedFlightProvider(flight.id).future),
          ),
          const SizedBox(height: 12),
          _SavedHotelsSection(
            hotels: hotelsAsync.valueOrNull ?? const [],
            isLoading: hotelsAsync.isLoading,
            onOpen: context.pushSavedHotelDetails,
            onRemove: (hotel) =>
                ref.read(removeSavedHotelProvider(hotel.id).future),
          ),
          const SizedBox(height: 12),
          _SavedRidesSection(
            rides: ridesAsync?.valueOrNull ?? const [],
            isLoading: ridesAsync?.isLoading ?? false,
          ),
        ],
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.selected, required this.onChanged});

  final SavedItemCategory? selected;
  final ValueChanged<SavedItemCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: Text(context.ui('all')),
            selected: selected == null,
            onSelected: (_) => onChanged(null),
          ),
          const SizedBox(width: 8),
          for (final category in SavedItemCategory.values) ...[
            ChoiceChip(
              label: Text(_label(category)),
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

class _DiscoverySavedSection extends StatelessWidget {
  const _DiscoverySavedSection({
    required this.items,
    required this.tripId,
    required this.onRemove,
    required this.onAddToTrip,
    required this.onBook,
  });

  final List<SavedItem> items;
  final String? tripId;
  final ValueChanged<SavedItem> onRemove;
  final ValueChanged<SavedItem> onAddToTrip;
  final ValueChanged<SavedItem> onBook;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
              'No saved discovery items yet. Save activities, restaurants or places from Discovery.'),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.ui('savedDiscovery'),
            style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        for (final item in items)
          Card(
            child: ListTile(
              leading: Icon(_icon(item.category)),
              title: Text(item.title),
              subtitle: Text('${item.location} · ${item.provider}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'remove') onRemove(item);
                  if (value == 'add') onAddToTrip(item);
                  if (value == 'book') onBook(item);
                },
                itemBuilder: (context) => [
                  if (item.isTripActivity && tripId != null)
                    PopupMenuItem(
                        value: 'add', child: Text(context.ui('addToTrip'))),
                  PopupMenuItem(
                    value: 'book',
                    enabled: item.isBookable,
                    child: Text(context.ui('proceedToBooking')),
                  ),
                  PopupMenuItem(value: 'remove', child: Text(context.ui('remove'))),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SavedFlightsSection extends StatelessWidget {
  const _SavedFlightsSection({
    required this.flights,
    required this.isLoading,
    required this.onOpen,
    required this.onRemove,
  });

  final List<SavedFlight> flights;
  final bool isLoading;
  final ValueChanged<SavedFlight> onOpen;
  final ValueChanged<SavedFlight> onRemove;

  @override
  Widget build(BuildContext context) {
    return _GenericSavedSection(
      title: context.ui('savedFlights'),
      isLoading: isLoading,
      empty: context.ui('noSavedFlightsAvailable'),
      children: [
        for (final flight in flights)
          ListTile(
            leading: const Icon(Icons.flight_takeoff),
            title: Text(flight.flightNumber),
            subtitle: Text(
              '${flight.origin} ${context.ui('to')} ${flight.destination}',
            ),
            onTap: () => onOpen(flight),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => onRemove(flight),
            ),
          ),
      ],
    );
  }
}

class _SavedHotelsSection extends StatelessWidget {
  const _SavedHotelsSection({
    required this.hotels,
    required this.isLoading,
    required this.onOpen,
    required this.onRemove,
  });

  final List<SavedHotel> hotels;
  final bool isLoading;
  final ValueChanged<SavedHotel> onOpen;
  final ValueChanged<SavedHotel> onRemove;

  @override
  Widget build(BuildContext context) {
    return _GenericSavedSection(
      title: context.ui('savedHotels'),
      isLoading: isLoading,
      empty: context.ui('noSavedHotelsAvailable'),
      children: [
        for (final hotel in hotels)
          ListTile(
            leading: const Icon(Icons.hotel_outlined),
            title: Text(hotel.name),
            subtitle: Text(
                '${hotel.city} · ${hotel.currency} ${hotel.totalPrice.toStringAsFixed(0)}'),
            onTap: () => onOpen(hotel),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => onRemove(hotel),
            ),
          ),
      ],
    );
  }
}

class _SavedRidesSection extends StatelessWidget {
  const _SavedRidesSection({required this.rides, required this.isLoading});

  final List<TaxiSavedRide> rides;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return _GenericSavedSection(
      title: context.ui('savedTransport'),
      isLoading: isLoading,
      empty: context.ui('noSavedRidesForSelectedTrip'),
      children: [
        for (final ride in rides)
          ListTile(
            leading: const Icon(Icons.local_taxi_outlined),
            title: Text(ride.provider),
            subtitle: Text(
              '${ride.pickupAddress} ${context.ui('to')} ${ride.destinationAddress}',
            ),
          ),
      ],
    );
  }
}

class _GenericSavedSection extends StatelessWidget {
  const _GenericSavedSection({
    required this.title,
    required this.isLoading,
    required this.empty,
    required this.children,
  });

  final String title;
  final bool isLoading;
  final String empty;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            if (isLoading) const LinearProgressIndicator(),
            if (children.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(empty),
              )
            else
              ...children,
          ],
        ),
      ),
    );
  }
}

String _label(SavedItemCategory category) {
  return category.name[0].toUpperCase() + category.name.substring(1);
}

IconData _icon(SavedItemCategory category) {
  return switch (category) {
    SavedItemCategory.flight => Icons.flight_takeoff,
    SavedItemCategory.hotel => Icons.hotel_outlined,
    SavedItemCategory.transport => Icons.local_taxi_outlined,
    SavedItemCategory.activity => Icons.explore_outlined,
    SavedItemCategory.restaurant => Icons.restaurant_outlined,
    SavedItemCategory.place => Icons.place_outlined,
  };
}

String? _firstTripId(List<Trip>? trips) {
  if (trips == null || trips.isEmpty) return null;
  return trips.first.id;
}
