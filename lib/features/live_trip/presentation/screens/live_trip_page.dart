import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/models/booking.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../expenses/presentation/screens/add_expense_page.dart';
import '../../../maps/models/places_prefill.dart';
import '../../../nearby/models/nearby_service_type.dart';
import '../../../flights/models/saved_flight.dart';
import '../../../flights/providers/flight_provider.dart';
import '../../../hotels/models/saved_hotel.dart';
import '../../../hotels/providers/hotel_provider.dart';
import '../../../taxi/presentation/providers/taxi_hub_provider.dart';
import '../../../weather/models/weather_data.dart';
import '../../../weather/providers/weather_provider.dart';
import '../../../translator/domain/translation_models.dart';
import '../../../trip_readiness/domain/entities/trip_readiness_item.dart';
import '../../../trip_readiness/presentation/providers/trip_readiness_provider.dart';
import '../../../trips/domain/entities/trip.dart';
import '../../../trips/domain/entities/trip_activity.dart';
import '../../../trips/domain/entities/trip_document.dart';
import '../../../trips/domain/services/trip_event_composer.dart';
import '../../../trips/presentation/providers/trip_activity_provider.dart';
import '../../../trips/presentation/providers/trip_bookings_provider.dart';
import '../../../trips/presentation/providers/trip_document_provider.dart';
import '../../../trips/presentation/providers/trip_provider.dart';
import '../../../trips/presentation/widgets/weather_card.dart';
import '../../domain/live_trip_models.dart';

class LiveTripPage extends ConsumerWidget {
  const LiveTripPage({
    super.key,
    this.trip,
  });

  final Trip? trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providedTrip = trip;
    if (providedTrip != null) {
      return _LiveTripContent(trip: providedTrip);
    }

    final tripsAsync = ref.watch(tripsProvider);
    return tripsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Live Trip')),
        body: Center(child: Text('Could not load trips: $error')),
      ),
      data: (trips) {
        final activeTrip = _activeTrip(trips, DateTime.now());
        if (activeTrip != null) {
          return _LiveTripContent(trip: activeTrip);
        }
        return _ChooseTripState(trips: trips);
      },
    );
  }

  Trip? _activeTrip(List<Trip> trips, DateTime now) {
    final active = trips.where((trip) {
      final start = DateTime(
        trip.startDate.year,
        trip.startDate.month,
        trip.startDate.day,
      );
      final end = DateTime(
        trip.endDate.year,
        trip.endDate.month,
        trip.endDate.day,
        23,
        59,
      );
      return !now.isBefore(start) && !now.isAfter(end);
    }).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    if (active.isNotEmpty) {
      return active.first;
    }

    final upcoming = trips.where((trip) => trip.endDate.isAfter(now)).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    return upcoming.isEmpty ? null : upcoming.first;
  }
}

