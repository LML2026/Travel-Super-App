import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/app_routes.dart';
import '../../../flights/models/saved_flight.dart';
import '../../../flights/providers/flight_provider.dart';
import '../../../hotels/models/saved_hotel.dart';
import '../../../hotels/providers/hotel_provider.dart';
import '../../../taxi/domain/entities/taxi_ride_request.dart';
import '../../../taxi/domain/entities/taxi_saved_ride.dart';
import '../../../taxi/presentation/providers/taxi_hub_provider.dart';
import '../../../weather/models/weather_data.dart';
import '../../../weather/providers/weather_provider.dart';
import '../../domain/entities/trip.dart';
import '../providers/trip_provider.dart';
import 'edit_trip_page.dart';

class TripDetailsPage extends ConsumerWidget {
  const TripDetailsPage({
    super.key,
    required this.tripId,
  });

  final String tripId;

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Trip trip,
  ) async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text('Delete "${trip.destination}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (delete != true) return;

    await ref.read(createTripProvider.notifier).deleteTrip(trip.id);

    if (context.mounted) {
      final router = GoRouter.maybeOf(context);
      if (router != null) {
        context.pop();
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(tripRepositoryProvider);

    return FutureBuilder<Trip?>(
      future: repository.get(tripId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Trip Dashboard')),
            body: Center(
              child: Text(snapshot.error.toString()),
            ),
          );
        }

        final trip = snapshot.data;

        if (trip == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Trip Dashboard')),
            body: const Center(
              child: Text('Trip not found'),
            ),
          );
        }

        final weatherAsync = ref.watch(weatherProvider(trip.destination));
        final flightsAsync = ref.watch(savedFlightsProvider);
        final hotelsAsync = ref.watch(savedHotelsProvider);
        final ridesAsync = ref.watch(taxiSavedRidesForTripProvider(trip.id));

        final linkedFlight = _findLinkedFlight(
          flightsAsync.valueOrNull ?? const <SavedFlight>[],
          trip.selectedFlightId,
        );
        final linkedHotel = _findLinkedHotel(
          hotelsAsync.valueOrNull ?? const <SavedHotel>[],
          trip.selectedHotelId,
        );

        final spent =
            (linkedFlight?.amount ?? 0) + (linkedHotel?.totalPrice ?? 0);
        final remaining = trip.budget - spent;
        final dateFormatter = DateFormat('dd MMM yyyy');

        return Scaffold(
          appBar: AppBar(
            title: const Text('Trip Dashboard'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                trip.destination,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '${dateFormatter.format(trip.departureDate)} -> ${dateFormatter.format(trip.returnDate)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const _SectionDivider(),
              _DashboardSection(
                icon: Icons.wb_sunny_outlined,
                title: 'Weather',
                child: weatherAsync.when(
                  loading: () => const Text('Loading weather...'),
                  error: (_, __) => const Text('Weather unavailable.'),
                  data: (weather) => _WeatherLine(weather: weather),
                ),
              ),
              const _SectionDivider(),
              _DashboardSection(
                icon: Icons.flight_takeoff,
                title: 'Flights',
                child: linkedFlight == null
                    ? const Text('No linked flight yet.')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            linkedFlight.flightNumber,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                              '${linkedFlight.origin} -> ${linkedFlight.destination}'),
                          Text(
                              'Departure: ${_formatIsoDateTime(linkedFlight.departureAt)}'),
                        ],
                      ),
              ),
              const _SectionDivider(),
              _DashboardSection(
                icon: Icons.hotel,
                title: 'Hotel',
                child: linkedHotel == null
                    ? const Text('No linked hotel yet.')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            linkedHotel.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            linkedHotel.address.isEmpty
                                ? '${linkedHotel.city}${linkedHotel.country.isEmpty ? '' : ', ${linkedHotel.country}'}'
                                : linkedHotel.address,
                          ),
                          Text(
                              'Rating: ${linkedHotel.rating.toStringAsFixed(1)}'),
                        ],
                      ),
              ),
              const _SectionDivider(),
              _DashboardSection(
                icon: Icons.payments_outlined,
                title: 'Budget',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${trip.currency} ${trip.budget.toStringAsFixed(2)}'),
                    const SizedBox(height: 4),
                    Text('Spent ${trip.currency} ${spent.toStringAsFixed(2)}'),
                    Text(
                        'Remaining ${trip.currency} ${remaining.toStringAsFixed(2)}'),
                  ],
                ),
              ),
              const _SectionDivider(),
              _DashboardSection(
                icon: Icons.event_note,
                title: 'Itinerary',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildDayItems(_tripDays(trip)),
                ),
              ),
              const _SectionDivider(),
              _DashboardSection(
                icon: Icons.alt_route,
                title: 'Transport Timeline',
                child: ridesAsync.when(
                  loading: () => const Text('Loading transport rides...'),
                  error: (error, _) => Text('Could not load rides: $error'),
                  data: (rides) {
                    if (rides.isEmpty) {
                      return const Text('No saved transport rides yet.');
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: rides
                          .map((ride) => _TransportRideLine(
                                ride: ride,
                                onBookReturnRide: () {
                                  final returnRequest = TaxiRideRequest(
                                    pickupLatitude: ride.destinationLatitude,
                                    pickupLongitude: ride.destinationLongitude,
                                    pickupAddress: ride.destinationAddress,
                                    destinationLatitude: ride.pickupLatitude,
                                    destinationLongitude: ride.pickupLongitude,
                                    destinationAddress: ride.pickupAddress,
                                    pickupTime: ride.scheduledAt,
                                    passengers: ride.passengers,
                                    luggage: ride.luggage,
                                  );

                                  context.pushTaxiResults(returnRequest);
                                },
                              ))
                          .toList(growable: false),
                    );
                  },
                ),
              ),
              if (linkedFlight != null) ...[
                const _SectionDivider(),
                _AiArrivalSuggestionCard(
                  flight: linkedFlight,
                  trip: trip,
                  linkedHotel: linkedHotel,
                ),
              ],
              const _SectionDivider(),
              const _DashboardSection(
                icon: Icons.map_outlined,
                title: 'Map',
                child: Text('Map integration coming next.'),
              ),
              const _SectionDivider(),
              const _DashboardSection(
                icon: Icons.description_outlined,
                title: 'Documents',
                child: Text('Travel documents module coming next.'),
              ),
              const _SectionDivider(),
              const _DashboardSection(
                icon: Icons.translate_outlined,
                title: 'Translator',
                child: Text('AI translator module coming next.'),
              ),
              const _SectionDivider(),
              const _DashboardSection(
                icon: Icons.smart_toy_outlined,
                title: 'AI Assistant',
                child: Text('Trip AI assistant coming next.'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Trip'),
                onPressed: () {
                  final router = GoRouter.maybeOf(context);
                  if (router != null) {
                    context.pushEditTrip(trip.id, initialTrip: trip);
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditTripPage(trip: trip),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Delete Trip'),
                onPressed: () => _confirmDelete(context, ref, trip),
              ),
            ],
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

  List<Widget> _buildDayItems(int count) {
    return List<Widget>.generate(
      count,
      (index) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text('Day ${index + 1}'),
      ),
    );
  }

  static String _formatIsoDateTime(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }
    return DateFormat('dd MMM, HH:mm').format(parsed);
  }
}

