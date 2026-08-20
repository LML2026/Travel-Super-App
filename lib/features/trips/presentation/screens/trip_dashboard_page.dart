import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/user_facing_error.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/models/booking.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../expenses/presentation/screens/trip_expenses_page.dart';
import '../../../flights/models/saved_flight.dart';
import '../../../flights/providers/flight_provider.dart';
import '../../../hotels/models/saved_hotel.dart';
import '../../../hotels/providers/hotel_provider.dart';
import '../../../maps/models/places_prefill.dart';
import '../../../taxi/domain/entities/taxi_saved_ride.dart';
import '../../../taxi/presentation/providers/taxi_hub_provider.dart';
import '../../../translator/domain/translation_models.dart';
import '../../../trip_readiness/domain/entities/trip_readiness_item.dart';
import '../../../trip_readiness/presentation/providers/trip_readiness_provider.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_activity.dart';
import '../../domain/entities/trip_collaborator.dart';
import '../../domain/entities/trip_document.dart';
import '../../domain/services/trip_event_composer.dart';
import '../providers/trip_activity_provider.dart';
import '../providers/trip_bookings_provider.dart';
import '../providers/trip_collaboration_provider.dart';
import '../providers/trip_document_provider.dart';
import '../providers/trip_provider.dart';
import '../widgets/activities_card.dart';
import '../widgets/ai_assistant_card.dart';
import '../widgets/bookings_card.dart';
import '../widgets/budget_card.dart';
import '../widgets/dashboard_section.dart';
import '../widgets/documents_card.dart';
import '../widgets/map_card.dart';
import '../widgets/translator_card.dart';
import '../widgets/weather_card.dart';
import 'edit_trip_page.dart';

class TripDashboardPage extends ConsumerStatefulWidget {
  const TripDashboardPage({
    super.key,
    required this.trip,
  });

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
    final activitiesAsync = ref.watch(tripActivitiesProvider(_trip.id));
    final bookingsAsync = ref.watch(tripBookingsProvider(_trip.id));
    final documentsAsync = ref.watch(tripDocumentsProvider(_trip.id));
    final expensesAsync = ref.watch(tripExpensesProvider(_trip.id));
    final ridesAsync = ref.watch(taxiSavedRidesForTripProvider(_trip.id));
    final savedFlightsAsync = ref.watch(savedFlightsProvider);
    final savedHotelsAsync = ref.watch(savedHotelsProvider);
    final readinessSummary = ref.watch(tripReadinessSummaryProvider(_trip.id));