class _LiveTripContent extends ConsumerWidget {
  const _LiveTripContent({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(tripActivitiesProvider(trip.id));
    final bookingsAsync = ref.watch(tripBookingsProvider(trip.id));
    final documentsAsync = ref.watch(tripDocumentsProvider(trip.id));
    final expensesAsync = ref.watch(tripExpensesProvider(trip.id));
    final readinessSummary = ref.watch(tripReadinessSummaryProvider(trip.id));
    final ridesAsync = ref.watch(taxiSavedRidesForTripProvider(trip.id));
    final savedFlightsAsync = ref.watch(savedFlightsProvider);
    final savedHotelsAsync = ref.watch(savedHotelsProvider);
    final weatherAsync = ref.watch(weatherProvider(trip.destination));

    final activities = activitiesAsync.valueOrNull ?? const <TripActivity>[];
    final bookings = bookingsAsync.valueOrNull ?? const <Booking>[];
    final documents = documentsAsync.valueOrNull ?? const <TripDocument>[];
    final expenses = expensesAsync.valueOrNull ?? const <Expense>[];
    final rides = ridesAsync.valueOrNull ?? const [];
    final linkedFlight = _linkedFlight(
      savedFlightsAsync.valueOrNull ?? const <SavedFlight>[],
      trip.selectedFlightId,
    );
    final linkedHotel = _linkedHotel(
      savedHotelsAsync.valueOrNull ?? const <SavedHotel>[],
      trip.selectedHotelId,
    );
    final tripEvents = const TripEventComposer().compose(
      trip: trip,
      bookings: bookings,
      activities: activities,
      rides: rides,
      reminders: readinessSummary.reminders,
      linkedFlight: linkedFlight,
      linkedHotel: linkedHotel,
      includeReadiness: true,
    );
    final liveTrip = const LiveTripComposer().compose(
      trip: trip,
      now: DateTime.now(),
      activities: activities,
      bookings: bookings,
      documents: documents,
      expenses: expenses,
      tripEvents: tripEvents,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Trip'),
        actions: [
          IconButton(
            tooltip: 'Trip Dashboard',
            onPressed: () => context.pushTripDetails(trip),
            icon: const Icon(Icons.dashboard_outlined),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(tripActivitiesProvider(trip.id));
              ref.invalidate(tripBookingsProvider(trip.id));
              ref.invalidate(tripDocumentsProvider(trip.id));
              ref.invalidate(tripExpensesProvider(trip.id));
              ref.invalidate(tripReadinessSummaryProvider(trip.id));
              ref.invalidate(taxiSavedRidesForTripProvider(trip.id));
              ref.invalidate(savedFlightsProvider);
              ref.invalidate(savedHotelsProvider);
              ref.invalidate(weatherProvider(trip.destination));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _LiveTripHero(state: liveTrip),
                const SizedBox(height: 12),
                _NextEventCard(
                  state: liveTrip,
                  onNavigate: (event) => _openMap(context, event),
                  onViewBooking: (booking) =>
                      context.pushConfirmedBookingDetails(booking),
                  onOpenDocuments: () => context.pushTripDocuments(trip.id),
                  onTranslate: () =>
                      _openTranslator(context, liveTrip.nextEvent),
                  onAskAi: () => context.pushTripAiPlanner(
                    trip.id,
                    initialTrip: trip,
                  ),
                  onAddExpense: () => _openAddExpense(context),
                  onNearby: () => context.pushNearbyEssentials(
                    initialService: _nearbyServiceFor(liveTrip.nextEvent),
                  ),
                ),
                const SizedBox(height: 12),
                _TodayTimelineCard(
                  events: liveTrip.todayEvents,
                  isLoading:
                      activitiesAsync.isLoading || bookingsAsync.isLoading,
                ),
                const SizedBox(height: 12),
                _ActionGrid(
                  nextEvent: liveTrip.nextEvent,
                  onNavigate: () {
                    final event = liveTrip.nextEvent;
                    if (event != null) {
                      _openMap(context, event);
                    } else {
                      context.pushMaps(
                        prefill: PlacesPrefill(
                          query: trip.destination,
                          locationHint: trip.destination,
                          title: '${trip.destination} map',
                        ),
                      );
                    }
                  },
                  onDocuments: () => context.pushTripDocuments(trip.id),
                  onTranslate: () =>
                      _openTranslator(context, liveTrip.nextEvent),
                  onAskAi: () => context.pushTripAiPlanner(
                    trip.id,
                    initialTrip: trip,
                  ),
                  onAddExpense: () => _openAddExpense(context),
                  onBooking: () => context.pushTripBookings(trip.id),
                  onNearby: () => context.pushNearbyEssentials(
                    initialService: _nearbyServiceFor(liveTrip.nextEvent),
                  ),
                ),
                const SizedBox(height: 12),
                WeatherCard(
                  destination: trip.destination,
                  onTap: () => context.pushWeather(),
                ),
                if (weatherAsync.valueOrNull != null)
                  _WeatherSuggestionCard(
                    weather: weatherAsync.valueOrNull!,
                    onRainyPlan: () => context.pushTripAiPlanner(
                      trip.id,
                      initialTrip: trip,
                    ),
                    onNearby: () => context.pushNearbyEssentials(
                      initialService: NearbyServiceType.museum,
                    ),
                  ),
                const SizedBox(height: 12),
                _DocumentCard(
                  documents: liveTrip.relevantDocuments,
                  isLoading: documentsAsync.isLoading,
                  onOpenAll: () => context.pushTripDocuments(trip.id),
                  onOpenDocument: (document) async {
                    try {
                      await ref
                          .read(tripDocumentMutationProvider.notifier)
                          .openDocument(document);
                    } catch (error) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Could not open document: $error')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                _MoneyCard(
                  money: liveTrip.money,
                  isLoading: expensesAsync.isLoading,
                  onAddExpense: () => _openAddExpense(context),
                ),
                const SizedBox(height: 12),
                _AiCompanionCard(
                  onPrompt: (_) => context.pushTripAiPlanner(
                    trip.id,
                    initialTrip: trip,
                  ),
                ),
                const SizedBox(height: 12),
                _ReadinessCard(
                  summary: readinessSummary,
                  fallbackReminders: liveTrip.reminders,
                  onOpenReadiness: () => context.pushTripReadiness(trip),
                ),
                const SizedBox(height: 12),
                _EssentialsCard(
                  trip: trip,
                  onMaps: () => context.pushMaps(
                    prefill: PlacesPrefill(
                      query: trip.destination,
                      locationHint: trip.destination,
                      title: '${trip.destination} essentials',
                    ),
                  ),
                  onTranslate: () =>
                      _openTranslator(context, liveTrip.nextEvent),
                  onNearby: () => context.pushNearbyEssentials(
                    initialService: _nearbyServiceFor(liveTrip.nextEvent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openMap(BuildContext context, LiveTripEvent event) {
    final query =
        event.location?.isNotEmpty == true ? event.location! : event.title;
    context.pushMaps(
      prefill: PlacesPrefill(
        query: query,
        locationHint: trip.destination,
        scheduledAt: event.startTime,
        note: event.title,
        title: 'Navigate to ${event.title}',
      ),
    );
  }

  Future<void> _openAddExpense(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AddExpensePage(
          tripId: trip.id,
          currency: trip.currency,
        ),
      ),
    );
  }

  void _openTranslator(BuildContext context, LiveTripEvent? event) {
    context.pushTranslator(
      context: TranslatorContext(
        destination: trip.destination,
        contextLabel: event == null ? 'Live Trip' : event.title,
        initialText: _translatorPromptFor(event),
      ),
    );
  }

  String? _translatorPromptFor(LiveTripEvent? event) {
    if (event == null) {
      return null;
    }
    return switch (event.type) {
      LiveTripEventType.hotel => 'I have a reservation.',
      LiveTripEventType.restaurant => 'A table for two, please.',
      LiveTripEventType.transport => 'Please take me to this address.',
      LiveTripEventType.flight => 'Where is the check-in desk?',
      LiveTripEventType.activity => 'Can you show me on the map?',
      LiveTripEventType.itinerary => null,
    };
  }

  NearbyServiceType _nearbyServiceFor(LiveTripEvent? event) {
    switch (event?.type) {
      case LiveTripEventType.restaurant:
        return NearbyServiceType.restaurant;
      case LiveTripEventType.hotel:
        return NearbyServiceType.cafe;
      case LiveTripEventType.flight:
      case LiveTripEventType.transport:
        return NearbyServiceType.transit;
      case LiveTripEventType.activity:
      case LiveTripEventType.itinerary:
      case null:
        return NearbyServiceType.attraction;
    }
  }
}

SavedFlight? _linkedFlight(List<SavedFlight> flights, String? id) {
  if (id == null || id.isEmpty) return null;
  for (final flight in flights) {
    if (flight.flightId == id) return flight;
  }
  return null;
}

SavedHotel? _linkedHotel(List<SavedHotel> hotels, String? id) {
  if (id == null || id.isEmpty) return null;
  for (final hotel in hotels) {
    if (hotel.hotelId == id) return hotel;
  }
  return null;
}

class _LiveTripHero extends StatelessWidget {
  const _LiveTripHero({required this.state});

  final LiveTripState state;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE d MMM, HH:mm');
    final dayText = state.dayNumber == 0
        ? 'Before trip'
        : 'Day ${state.dayNumber} of ${state.totalDays}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  child: Icon(Icons.explore_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.trip.destination,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                      ),
                      Text('${state.statusLabel} · $dayText'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.schedule, size: 18),
                  label: Text(dateFormat.format(state.now)),
                ),
                Chip(
                  avatar: const Icon(Icons.people_outline, size: 18),
                  label: Text('${state.trip.travellers} travellers'),
                ),
                Chip(
                  avatar: const Icon(Icons.event_available, size: 18),
                  label: Text('${state.todayEvents.length} events today'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NextEventCard extends StatelessWidget {
  const _NextEventCard({
    required this.state,
    required this.onNavigate,
    required this.onViewBooking,
    required this.onOpenDocuments,
    required this.onTranslate,
    required this.onAskAi,
    required this.onAddExpense,
    required this.onNearby,
  });

  final LiveTripState state;
  final ValueChanged<LiveTripEvent> onNavigate;
  final ValueChanged<Booking> onViewBooking;
  final VoidCallback onOpenDocuments;
  final VoidCallback onTranslate;
  final VoidCallback onAskAi;
  final VoidCallback onAddExpense;
  final VoidCallback onNearby;

  @override
  Widget build(BuildContext context) {
    final event = state.nextEvent;
    if (event == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "What's next",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                  'No upcoming saved events. Add bookings or activities to build your live timeline.'),
            ],
          ),
        ),
      );
    }

    final formatter = DateFormat('EEE HH:mm');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What's next",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(child: Icon(_iconFor(event.type))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                          '${formatter.format(event.startTime)} · ${_countdown(event.startTime, state.now)}'),
                      if (event.location?.isNotEmpty == true)
                        Text(event.location!),
                      if (event.status?.isNotEmpty == true)
                        Text('Status: ${event.status}'),
                      if (event.provider?.isNotEmpty == true)
                        Text('Provider: ${event.provider}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => onNavigate(event),
                  icon: const Icon(Icons.navigation_outlined),
                  label: const Text('Navigate'),
                ),
                if (event.booking != null)
                  OutlinedButton.icon(
                    onPressed: () => onViewBooking(event.booking!),
                    icon: const Icon(Icons.confirmation_num_outlined),
                    label: const Text('Booking'),
                  ),
                OutlinedButton.icon(
                  onPressed: onOpenDocuments,
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Ticket'),
                ),
                OutlinedButton.icon(
                  onPressed: onTranslate,
                  icon: const Icon(Icons.translate_outlined),
                  label: const Text('Translate'),
                ),
                OutlinedButton.icon(
                  onPressed: onAskAi,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Ask AI'),
                ),
                OutlinedButton.icon(
                  onPressed: onAddExpense,
                  icon: const Icon(Icons.add_card_outlined),
                  label: const Text('Expense'),
                ),
                OutlinedButton.icon(
                  onPressed: onNearby,
                  icon: const Icon(Icons.place_outlined),
                  label: const Text('Nearby'),
                ),
              ],
            ),
            if (state.upcomingEvents.length > 1) ...[
              const SizedBox(height: 16),
              Text(
                'After that',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              for (final upcoming in state.upcomingEvents.skip(1).take(3))
                _MiniEventRow(event: upcoming, now: state.now),
            ],
          ],
        ),
      ),
    );
  }
}

