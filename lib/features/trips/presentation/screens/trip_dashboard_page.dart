import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/app_routes.dart';
import '../../../expenses/presentation/screens/trip_expenses_page.dart';
import '../../../flights/models/saved_flight.dart';
import '../../../flights/providers/flight_provider.dart';
import '../../../hotels/models/saved_hotel.dart';
import '../../../hotels/providers/hotel_provider.dart';
import '../../domain/entities/trip.dart';
import '../providers/trip_provider.dart';
import '../providers/trip_document_provider.dart';
import '../widgets/activities_card.dart';
import '../widgets/ai_assistant_card.dart';
import '../widgets/budget_card.dart';
import '../widgets/documents_card.dart';
import '../widgets/flight_card.dart';
import '../widgets/hotel_card.dart';
import '../widgets/map_card.dart';
import '../widgets/translator_card.dart';
import '../widgets/weather_card.dart';
import 'edit_trip_page.dart';

class TripDashboardPage extends ConsumerStatefulWidget {
  const TripDashboardPage({super.key, required this.trip});

  final Trip trip;

  @override
  ConsumerState<TripDashboardPage> createState() => _TripDashboardPageState();
}

class _TripDashboardPageState extends ConsumerState<TripDashboardPage> {
  late Trip _trip;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
  }

  @override
  void didUpdateWidget(covariant TripDashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trip.id != widget.trip.id ||
        oldWidget.trip.updatedAt != widget.trip.updatedAt) {
      _trip = widget.trip;
    }
  }

  @override
  Widget build(BuildContext context) {
    final documentsAsync = ref.watch(tripDocumentsProvider(_trip.id));
    final hasDocuments =
        (documentsAsync.valueOrNull ?? const <dynamic>[]).isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Edit Trip',
            icon: const Icon(Icons.edit),
            onPressed: () {
              final router = GoRouter.maybeOf(context);
              if (router != null) {
                context
                    .pushEditTrip(_trip.id, initialTrip: _trip)
                    .then((_) => _reloadTrip());
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditTripPage(trip: _trip)),
              ).then((_) => _reloadTrip());
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _TripHeader(trip: _trip),
              const SizedBox(height: 12),
              WeatherCard(
                destination: _trip.destination,
                onTap: () => context.pushWeather(),
              ),
              FlightCard(
                tripId: _trip.id,
                onOpenFlights: () => context.pushFlights(),
                onViewFlightDetails: (flight) =>
                    context.pushSavedFlightDetails(flight),
                onLinkFlight: () => _selectAndLinkFlight(),
                onUnlinkFlight: () => _confirmAndUnlinkFlight(),
              ),
              HotelCard(
                tripId: _trip.id,
                checkInDate: _trip.departureDate,
                checkOutDate: _trip.returnDate,
                onOpenHotels: () => context.pushHotels(),
                onViewHotelDetails: (hotel) =>
                    context.pushSavedHotelDetails(hotel),
                onLinkHotel: () => _selectAndLinkHotel(),
                onUnlinkHotel: () => _confirmAndUnlinkHotel(),
              ),
              BudgetCard(
                tripId: _trip.id,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TripExpensesPage(trip: _trip),
                  ),
                ),
              ),
              ActivitiesCard(
                tripId: _trip.id,
                onOpenActivities: () => context.pushTripActivities(_trip.id),
              ),
              const MapCard(),
              DocumentsCard(
                hasDocuments: hasDocuments,
                onOpenDocuments: () => context.pushTripDocuments(_trip.id),
              ),
              const TranslatorCard(),
              const AiAssistantCard(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _reloadTrip() async {
    final latest = await ref.read(tripRepositoryProvider).get(_trip.id);
    if (!mounted || latest == null) {
      return;
    }

    setState(() {
      _trip = latest;
    });
  }

  Future<void> _selectAndLinkFlight() async {
    final flights =
        ref.read(savedFlightsProvider).valueOrNull ?? const <SavedFlight>[];
    if (flights.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved flights available.')),
      );
      return;
    }

    final selected = await showModalBottomSheet<SavedFlight>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView.builder(
          itemCount: flights.length,
          itemBuilder: (context, index) {
            final flight = flights[index];
            return ListTile(
              title: Text('${flight.airline} ${flight.flightNumber}'),
              subtitle: Text('${flight.origin} → ${flight.destination}'),
              onTap: () => Navigator.pop(sheetContext, flight),
            );
          },
        ),
      ),
    );

    if (selected == null) {
      return;
    }

    final updatedTrip = _trip.copyWith(
      selectedFlightId: selected.flightId,
      updatedAt: DateTime.now(),
    );

    await ref.read(createTripProvider.notifier).updateTrip(updatedTrip);
    if (!mounted) return;
    setState(() {
      _trip = updatedTrip;
    });
  }

  Future<void> _unlinkFlight() async {
    final updatedTrip = Trip(
      id: _trip.id,
      title: _trip.title,
      destination: _trip.destination,
      departureDate: _trip.departureDate,
      returnDate: _trip.returnDate,
      budget: _trip.budget,
      currency: _trip.currency,
      travellers: _trip.travellers,
      notes: _trip.notes,
      selectedFlightId: null,
      selectedHotelId: _trip.selectedHotelId,
      createdAt: _trip.createdAt,
      updatedAt: DateTime.now(),
    );

    await ref.read(createTripProvider.notifier).updateTrip(updatedTrip);
    if (!mounted) return;
    setState(() {
      _trip = updatedTrip;
    });
  }

  Future<void> _confirmAndUnlinkFlight() async {
    final shouldUnlink = await _confirmUnlinkDialog(
      title: 'Unlink flight?',
      message: 'This will remove the current flight from this trip dashboard.',
    );
    if (!shouldUnlink) {
      return;
    }

    await _unlinkFlight();
  }

  Future<void> _selectAndLinkHotel() async {
    final hotels =
        ref.read(savedHotelsProvider).valueOrNull ?? const <SavedHotel>[];
    if (hotels.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved hotels available.')),
      );
      return;
    }

    final selected = await showModalBottomSheet<SavedHotel>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView.builder(
          itemCount: hotels.length,
          itemBuilder: (context, index) {
            final hotel = hotels[index];
            return ListTile(
              title: Text(hotel.name),
              subtitle: Text(_hotelAddress(hotel)),
              onTap: () => Navigator.pop(sheetContext, hotel),
            );
          },
        ),
      ),
    );

    if (selected == null) {
      return;
    }

    final updatedTrip = _trip.copyWith(
      selectedHotelId: selected.hotelId,
      updatedAt: DateTime.now(),
    );

    await ref.read(createTripProvider.notifier).updateTrip(updatedTrip);
    if (!mounted) return;
    setState(() {
      _trip = updatedTrip;
    });
  }

  Future<void> _unlinkHotel() async {
    final updatedTrip = Trip(
      id: _trip.id,
      title: _trip.title,
      destination: _trip.destination,
      departureDate: _trip.departureDate,
      returnDate: _trip.returnDate,
      budget: _trip.budget,
      currency: _trip.currency,
      travellers: _trip.travellers,
      notes: _trip.notes,
      selectedFlightId: _trip.selectedFlightId,
      selectedHotelId: null,
      createdAt: _trip.createdAt,
      updatedAt: DateTime.now(),
    );

    await ref.read(createTripProvider.notifier).updateTrip(updatedTrip);
    if (!mounted) return;
    setState(() {
      _trip = updatedTrip;
    });
  }

  Future<void> _confirmAndUnlinkHotel() async {
    final shouldUnlink = await _confirmUnlinkDialog(
      title: 'Unlink hotel?',
      message: 'This will remove the current hotel from this trip dashboard.',
    );
    if (!shouldUnlink) {
      return;
    }

    await _unlinkHotel();
  }

  Future<bool> _confirmUnlinkDialog({
    required String title,
    required String message,
  }) async {
    final decision = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Unlink'),
          ),
        ],
      ),
    );

    return decision == true;
  }

  String _hotelAddress(SavedHotel hotel) {
    if (hotel.address.isNotEmpty) {
      return hotel.address;
    }

    if (hotel.country.isNotEmpty) {
      return '${hotel.city}, ${hotel.country}';
    }

    return hotel.city;
  }
}

class _TripHeader extends StatelessWidget {
  const _TripHeader({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM');

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trip.destination,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${formatter.format(trip.departureDate)} → ${formatter.format(trip.returnDate)}',
            ),
          ],
        ),
      ),
    );
  }
}