class _TransportRideLine extends StatelessWidget {
  const _TransportRideLine({
    required this.ride,
    required this.onBookReturnRide,
  });

  final TaxiSavedRide ride;
  final VoidCallback onBookReturnRide;

  @override
  Widget build(BuildContext context) {
    final scheduledText = ride.scheduledAt == null
        ? 'ASAP'
        : DateFormat('dd MMM, HH:mm').format(ride.scheduledAt!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.local_taxi, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ride.pickupAddress} -> ${ride.destinationAddress}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text('${ride.provider} | $scheduledText'),
                  Text(
                    '${ride.currency} ${ride.estimatedFare.toStringAsFixed(2)} | ${ride.passengers} pax | ${ride.luggage} luggage',
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: onBookReturnRide,
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Book Return Ride'),
                    ),
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

class _AiArrivalSuggestionCard extends StatelessWidget {
  const _AiArrivalSuggestionCard({
    required this.flight,
    required this.trip,
    required this.linkedHotel,
  });

  final SavedFlight flight;
  final Trip trip;
  final SavedHotel? linkedHotel;

  @override
  Widget build(BuildContext context) {
    final arrival = DateTime.tryParse(flight.arrivalAt);
    final arrivalText = arrival == null
        ? flight.arrivalAt
        : DateFormat('HH:mm').format(arrival);

    final isLateArrival = arrival != null && (arrival.hour >= 21 || arrival.hour <= 5);

    final destinationAddress = _resolveHotelDestination();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smart_toy_outlined),
              const SizedBox(width: 8),
              Text(
                'AI Arrival Suggestions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isLateArrival
                ? 'You arrive at $arrivalText. Would you like to prepare a late-arrival plan?'
                : 'Arrival at $arrivalText. Want to prepare your post-flight flow?',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () {
                  final request = TaxiRideRequest(
                    pickupLatitude: 0,
                    pickupLongitude: 0,
                    pickupAddress: '${trip.destination} Airport',
                    destinationLatitude: 0,
                    destinationLongitude: 0,
                    destinationAddress: destinationAddress,
                    pickupTime: arrival,
                    passengers: trip.travellers,
                    luggage: trip.travellers,
                  );

                  context.pushTaxiResults(request);
                },
                icon: const Icon(Icons.local_taxi),
                label: const Text('Book Taxi'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Hotel notification workflow coming next.'),
                    ),
                  );
                },
                icon: const Icon(Icons.hotel_outlined),
                label: const Text('Notify Hotel'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Receipt capture assistant is queued for next step.'),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Save Receipt'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.pushAiAssistant(),
                icon: const Icon(Icons.translate_outlined),
                label: const Text('Translate Destination'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _resolveHotelDestination() {
    final hotel = linkedHotel;
    if (hotel == null) {
      return '${trip.destination} City Center';
    }

    if (hotel.address.isNotEmpty) {
      return hotel.address;
    }

    final country = hotel.country.trim();
    if (country.isEmpty) {
      return hotel.city;
    }
    return '${hotel.city}, $country';
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _WeatherLine extends StatelessWidget {
  const _WeatherLine({required this.weather});

  final WeatherData weather;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${weather.tempC.toStringAsFixed(0)}°C - ${weather.description}',
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(height: 1),
    );
  }
}