class _TodayTimelineCard extends StatelessWidget {
  const _TodayTimelineCard({
    required this.events,
    required this.isLoading,
  });

  final List<LiveTripEvent> events;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Today's timeline",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (events.isEmpty)
              const Text('No saved bookings or activities for today.')
            else
              for (final event in events) _TimelineRow(event: event),
          ],
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({
    required this.nextEvent,
    required this.onNavigate,
    required this.onDocuments,
    required this.onTranslate,
    required this.onAskAi,
    required this.onAddExpense,
    required this.onBooking,
    required this.onNearby,
  });

  final LiveTripEvent? nextEvent;
  final VoidCallback onNavigate;
  final VoidCallback onDocuments;
  final VoidCallback onTranslate;
  final VoidCallback onAskAi;
  final VoidCallback onAddExpense;
  final VoidCallback onBooking;
  final VoidCallback onNearby;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionButton(
                  icon: Icons.navigation_outlined,
                  label: nextEvent == null ? 'Open Map' : 'Navigate',
                  onTap: onNavigate,
                ),
                _ActionButton(
                  icon: Icons.description_outlined,
                  label: 'Documents',
                  onTap: onDocuments,
                ),
                _ActionButton(
                  icon: Icons.translate_outlined,
                  label: 'Translate',
                  onTap: onTranslate,
                ),
                _ActionButton(
                  icon: Icons.auto_awesome,
                  label: 'Ask AI',
                  onTap: onAskAi,
                ),
                _ActionButton(
                  icon: Icons.add_card_outlined,
                  label: 'Add Expense',
                  onTap: onAddExpense,
                ),
                _ActionButton(
                  icon: Icons.confirmation_num_outlined,
                  label: 'Bookings',
                  onTap: onBooking,
                ),
                _ActionButton(
                  icon: Icons.place_outlined,
                  label: 'Nearby',
                  onTap: onNearby,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.documents,
    required this.isLoading,
    required this.onOpenAll,
    required this.onOpenDocument,
  });

  final List<TripDocument> documents;
  final bool isLoading;
  final VoidCallback onOpenAll;
  final ValueChanged<TripDocument> onOpenDocument;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Travel documents',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                TextButton(onPressed: onOpenAll, child: const Text('All')),
              ],
            ),
            if (isLoading)
              const LinearProgressIndicator()
            else if (documents.isEmpty)
              const Text('No relevant documents found for the next event.')
            else
              for (final document in documents)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(document.hasUploadedFile
                      ? Icons.file_present_outlined
                      : Icons.article_outlined),
                  title: Text(document.title),
                  subtitle: Text('${document.type} · ${document.reference}'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => onOpenDocument(document),
                ),
          ],
        ),
      ),
    );
  }
}