    final activities = activitiesAsync.valueOrNull ?? const <TripActivity>[];
    final bookings = bookingsAsync.valueOrNull ?? const <Booking>[];
    final documents = documentsAsync.valueOrNull ?? const <TripDocument>[];
    final expenses = expensesAsync.valueOrNull ?? const <Expense>[];
    final rides = ridesAsync.valueOrNull ?? const <TaxiSavedRide>[];
    final savedFlights = savedFlightsAsync.valueOrNull ?? const <SavedFlight>[];
    final savedHotels = savedHotelsAsync.valueOrNull ?? const <SavedHotel>[];
    final linkedFlight =
        _findLinkedFlight(savedFlights, _trip.selectedFlightId);
    final linkedHotel = _findLinkedHotel(savedHotels, _trip.selectedHotelId);
    final hasDocuments = documents.isNotEmpty;
    final tripEvents = const TripEventComposer().compose(
      trip: _trip,
      bookings: bookings,
      activities: activities,
      rides: rides,
      reminders: readinessSummary.reminders,
      linkedFlight: linkedFlight,
      linkedHotel: linkedHotel,
      includeReadiness: true,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Live Trip',
            icon: const Icon(Icons.explore_outlined),
            onPressed: () => context.pushTripLive(_trip),
          ),
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
                MaterialPageRoute(
                  builder: (_) => EditTripPage(trip: _trip),
                ),
              ).then((_) => _reloadTrip());
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            scrollCacheExtent: const ScrollCacheExtent.pixels(12000),
            padding: const EdgeInsets.all(16),
            children: [
              _TripHero(
                trip: _trip,
                activitiesCount: activities.length,
                bookingsCount: bookings.length,
                documentsCount: documents.length,
                spent: _totalExpenses(expenses),
              ),
              const SizedBox(height: 12),
              WeatherCard(
                destination: _trip.destination,
                onTap: () => context.pushWeather(),
              ),
              if (_hasCloudError([
                activitiesAsync,
                bookingsAsync,
                documentsAsync,
                expensesAsync,
                ridesAsync,
              ]))
                _CloudDataErrorBanner(
                  onRetry: () {
                    ref.invalidate(tripActivitiesProvider(_trip.id));
                    ref.invalidate(tripBookingsProvider(_trip.id));
                    ref.invalidate(tripDocumentsProvider(_trip.id));
                    ref.invalidate(tripExpensesProvider(_trip.id));
                    ref.invalidate(taxiSavedRidesForTripProvider(_trip.id));
                  },
                ),
              _TravelPlanSection(
                linkedFlight: linkedFlight,
                linkedHotel: linkedHotel,
                checkInDate: _trip.departureDate,
                checkOutDate: _trip.returnDate,
                onOpenFlights: () => context.pushFlights(),
                onViewFlightDetails: (flight) =>
                    context.pushSavedFlightDetails(flight),
                onLinkFlight: () => _selectAndLinkFlight(),
                onUnlinkFlight: () => _confirmAndUnlinkFlight(),
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
              _ReadinessSummarySection(
                summary: readinessSummary,
                onOpenReadiness: () => context.pushTripReadiness(_trip),
              ),
              _QuickActions(
                onOpenLiveTrip: () => context.pushTripLive(_trip),
                onOpenReadiness: () => context.pushTripReadiness(_trip),
                onOpenSavedItems: () => context.pushSavedItems(),
                onAddActivity: () => context.pushTripActivities(_trip.id),
                onOpenBookings: () => context.pushTripBookings(_trip.id),
                onOpenExpenses: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TripExpensesPage(trip: _trip),
                  ),
                ),
                onOpenDocuments: () => context.pushTripDocuments(_trip.id),
                onOpenMap: () => context.pushMaps(
                  prefill: PlacesPrefill(
                    query: _trip.destination,
                    locationHint: _trip.destination,
                    title: '${_trip.destination} trip map',
                  ),
                ),
                onInvite: () => _showCollaboratorSheet(),
              ),
              _OverviewSection(
                trip: _trip,
                linkedFlight: linkedFlight,
                linkedHotel: linkedHotel,
                rides: rides,
                expenses: expenses,
              ),
              _ItinerarySection(
                trip: _trip,
                events: tripEvents,
                onAddActivity: () => context.pushTripActivities(_trip.id),
                onOpenTransport: () => context.pushTransport(),
                onOpenBooking: (booking) =>
                    context.pushConfirmedBookingDetails(booking),
              ),
              ActivitiesCard(
                tripId: _trip.id,
                onOpenActivities: () => context.pushTripActivities(_trip.id),
              ),
              BookingsCard(tripId: _trip.id),
              _BookingsSection(
                bookings: bookings,
                isLoading: bookingsAsync.isLoading,
                onOpenBookings: () => context.pushTripBookings(_trip.id),
                onOpenBooking: (booking) =>
                    context.pushConfirmedBookingDetails(booking),
              ),
              _ExpensesSection(
                trip: _trip,
                expenses: expenses,
                isLoading: expensesAsync.isLoading,
                onOpenExpenses: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TripExpensesPage(trip: _trip),
                  ),
                ),
              ),
              _DocumentsSection(
                documents: documents,
                isLoading: documentsAsync.isLoading,
                onOpenDocuments: () => context.pushTripDocuments(_trip.id),
              ),
              _TravellersSection(
                trip: _trip,
                onInvite: () => _showCollaboratorSheet(),
              ),
              MapCard(trip: _trip),
              _MapRouteSection(
                trip: _trip,
                linkedHotel: linkedHotel,
                rides: rides,
                activities: activities,
                onOpenMap: (query) => context.pushMaps(
                  prefill: PlacesPrefill(
                    query: query,
                    locationHint: _trip.destination,
                    title: 'Trip route',
                  ),
                ),
              ),
              DocumentsCard(
                hasDocuments: hasDocuments,
                onOpenDocuments: () => context.pushTripDocuments(_trip.id),
              ),
              TranslatorCard(
                onOpenTranslator: () => context.pushTranslator(
                  context: TranslatorContext(
                    destination: _trip.destination,
                    contextLabel: _trip.title,
                  ),
                ),
              ),
              AiAssistantCard(
                onOpenPlanner: () =>
                    context.pushTripAiPlanner(_trip.id, initialTrip: _trip),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SavedFlight? _findLinkedFlight(
    List<SavedFlight> flights,
    String? selectedFlightId,
  ) {
    if (selectedFlightId == null || selectedFlightId.isEmpty) {
      return null;
    }

    for (final flight in flights) {
      if (flight.flightId == selectedFlightId) {
        return flight;
      }
    }

    return null;
  }

  SavedHotel? _findLinkedHotel(
    List<SavedHotel> hotels,
    String? selectedHotelId,
  ) {
    if (selectedHotelId == null || selectedHotelId.isEmpty) {
      return null;
    }

    for (final hotel in hotels) {
      if (hotel.hotelId == selectedHotelId) {
        return hotel;
      }
    }

    return null;
  }

  double _totalExpenses(List<Expense> expenses) {
    return expenses.fold<double>(0, (total, expense) => total + expense.amount);
  }

  Future<void> _showCollaboratorSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _CollaboratorSheet(
        tripId: _trip.id,
        travellers: _trip.travellers,
        onInvite: (context, email, userId, role) => _inviteCollaborator(
          context,
          email: email,
          userId: userId,
          role: role,
        ),
        onUpdateRole: (context, collaboratorId, role) =>
            _updateCollaboratorRole(
          context,
          collaboratorId: collaboratorId,
          role: role,
        ),
        onRemove: (context, collaboratorId) => _removeCollaborator(
          context,
          collaboratorId: collaboratorId,
        ),
      ),
    );
  }

  Future<void> _inviteCollaborator(
    BuildContext context, {
    required String email,
    required String userId,
    required TripCollaboratorRole role,
  }) async {
    try {
      await ref.read(tripCollaborationActionsProvider).inviteCollaborator(
            tripId: _trip.id,
            email: email,
            role: role,
            userId: userId,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Collaborator invited.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(UserFacingError.message(
              error,
              fallback: 'We could not invite this collaborator.',
            )),
          ),
        );
      }
    }
  }

  Future<void> _updateCollaboratorRole(
    BuildContext context, {
    required String collaboratorId,
    required TripCollaboratorRole role,
  }) async {
    try {
      await ref.read(tripCollaborationActionsProvider).updateRole(
            tripId: _trip.id,
            collaboratorId: collaboratorId,
            role: role,
          );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(UserFacingError.message(
              error,
              fallback: 'We could not update this collaborator.',
            )),
          ),
        );
      }
    }
  }

  Future<void> _removeCollaborator(
    BuildContext context, {
    required String collaboratorId,
  }) async {
    try {
      await ref.read(tripCollaborationActionsProvider).removeCollaborator(
            tripId: _trip.id,
            collaboratorId: collaboratorId,
          );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(UserFacingError.message(
              error,
              fallback: 'We could not remove this collaborator.',
            )),
          ),
        );
      }
    }
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

