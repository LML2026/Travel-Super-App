import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../flights/models/saved_flight.dart';
import '../../../flights/providers/flight_provider.dart';
import '../../../hotels/models/saved_hotel.dart';
import '../../../hotels/providers/hotel_provider.dart';
import '../../../weather/providers/weather_provider.dart';
import '../../domain/entities/trip.dart';
import '../providers/trip_provider.dart';
import '../widgets/ai_assistant_card.dart';
import '../widgets/budget_card.dart';
import '../widgets/documents_card.dart';
import '../widgets/flight_card.dart';
import '../widgets/hotel_card.dart';
import '../widgets/itinerary_card.dart';
import '../widgets/map_card.dart';
import '../widgets/translator_card.dart';
import '../widgets/weather_card.dart';
import 'edit_trip_page.dart';

class TripDashboardPage extends ConsumerWidget {
  const TripDashboardPage({
    super.key,
    required this.tripId,
  });

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(tripRepositoryProvider);

    return FutureBuilder<Trip?>(
      future: repository.getTrip(tripId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Trip Dashboard')),
            body: Center(child: Text(snapshot.error.toString())),
          );
        }

        final trip = snapshot.data;
        if (trip == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Trip Dashboard')),
            body: const Center(child: Text('Trip not found')),
          );
        }

        final weatherAsync = ref.watch(weatherProvider(trip.destination));
        final flightsAsync = ref.watch(savedFlightsProvider);
        final hotelsAsync = ref.watch(savedHotelsProvider);

        final linkedFlight = _findLinkedFlight(
          flightsAsync.valueOrNull ?? const <SavedFlight>[],
          trip.selectedFlightId,
        );
        final linkedHotel = _findLinkedHotel(
          hotelsAsync.valueOrNull ?? const <SavedHotel>[],
          trip.selectedHotelId,
        );

        final spent = (linkedFlight?.amount ?? 0) + (linkedHotel?.totalPrice ?? 0);
        final tripDays = _tripDays(trip);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Trip Dashboard'),
            actions: [
              IconButton(
                tooltip: 'Edit Trip',
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditTripPage(trip: trip),
                    ),
                  );
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
                  _TripHeader(trip: trip),
                  const SizedBox(height: 12),
                  WeatherCard(
                    isLoading: weatherAsync.isLoading,
                    errorText: weatherAsync.hasError ? 'Weather unavailable.' : null,
                    temperatureC: weatherAsync.valueOrNull?.tempC,
                    condition: weatherAsync.valueOrNull?.description,
                  ),
                  FlightCard(
                    flightNumber: linkedFlight?.flightNumber,
                    route: linkedFlight == null
                        ? null
                        : '${linkedFlight.origin} → ${linkedFlight.destination}',
                    timeRange: linkedFlight == null
                        ? null
                        : '${_formatFlightTime(linkedFlight.departureAt)} → ${_formatFlightTime(linkedFlight.arrivalAt)}',
                  ),
                  HotelCard(
                    name: linkedHotel?.name,
                    address: linkedHotel == null
                        ? null
                        : _hotelAddress(linkedHotel),
                  ),
                  BudgetCard(
                    currency: trip.currency,
                    budget: trip.budget,
                    spent: spent,
                  ),
                  ItineraryCard(days: tripDays),
                  const MapCard(),
                  const DocumentsCard(),
                  const TranslatorCard(),
                  const AiAssistantCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  SavedFlight? _findLinkedFlight(List<SavedFlight> flights, String? flightId) {
    if (flightId == null || flightId.isEmpty) {
      return null;
    }

    for (final flight in flights) {
      if (flight.flightId == flightId) {
        return flight;
      }
    }

    return null;
  }

  SavedHotel? _findLinkedHotel(List<SavedHotel> hotels, String? hotelId) {
    if (hotelId == null || hotelId.isEmpty) {
      return null;
    }

    for (final hotel in hotels) {
      if (hotel.hotelId == hotelId) {
        return hotel;
      }
    }

    return null;
  }

  int _tripDays(Trip trip) {
    final days = trip.returnDate.difference(trip.departureDate).inDays + 1;
    return days < 1 ? 1 : days;
  }

  String _formatFlightTime(String dateTime) {
    final parsed = DateTime.tryParse(dateTime);
    if (parsed == null) {
      return dateTime;
    }

    return DateFormat('HH:mm').format(parsed);
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text('${formatter.format(trip.departureDate)} → ${formatter.format(trip.returnDate)}'),
          ],
        ),
      ),
    );
  }
}