class _MoneyCard extends StatelessWidget {
  const _MoneyCard({
    required this.money,
    required this.isLoading,
    required this.onAddExpense,
  });

  final LiveTripMoneySummary money;
  final bool isLoading;
  final VoidCallback onAddExpense;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Travel money',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MoneyMetric(
                    label: 'Budget',
                    value: _money(money.currency, money.budget),
                  ),
                ),
                Expanded(
                  child: _MoneyMetric(
                    label: 'Spent',
                    value: _money(money.currency, money.spent),
                  ),
                ),
                Expanded(
                  child: _MoneyMetric(
                    label: 'Left',
                    value: _money(money.currency, money.remaining),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onAddExpense,
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiCompanionCard extends StatelessWidget {
  const _AiCompanionCard({required this.onPrompt});

  final ValueChanged<String> onPrompt;

  @override
  Widget build(BuildContext context) {
    const prompts = [
      'What should I do now?',
      'Plan my next few hours',
      'Something changed',
      'Make today cheaper',
      'Rainy-day alternative',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI travel companion',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final prompt in prompts)
                  ActionChip(
                    avatar: const Icon(Icons.auto_awesome),
                    label: Text(prompt),
                    onPressed: () => onPrompt(prompt),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherSuggestionCard extends StatelessWidget {
  const _WeatherSuggestionCard({
    required this.weather,
    required this.onRainyPlan,
    required this.onNearby,
  });

  final WeatherData weather;
  final VoidCallback onRainyPlan;
  final VoidCallback onNearby;

  bool get _isWet => '${weather.condition} ${weather.description}'
      .toLowerCase()
      .contains(RegExp(r'rain|storm|snow'));

  @override
  Widget build(BuildContext context) {
    final wet = _isWet;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weather-aware plan',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(wet
                ? 'Rain or snow is expected. Consider a museum or ask AI for an indoor plan.'
                : 'Conditions look suitable for exploring nearby. Find something useful around your next stop.'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                if (wet)
                  ActionChip(
                    avatar: const Icon(Icons.auto_awesome),
                    label: const Text('Rainy-day plan'),
                    onPressed: onRainyPlan,
                  ),
                ActionChip(
                  avatar: const Icon(Icons.place_outlined),
                  label: const Text('Find nearby'),
                  onPressed: onNearby,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({
    required this.summary,
    required this.fallbackReminders,
    required this.onOpenReadiness,
  });

  final TripReadinessSummary summary;
  final List<String> fallbackReminders;
  final VoidCallback onOpenReadiness;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Travel readiness',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            _PersistentReadinessSummary(
              summary: summary,
              fallbackReminders: fallbackReminders,
              onOpenReadiness: onOpenReadiness,
            ),
          ],
        ),
      ),
    );
  }
}

class _PersistentReadinessSummary extends StatelessWidget {
  const _PersistentReadinessSummary({
    required this.summary,
    required this.fallbackReminders,
    required this.onOpenReadiness,
  });

  final TripReadinessSummary summary;
  final List<String> fallbackReminders;
  final VoidCallback onOpenReadiness;

  @override
  Widget build(BuildContext context) {
    final overdueCount =
        summary.overdueItems.length + summary.overdueReminders.length;
    final dueTodayCount =
        summary.dueTodayItems.length + summary.dueTodayReminders.length;
    final upcomingCount = summary.items
            .where((item) =>
                !item.isCompleted &&
                item.dueAt != null &&
                item.dueAt!.isAfter(summary.now))
            .length +
        summary.reminders
            .where((reminder) =>
                !reminder.isCompleted && reminder.dueAt.isAfter(summary.now))
            .length;

    if (summary.totalCount == 0 && summary.reminders.isEmpty) {
      return _DerivedReminderList(
        reminders: fallbackReminders,
        onOpenReadiness: onOpenReadiness,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: LinearProgressIndicator(value: summary.progress)),
            const SizedBox(width: 12),
            Text('${(summary.progress * 100).round()}%'),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text('${summary.remainingCount} pending')),
            Chip(label: Text('${summary.completedCount} complete')),
            if (overdueCount > 0)
              Chip(
                label: Text('$overdueCount overdue'),
                avatar: Icon(
                  Icons.warning_amber_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            if (dueTodayCount > 0)
              Chip(label: Text('$dueTodayCount due today')),
            if (upcomingCount > 0) Chip(label: Text('$upcomingCount upcoming')),
          ],
        ),
        if (summary.nextTask != null) ...[
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.task_alt_outlined),
            title: Text(summary.nextTask!.title),
            subtitle: Text(_readinessSubtitle(summary.nextTask!)),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenReadiness,
          ),
        ],
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: onOpenReadiness,
          icon: const Icon(Icons.checklist_outlined),
          label: const Text('Manage readiness'),
        ),
      ],
    );
  }
}