class _TripHero extends StatelessWidget {
  const _TripHero({
    required this.trip,
    required this.activitiesCount,
    required this.bookingsCount,
    required this.documentsCount,
    required this.spent,
  });

  final Trip trip;
  final int activitiesCount;
  final int bookingsCount;
  final int documentsCount;
  final double spent;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yyyy');
    final status = _tripStatus(trip);
    final countdown = _countdownText(trip);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.title.isEmpty ? trip.destination : trip.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trip.destination,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                _StatusPill(label: status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${dateFormatter.format(trip.startDate)} -> ${dateFormatter.format(trip.endDate)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(countdown),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(
                  icon: Icons.group_outlined,
                  label: '${trip.travellers} travellers',
                ),
                _MetricChip(
                  icon: Icons.event_note_outlined,
                  label: '$activitiesCount plans',
                ),
                _MetricChip(
                  icon: Icons.confirmation_num_outlined,
                  label: '$bookingsCount bookings',
                ),
                _MetricChip(
                  icon: Icons.folder_copy_outlined,
                  label: '$documentsCount docs',
                ),
                _MetricChip(
                  icon: Icons.payments_outlined,
                  label: '${trip.currency} ${spent.toStringAsFixed(0)} spent',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadinessSummarySection extends StatelessWidget {
  const _ReadinessSummarySection({
    required this.summary,
    required this.onOpenReadiness,
  });

  final TripReadinessSummary summary;
  final VoidCallback onOpenReadiness;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      icon: Icons.fact_check_outlined,
      title: 'Trip Readiness',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(value: summary.progress),
              ),
              const SizedBox(width: 12),
              Text('${(summary.progress * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${summary.completedCount} complete · ${summary.remainingCount} remaining',
          ),
          if (summary.overdueItems.isNotEmpty ||
              summary.overdueReminders.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '${summary.overdueItems.length + summary.overdueReminders.length} overdue',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (summary.nextTask != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Next: ${summary.nextTask!.title}'),
            ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: onOpenReadiness,
            icon: const Icon(Icons.checklist_outlined),
            label: const Text('Open readiness'),
          ),
        ],
      ),
    );
  }
}

