import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../flights/models/saved_flight.dart';
import '../../../flights/providers/flight_provider.dart';
import '../../../hotels/models/saved_hotel.dart';
import '../../../hotels/providers/hotel_provider.dart';
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

    await ref.read(tripRepositoryProvider).deleteTrip(trip.id);

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(tripRepositoryProvider);

    return FutureBuilder<Trip?>(
      future: repository.getTrip(tripId),
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

        final linkedFlight = _findLinkedFlight(
          flightsAsync.valueOrNull ?? const <SavedFlight>[],
          trip.destination,
        );
        final linkedHotel = _findLinkedHotel(
          hotelsAsync.valueOrNull ?? const <SavedHotel>[],
          trip.destination,
        );

        final spent = (linkedFlight?.amount ?? 0) + (linkedHotel?.totalPrice ?? 0);
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
                          Text('${linkedFlight.origin} -> ${linkedFlight.destination}'),
                          Text('Departure: ${_formatIsoDateTime(linkedFlight.departureAt)}'),
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
                          Text('Rating: ${linkedHotel.rating.toStringAsFixed(1)}'),
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
                    Text('Remaining ${trip.currency} ${remaining.toStringAsFixed(2)}'),
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

  SavedFlight? _findLinkedFlight(List<SavedFlight> flights, String destination) {
    for (final flight in flights) {
      if (_sameLocation(flight.destination, destination)) {
        return flight;
      }
    }
    return null;
  }

  SavedHotel? _findLinkedHotel(List<SavedHotel> hotels, String destination) {
    for (final hotel in hotels) {
      if (_sameLocation(hotel.city, destination) || _sameLocation(hotel.address, destination)) {
        return hotel;
      }
    }
    return null;
  }

  bool _sameLocation(String a, String b) {
    final left = a.trim().toLowerCase();
    final right = b.trim().toLowerCase();
    return left == right || left.contains(right) || right.contains(left);
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