class _DerivedReminderList extends StatelessWidget {
  const _DerivedReminderList({
    required this.reminders,
    required this.onOpenReadiness,
  });

  final List<String> reminders;
  final VoidCallback onOpenReadiness;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (reminders.isEmpty)
          const Text('No readiness reminders for the next few hours.')
        else
          for (final reminder in reminders)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.task_alt_outlined),
              title: Text(reminder),
            ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onOpenReadiness,
          icon: const Icon(Icons.add_task_outlined),
          label: const Text('Create checklist'),
        ),
      ],
    );
  }
}

String _readinessSubtitle(TripReadinessItem item) {
  final due = item.dueAt;
  final dueText =
      due == null ? 'No due date' : DateFormat('EEE d MMM').format(due);
  return '${item.category.name} · $dueText';
}

class _EssentialsCard extends StatelessWidget {
  const _EssentialsCard({
    required this.trip,
    required this.onMaps,
    required this.onTranslate,
    required this.onNearby,
  });

  final Trip trip;
  final VoidCallback onMaps;
  final VoidCallback onTranslate;
  final VoidCallback onNearby;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Destination essentials',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
                'Static trip assistance for ${trip.destination}. Not live emergency dispatch.'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionButton(
                  icon: Icons.emergency_outlined,
                  label: 'Emergency Info',
                  onTap: () => _showEmergencyInfo(context),
                ),
                _ActionButton(
                  icon: Icons.payments_outlined,
                  label: trip.currency,
                  onTap: () {},
                ),
                _ActionButton(
                  icon: Icons.map_outlined,
                  label: 'Maps',
                  onTap: onMaps,
                ),
                _ActionButton(
                  icon: Icons.translate_outlined,
                  label: 'Translator',
                  onTap: onTranslate,
                ),
                _ActionButton(
                  icon: Icons.place_outlined,
                  label: 'Nearby',
                  onTap: onNearby,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use the local emergency number for the country you are in. This static reminder is not live emergency guidance.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ChooseTripState extends StatelessWidget {
  const _ChooseTripState({required this.trips});

  final List<Trip> trips;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Trip')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.explore_outlined, size: 64),
                const SizedBox(height: 16),
                Text(
                  'No active trip right now',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Open a trip to use Live Trip Mode, or create a new journey.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (trips.isNotEmpty)
                  for (final trip in trips.take(3))
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.luggage_outlined),
                        title: Text(trip.destination),
                        subtitle: Text(
                          '${DateFormat('dd MMM').format(trip.startDate)} - ${DateFormat('dd MMM').format(trip.endDate)}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.pushTripLive(trip),
                      ),
                    )
                else
                  FilledButton.icon(
                    onPressed: () => context.pushCreateTrip(),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Trip'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event});

  final LiveTripEvent event;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Icon(_iconFor(event.type), size: 18)),
      title: Text(event.title),
      subtitle: Text(
        [
          DateFormat('HH:mm').format(event.startTime),
          if (event.location?.isNotEmpty == true) event.location!,
          if (event.status?.isNotEmpty == true) event.status!,
        ].join(' · '),
      ),
    );
  }
}