class _CloudDataErrorBanner extends StatelessWidget {
  const _CloudDataErrorBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              Icons.cloud_off_outlined,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Some trip data could not sync. Existing local/demo sections are unchanged.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onOpenLiveTrip,
    required this.onOpenReadiness,
    required this.onOpenSavedItems,
    required this.onAddActivity,
    required this.onOpenBookings,
    required this.onOpenExpenses,
    required this.onOpenDocuments,
    required this.onOpenMap,
    required this.onInvite,
  });

  final VoidCallback onOpenLiveTrip;
  final VoidCallback onOpenReadiness;
  final VoidCallback onOpenSavedItems;
  final VoidCallback onAddActivity;
  final VoidCallback onOpenBookings;
  final VoidCallback onOpenExpenses;
  final VoidCallback onOpenDocuments;
  final VoidCallback onOpenMap;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      icon: Icons.bolt_outlined,
      title: 'Quick Actions',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _ActionButton(
            icon: Icons.explore_outlined,
            label: 'Live Trip',
            onPressed: onOpenLiveTrip,
          ),
          _ActionButton(
            icon: Icons.fact_check_outlined,
            label: 'Readiness',
            onPressed: onOpenReadiness,
          ),
          _ActionButton(
            icon: Icons.bookmark_border,
            label: 'Saved',
            onPressed: onOpenSavedItems,
          ),
          _ActionButton(
            icon: Icons.add_location_alt_outlined,
            label: 'Add plan',
            onPressed: onAddActivity,
          ),
          _ActionButton(
            icon: Icons.confirmation_num_outlined,
            label: 'Bookings',
            onPressed: onOpenBookings,
          ),
          _ActionButton(
            icon: Icons.receipt_long_outlined,
            label: 'Expenses',
            onPressed: onOpenExpenses,
          ),
          _ActionButton(
            icon: Icons.folder_copy_outlined,
            label: 'Documents',
            onPressed: onOpenDocuments,
          ),
          _ActionButton(
            icon: Icons.map_outlined,
            label: 'Map',
            onPressed: onOpenMap,
          ),
          _ActionButton(
            icon: Icons.person_add_alt,
            label: 'Invite',
            onPressed: onInvite,
          ),
        ],
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({
    required this.trip,
    required this.linkedFlight,
    required this.linkedHotel,
    required this.rides,
    required this.expenses,
  });

  final Trip trip;
  final SavedFlight? linkedFlight;
  final SavedHotel? linkedHotel;
  final List<TaxiSavedRide> rides;
  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    final spent =
        expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    final remaining = trip.budget - spent;

    return DashboardSection(
      icon: Icons.dashboard_customize_outlined,
      title: 'Trip Overview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Destination',
            value: trip.destination,
          ),
          _InfoRow(
            icon: Icons.groups_outlined,
            label: 'Travellers',
            value:
                '${trip.travellers} traveller${trip.travellers == 1 ? '' : 's'}',
          ),
          _InfoRow(
            icon: Icons.flight_takeoff,
            label: 'Flight',
            value: linkedFlight == null
                ? 'Not linked'
                : '${linkedFlight!.airline} ${linkedFlight!.flightNumber}',
          ),
          _InfoRow(
            icon: Icons.hotel_outlined,
            label: 'Stay',
            value: linkedHotel?.name ?? 'Not linked',
          ),
          _InfoRow(
            icon: Icons.local_taxi_outlined,
            label: 'Transport',
            value: rides.isEmpty
                ? 'No rides saved'
                : '${rides.length} saved ride${rides.length == 1 ? '' : 's'}',
          ),
          _InfoRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Budget',
            value:
                '${trip.currency} ${spent.toStringAsFixed(2)} spent, ${remaining.toStringAsFixed(2)} remaining',
          ),
          if ((trip.notes ?? '').trim().isNotEmpty)
            _InfoRow(
              icon: Icons.notes_outlined,
              label: 'Notes',
              value: trip.notes!.trim(),
            ),
        ],
      ),
    );
  }
}

class _TravelPlanSection extends StatelessWidget {
  const _TravelPlanSection({
    required this.linkedFlight,
    required this.linkedHotel,
    required this.checkInDate,
    required this.checkOutDate,
    required this.onOpenFlights,
    required this.onViewFlightDetails,
    required this.onLinkFlight,
    required this.onUnlinkFlight,
    required this.onOpenHotels,
    required this.onViewHotelDetails,
    required this.onLinkHotel,
    required this.onUnlinkHotel,
  });

  final SavedFlight? linkedFlight;
  final SavedHotel? linkedHotel;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final VoidCallback onOpenFlights;
  final ValueChanged<SavedFlight> onViewFlightDetails;
  final VoidCallback onLinkFlight;
  final VoidCallback onUnlinkFlight;
  final VoidCallback onOpenHotels;
  final ValueChanged<SavedHotel> onViewHotelDetails;
  final VoidCallback onLinkHotel;
  final VoidCallback onUnlinkHotel;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy');

    return DashboardSection(
      icon: Icons.luggage_outlined,
      title: 'Travel Plan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Flights',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          if (linkedFlight == null)
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No flight added yet.'),
                SizedBox(height: 2),
                Text('Tap to attach a flight.'),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${linkedFlight!.airline} ${linkedFlight!.flightNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('${linkedFlight!.origin} -> ${linkedFlight!.destination}'),
                Text(
                  '${_formatTime(linkedFlight!.departureAt)} -> ${_formatTime(linkedFlight!.arrivalAt)}',
                ),
              ],
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: onOpenFlights,
                child: const Text('Open Flights'),
              ),
              if (linkedFlight == null)
                FilledButton(
                  onPressed: onLinkFlight,
                  child: const Text('Link Flight'),
                )
              else ...[
                OutlinedButton(
                  onPressed: () => onViewFlightDetails(linkedFlight!),
                  child: const Text('View Details'),
                ),
                OutlinedButton(
                  onPressed: onUnlinkFlight,
                  child: const Text('Unlink'),
                ),
              ],
            ],
          ),
          const Divider(height: 24),
          Text(
            'Hotel',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          if (linkedHotel == null)
            const Text('No hotel linked yet. Tap to add one.')
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  linkedHotel!.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Rating: ${linkedHotel!.rating.toStringAsFixed(1)} ★'),
                Text(_hotelAddress(linkedHotel!)),
                Text(
                  'Check-in ${formatter.format(checkInDate)} • Check-out ${formatter.format(checkOutDate)}',
                ),
              ],
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: onOpenHotels,
                child: const Text('Open Hotels'),
              ),
              if (linkedHotel == null)
                FilledButton(
                  onPressed: onLinkHotel,
                  child: const Text('Link Hotel'),
                )
              else ...[
                OutlinedButton(
                  onPressed: () => onViewHotelDetails(linkedHotel!),
                  child: const Text('View Details'),
                ),
                OutlinedButton(
                  onPressed: onUnlinkHotel,
                  child: const Text('Unlink'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ItinerarySection extends StatelessWidget {
  const _ItinerarySection({
    required this.trip,
    required this.events,
    required this.onAddActivity,
    required this.onOpenTransport,
    required this.onOpenBooking,
  });

  final Trip trip;
  final List<TripEvent> events;
  final VoidCallback onAddActivity;
  final VoidCallback onOpenTransport;
  final ValueChanged<Booking> onOpenBooking;

  @override
  Widget build(BuildContext context) {
    final items = _timelineItems();

    return DashboardSection(
      icon: Icons.timeline_outlined,
      title: 'Itinerary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isEmpty)
            const Text(
                'No itinerary items yet. Add activities, bookings, transport, flights or hotels to build the trip timeline.')
          else
            ...items.map((item) => _TimelineRow(item: item)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onAddActivity,
                icon: const Icon(Icons.add),
                label: const Text('Add itinerary item'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenTransport,
                icon: const Icon(Icons.local_taxi_outlined),
                label: const Text('Add transport'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<_TimelineItem> _timelineItems() {
    return events
        .map(
          (event) => _TimelineItem(
            date: event.startTime,
            icon: _eventIcon(event.type),
            title: _timelineTitle(event),
            subtitle: _timelineSubtitle(event),
            location: event.location ?? trip.destination,
            status: event.status ?? 'Planned',
            onTap: event.booking == null
                ? null
                : () => onOpenBooking(event.booking!),
          ),
        )
        .toList(growable: false);
  }

  String _timelineTitle(TripEvent event) {
    final activity = event.activity;
    if (activity != null && activity.scheduledAt == null) {
      return 'Activity plan';
    }
    return event.title;
  }

  String _timelineSubtitle(TripEvent event) {
    final activity = event.activity;
    if (activity != null && activity.scheduledAt == null) {
      return activity.notes ?? 'Open activities to edit details';
    }
    return event.subtitle ?? event.provider ?? event.source;
  }
}

class _BookingsSection extends StatelessWidget {
  const _BookingsSection({
    required this.bookings,
    required this.isLoading,
    required this.onOpenBookings,
    required this.onOpenBooking,
  });

  final List<Booking> bookings;
  final bool isLoading;
  final VoidCallback onOpenBookings;
  final ValueChanged<Booking> onOpenBooking;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      icon: Icons.confirmation_num_outlined,
      title: 'Confirmed Bookings',
      child: isLoading
          ? const LinearProgressIndicator()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bookings.isEmpty)
                  const Text(
                      'Confirmed flight, hotel and transport bookings will appear here.')
                else
                  ...bookings.take(4).map(
                        (booking) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(_bookingIcon(booking.type)),
                          title: Text(_bookingTitle(booking)),
                          subtitle: Text(_bookingSubtitle(booking)),
                          trailing: _StatusPill(label: booking.status.name),
                          onTap: () => onOpenBooking(booking),
                        ),
                      ),
                TextButton(
                  onPressed: onOpenBookings,
                  child: Text(
                      bookings.isEmpty ? 'Open bookings' : 'View all bookings'),
                ),
              ],
            ),
    );
  }
}

class _ExpensesSection extends StatelessWidget {
  const _ExpensesSection({
    required this.trip,
    required this.expenses,
    required this.isLoading,
    required this.onOpenExpenses,
  });

  final Trip trip;
  final List<Expense> expenses;
  final bool isLoading;
  final VoidCallback onOpenExpenses;

  @override
  Widget build(BuildContext context) {
    final spent =
        expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    final remaining = trip.budget - spent;
    final grouped = <String, double>{};
    for (final expense in expenses) {
      grouped.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return DashboardSection(
      icon: Icons.receipt_long_outlined,
      title: 'Trip Expenses',
      child: isLoading
          ? const LinearProgressIndicator()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Trip Budget: ${trip.currency} ${trip.budget.toStringAsFixed(2)}'),
                Text('Spent: ${trip.currency} ${spent.toStringAsFixed(2)}'),
                Text(
                    'Remaining: ${trip.currency} ${remaining.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                if (grouped.isEmpty)
                  const Text(
                      'No expenses yet. Track flights, hotels, food, transport and activities here.')
                else
                  ...grouped.entries.map(
                    (entry) => _InfoRow(
                      icon: Icons.label_outline,
                      label: entry.key,
                      value:
                          '${trip.currency} ${entry.value.toStringAsFixed(2)}',
                    ),
                  ),
                TextButton(
                  onPressed: onOpenExpenses,
                  child: const Text('Manage expenses'),
                ),
              ],
            ),
    );
  }
}

class _DocumentsSection extends StatelessWidget {
  const _DocumentsSection({
    required this.documents,
    required this.isLoading,
    required this.onOpenDocuments,
  });

  final List<TripDocument> documents;
  final bool isLoading;
  final VoidCallback onOpenDocuments;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      icon: Icons.folder_copy_outlined,
      title: 'Documents',
      child: isLoading
          ? const LinearProgressIndicator()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (documents.isEmpty)
                  const Text(
                      'Add tickets, confirmations, passports, visa references and travel documents.')
                else
                  ...documents.take(4).map(
                        (document) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.description_outlined),
                          title: Text(document.title),
                          subtitle:
                              Text('${document.type} • ${document.reference}'),
                        ),
                      ),
                TextButton(
                  onPressed: onOpenDocuments,
                  child: Text(
                      documents.isEmpty ? 'Add document' : 'Manage documents'),
                ),
              ],
            ),
    );
  }
}