class _MiniEventRow extends StatelessWidget {
  const _MiniEventRow({
    required this.event,
    required this.now,
  });

  final LiveTripEvent event;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(_iconFor(event.type), size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(event.title)),
          Text(_countdown(event.startTime, now)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon),
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _MoneyMetric extends StatelessWidget {
  const _MoneyMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}

IconData _iconFor(LiveTripEventType type) {
  switch (type) {
    case LiveTripEventType.flight:
      return Icons.flight_takeoff;
    case LiveTripEventType.hotel:
      return Icons.hotel_outlined;
    case LiveTripEventType.transport:
      return Icons.local_taxi_outlined;
    case LiveTripEventType.activity:
      return Icons.explore_outlined;
    case LiveTripEventType.restaurant:
      return Icons.restaurant_outlined;
    case LiveTripEventType.itinerary:
      return Icons.event_note_outlined;
  }
}

String _countdown(DateTime eventTime, DateTime now) {
  final duration = eventTime.difference(now);
  if (duration.isNegative) {
    final elapsed = now.difference(eventTime);
    if (elapsed.inHours >= 1) {
      return '${elapsed.inHours}h ago';
    }
    return '${elapsed.inMinutes}m ago';
  }
  if (duration.inDays >= 1) {
    return 'in ${duration.inDays}d';
  }
  if (duration.inHours >= 1) {
    return 'in ${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
  }
  return 'in ${duration.inMinutes}m';
}

String _money(String currency, double value) {
  return '$currency ${value.toStringAsFixed(0)}';
}