class _CollaboratorSheet extends ConsumerStatefulWidget {
  const _CollaboratorSheet({
    required this.tripId,
    required this.travellers,
    required this.onInvite,
    required this.onUpdateRole,
    required this.onRemove,
  });

  final String tripId;
  final int travellers;
  final Future<void> Function(
    BuildContext context,
    String email,
    String userId,
    TripCollaboratorRole role,
  ) onInvite;
  final Future<void> Function(
    BuildContext context,
    String collaboratorId,
    TripCollaboratorRole role,
  ) onUpdateRole;
  final Future<void> Function(BuildContext context, String collaboratorId)
      onRemove;

  @override
  ConsumerState<_CollaboratorSheet> createState() => _CollaboratorSheetState();
}

class _CollaboratorSheetState extends ConsumerState<_CollaboratorSheet> {
  final _emailController = TextEditingController();
  final _userIdController = TextEditingController();
  TripCollaboratorRole _role = TripCollaboratorRole.editor;

  @override
  void dispose() {
    _emailController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collaboratorsAsync =
        ref.watch(tripCollaboratorsProvider(widget.tripId));

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trip collaborators',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Invite editors or viewers. Shared trip changes use the same user/trip-scoped Firestore collections.',
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: const Text('Trip owner'),
                subtitle: Text(
                  '${widget.travellers} traveller${widget.travellers == 1 ? '' : 's'} planned',
                ),
                trailing: const Chip(label: Text('owner')),
              ),
              collaboratorsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, _) =>
                    Text('Could not load collaborators: $error'),
                data: (collaborators) {
                  if (collaborators.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('No collaborators invited yet.'),
                    );
                  }
                  return Column(
                    children: [
                      for (final collaborator in collaborators)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            child: Icon(Icons.group_outlined),
                          ),
                          title: Text(collaborator.email),
                          subtitle: Text(collaborator.status.name),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'remove') {
                                await widget.onRemove(context, collaborator.id);
                                return;
                              }
                              await widget.onUpdateRole(
                                context,
                                collaborator.id,
                                TripCollaboratorRole.values.firstWhere(
                                  (role) => role.name == value,
                                ),
                              );
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'editor',
                                child: Text('Make editor'),
                              ),
                              PopupMenuItem(
                                value: 'viewer',
                                child: Text('Make viewer'),
                              ),
                              PopupMenuItem(
                                value: 'remove',
                                child: Text('Remove'),
                              ),
                            ],
                            child: Chip(label: Text(collaborator.role.name)),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const Divider(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Collaborator email',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: 'Collaborator user ID (optional)',
                  hintText: 'Used to mirror shared trip access',
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<TripCollaboratorRole>(
                segments: const [
                  ButtonSegment(
                    value: TripCollaboratorRole.editor,
                    icon: Icon(Icons.edit_outlined),
                    label: Text('Editor'),
                  ),
                  ButtonSegment(
                    value: TripCollaboratorRole.viewer,
                    icon: Icon(Icons.visibility_outlined),
                    label: Text('Viewer'),
                  ),
                ],
                selected: {_role},
                onSelectionChanged: (selection) {
                  setState(() => _role = selection.single);
                },
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async {
                  await widget.onInvite(
                    context,
                    _emailController.text,
                    _userIdController.text,
                    _role,
                  );
                  _emailController.clear();
                  _userIdController.clear();
                },
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Invite collaborator'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TravellersSection extends StatelessWidget {
  const _TravellersSection({
    required this.trip,
    required this.onInvite,
  });

  final Trip trip;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      icon: Icons.groups_outlined,
      title: 'Travellers & Collaborators',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var index = 0; index < trip.travellers; index++)
                Chip(
                  avatar: const Icon(Icons.person_outline, size: 18),
                  label: Text(
                      index == 0 ? 'Trip owner' : 'Traveller ${index + 1}'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
              'Invite editors or viewers and keep shared trip planning data synced through the trip workspace.'),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onInvite,
            icon: const Icon(Icons.person_add_alt),
            label: const Text('Invite collaborator'),
          ),
        ],
      ),
    );
  }
}

class _MapRouteSection extends StatelessWidget {
  const _MapRouteSection({
    required this.trip,
    required this.linkedHotel,
    required this.rides,
    required this.activities,
    required this.onOpenMap,
  });

  final Trip trip;
  final SavedHotel? linkedHotel;
  final List<TaxiSavedRide> rides;
  final List<TripActivity> activities;
  final ValueChanged<String> onOpenMap;

  @override
  Widget build(BuildContext context) {
    final locations = <String>[
      trip.destination,
      if (linkedHotel != null) _hotelAddress(linkedHotel!),
      ...rides.expand((ride) => [ride.pickupAddress, ride.destinationAddress]),
      ...activities
          .map((activity) => activity.location)
          .whereType<String>()
          .where((location) => location.trim().isNotEmpty),
    ];
    final uniqueLocations = locations.toSet().toList(growable: false);

    return DashboardSection(
      icon: Icons.alt_route_outlined,
      title: 'Maps & Route',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
              'Open the maps hub with this trip context and route-ready places.'),
          const SizedBox(height: 8),
          if (uniqueLocations.isEmpty)
            const Text('Add itinerary locations to build a route.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: uniqueLocations
                  .take(8)
                  .map(
                    (location) => ActionChip(
                      avatar: const Icon(Icons.place_outlined, size: 18),
                      label: Text(location),
                      onPressed: () => onOpenMap(location),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.item});

  final _TimelineItem item;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('EEE d MMM, HH:mm').format(item.date);
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          child: Icon(item.icon, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(time, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 2),
              Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(item.subtitle),
              Text('${item.location} • ${item.status}'),
            ],
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: item.onTap == null
          ? content
          : InkWell(onTap: item.onTap, child: content),
    );
  }
}

class _TimelineItem {
  const _TimelineItem({
    required this.date,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.status,
    this.onTap,
  });

  final DateTime date;
  final IconData icon;
  final String title;
  final String subtitle;
  final String location;
  final String status;
  final VoidCallback? onTap;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

String _tripStatus(Trip trip) {
  final today = DateTime.now();
  if (trip.status?.trim().isNotEmpty == true) {
    return trip.status!.trim();
  }
  if (today.isBefore(_startOfDay(trip.startDate))) {
    return 'Upcoming';
  }
  if (today.isAfter(_endOfDay(trip.endDate))) {
    return 'Completed';
  }
  return 'In progress';
}

String _countdownText(Trip trip) {
  final today = _startOfDay(DateTime.now());
  final start = _startOfDay(trip.startDate);
  final end = _startOfDay(trip.endDate);

  if (today.isBefore(start)) {
    final days = start.difference(today).inDays;
    return days == 0 ? 'Starts today' : '$days days until departure';
  }

  if (today.isAfter(end)) {
    final days = today.difference(end).inDays;
    return days == 0 ? 'Trip ends today' : 'Ended $days days ago';
  }

  final remaining = end.difference(today).inDays;
  return remaining == 0 ? 'Final day of trip' : '$remaining days remaining';
}

DateTime _startOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

DateTime _endOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day, 23, 59, 59);

bool _hasCloudError(List<AsyncValue<dynamic>> values) {
  return values.any((value) => value.hasError);
}

String _formatTime(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return value;
  }
  return DateFormat('HH:mm').format(parsed);
}

IconData _bookingIcon(BookingType type) {
  switch (type) {
    case BookingType.flight:
      return Icons.flight_takeoff;
    case BookingType.hotel:
      return Icons.hotel_outlined;
    case BookingType.transport:
      return Icons.local_taxi_outlined;
  }
}

IconData _eventIcon(TripEventType type) {
  switch (type) {
    case TripEventType.flight:
      return Icons.flight_takeoff;
    case TripEventType.hotel:
      return Icons.hotel_outlined;
    case TripEventType.transport:
      return Icons.local_taxi_outlined;
    case TripEventType.restaurant:
      return Icons.restaurant_outlined;
    case TripEventType.activity:
      return Icons.explore_outlined;
    case TripEventType.readiness:
      return Icons.fact_check_outlined;
    case TripEventType.itinerary:
      return Icons.event_note_outlined;
  }
}

String _bookingTitle(Booking booking) {
  switch (booking.type) {
    case BookingType.flight:
      final airline = booking.metadata['airline']?.toString();
      final number = booking.metadata['flightNumber']?.toString();
      return [airline, number]
          .where((value) => value != null && value.isNotEmpty)
          .join(' ')
          .ifEmpty('Flight booking');
    case BookingType.hotel:
      return booking.metadata['hotelName']
              ?.toString()
              .ifEmpty('Hotel booking') ??
          'Hotel booking';
    case BookingType.transport:
      return (booking.metadata['providerName'] ??
              booking.metadata['provider'] ??
              'Transport booking')
          .toString();
  }
}

String _bookingSubtitle(Booking booking) {
  switch (booking.type) {
    case BookingType.flight:
      final departure =
          booking.metadata['departure']?.toString() ?? 'Departure';
      final arrival = booking.metadata['arrival']?.toString() ?? 'Arrival';
      return '$departure -> $arrival';
    case BookingType.hotel:
      return (booking.metadata['roomType'] ??
              booking.metadata['city'] ??
              'Accommodation')
          .toString();
    case BookingType.transport:
      final pickup = booking.metadata['pickup']?.toString() ?? 'Pickup';
      final destination =
          booking.metadata['destination']?.toString() ?? 'Destination';
      return '$pickup -> $destination';
  }
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

extension _EmptyStringFallback on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
