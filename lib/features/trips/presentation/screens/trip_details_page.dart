import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../flights/models/saved_flight.dart';
import '../../../flights/providers/flight_provider.dart';
import '../../../hotels/models/saved_hotel.dart';
import '../../../hotels/providers/hotel_experience_provider.dart';
import '../../../hotels/providers/hotel_provider.dart';
import '../../../weather/models/weather_data.dart';
import '../../../weather/providers/weather_provider.dart';
import '../../models/trip.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_timeline.dart';

enum TripDetailsAction { edit, duplicate }

class TripDetailsPage extends ConsumerStatefulWidget {
  const TripDetailsPage({
    super.key,
    required this.trip,
  });

  final Trip trip;

  @override
  ConsumerState<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends ConsumerState<TripDetailsPage> {
  bool _isDeleting = false;

  Future<void> _deleteTrip(BuildContext context) async {
    if (_isDeleting) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete trip?'),
          content: Text(
            'Remove your trip to ${widget.trip.destination}? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await deleteTrip(ref, widget.trip.id);
      ref.invalidate(tripsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted trip to ${widget.trip.destination}.')),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to delete trip: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final flightsAsync = ref.watch(savedFlightsProvider);
    final hotelsAsync = ref.watch(savedHotelsProvider);
    final weatherAsync = ref.watch(weatherProvider(trip.destination));
    final nearbyAsync = ref.watch(nearbyBundleProvider(trip.destination));
    final currencyAsync = ref.watch(currencyRateProvider(_currencyTarget()));
    final snapshotWeather = trip.weatherSnapshot == null
        ? null
        : WeatherData.fromJson(trip.weatherSnapshot!);

    final linkedFlight = _findFlight(flightsAsync.valueOrNull ?? const [], trip.flightId);
    final linkedHotel = _findHotel(hotelsAsync.valueOrNull ?? const [], trip.hotelId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Trip to ${trip.destination}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                Navigator.pop(context, TripDetailsAction.edit);
                return;
              }

              if (value == 'duplicate') {
                Navigator.pop(context, TripDetailsAction.duplicate);
                return;
              }

              if (value == 'delete') {
                await _deleteTrip(context);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit trip'),
              ),
              PopupMenuItem<String>(
                value: 'duplicate',
                child: Text('Duplicate trip'),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete trip'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Section(
              title: 'Trip Summary',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.destination,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${_formatDate(trip.startDate)} → ${_formatDate(trip.endDate)}',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('${trip.travellers} ${trip.travellers == 1 ? 'traveller' : 'travellers'}'),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Budget: ${trip.currency} ${trip.budget.toStringAsFixed(0)}'),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Status: ${trip.status}'),
                  const SizedBox(height: AppSpacing.md),
                  Text('Notes', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    trip.notes.trim().isEmpty ? 'No notes added yet.' : trip.notes,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _Section(
              title: 'Flight',
              child: linkedFlight == null
                  ? const Text('No flight linked')
                  : InkWell(
                      onTap: () {
                        context.pushSavedFlightDetails(linkedFlight);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(linkedFlight.flightNumber, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: AppSpacing.sm),
                          Text('${linkedFlight.departureAt} → ${linkedFlight.arrivalAt}'),
                          const SizedBox(height: AppSpacing.sm),
                          Text(linkedFlight.airline),
                          const SizedBox(height: AppSpacing.sm),
                          const Text(
                            'Open flight details →',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            _Section(
              title: 'Hotel',
              child: linkedHotel == null
                  ? const Text('No hotel linked')
                  : InkWell(
                      onTap: () {
                        context.pushSavedHotelDetails(linkedHotel);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(linkedHotel.name, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: AppSpacing.sm),
                          Text('Check-in: ${_formatDate(trip.startDate)}'),
                          const SizedBox(height: AppSpacing.xs),
                          Text('Check-out: ${_formatDate(trip.endDate)}'),
                          const SizedBox(height: AppSpacing.sm),
                          const Text(
                            'Open hotel details →',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            _Section(
              title: 'Timeline',
              child: TripTimeline(
                entries: [
                  TripTimelineEntry(
                    dateLabel: _shortDate(trip.startDate),
                    title: 'Flight departs',
                    subtitle: linkedFlight == null ? 'Flight not linked' : '${linkedFlight.airline} ${linkedFlight.flightNumber}',
                  ),
                  TripTimelineEntry(
                    dateLabel: _shortDate(trip.startDate),
                    title: 'Hotel check-in',
                    subtitle: linkedHotel?.name ?? 'Hotel not linked',
                  ),
                  TripTimelineEntry(
                    dateLabel: _shortDate(trip.startDate.add(const Duration(days: 1))),
                    title: 'Weather forecast',
                    subtitle: snapshotWeather == null ? 'Forecast unavailable' : '${snapshotWeather.tempC.toStringAsFixed(0)}° ${snapshotWeather.description}',
                  ),
                  TripTimelineEntry(
                    dateLabel: _shortDate(trip.endDate.subtract(const Duration(days: 1))),
                    title: 'Planned activity',
                    subtitle: 'Explore nearby attractions',
                  ),
                  TripTimelineEntry(
                    dateLabel: _shortDate(trip.endDate),
                    title: 'Hotel check-out',
                    subtitle: linkedHotel?.name ?? 'Hotel not linked',
                  ),
                  TripTimelineEntry(
                    dateLabel: _shortDate(trip.endDate),
                    title: 'Return flight',
                    subtitle: linkedFlight == null ? 'Flight not linked' : '${linkedFlight.origin} → ${linkedFlight.destination}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _Section(
              title: 'Weather',
              child: weatherAsync.when(
                loading: () => const LoadingIndicator(message: 'Loading weather...'),
                error: (error, _) {
                  if (snapshotWeather != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_snapshotLabel(trip)),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Monday ${snapshotWeather.tempC.toStringAsFixed(0)}°'),
                        const SizedBox(height: AppSpacing.xs),
                        Text('Tuesday ${(snapshotWeather.tempC + 2).toStringAsFixed(0)}°'),
                        const SizedBox(height: AppSpacing.xs),
                        Text('Wednesday ${(snapshotWeather.tempC + 1).toStringAsFixed(0)}°'),
                      ],
                    );
                  }
                  return Text('Weather unavailable: $error');
                },
                data: (weather) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Source: Live weather service'),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Monday ${weather.tempC.toStringAsFixed(0)}°'),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Tuesday ${(weather.tempC + 2).toStringAsFixed(0)}°'),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Wednesday ${(weather.tempC + 1).toStringAsFixed(0)}°'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _Section(
              title: 'Currency',
              child: currencyAsync.when(
                loading: () => const Text('Loading currency...'),
                error: (_, __) => Text('${trip.currency} → EUR'),
                data: (rate) => Text('${rate.base} → ${rate.target}'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _Section(
              title: 'Attractions',
              child: nearbyAsync.when(
                loading: () => const Text('Loading attractions...'),
                error: (_, __) => const Text('Attractions unavailable'),
                data: (nearby) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: nearby.attractions
                      .take(3)
                      .map((place) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                            child: Text(place.name),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _snapshotLabel(Trip trip) {
    final capturedAt = trip.weatherSnapshotCapturedAt;
    if (capturedAt == null) {
      return 'Source: Saved weather snapshot';
    }

    final hour = capturedAt.hour.toString().padLeft(2, '0');
    final minute = capturedAt.minute.toString().padLeft(2, '0');
    return 'Source: Saved weather snapshot from ${capturedAt.day}/${capturedAt.month}/${capturedAt.year} $hour:$minute';
  }

  SavedFlight? _findFlight(List<SavedFlight> flights, String? flightId) {
    if (flightId == null) return null;
    for (final flight in flights) {
      if (flight.flightId == flightId) return flight;
    }
    return null;
  }

  SavedHotel? _findHotel(List<SavedHotel> hotels, String? hotelId) {
    if (hotelId == null) return null;
    for (final hotel in hotels) {
      if (hotel.hotelId == hotelId) return hotel;
    }
    return null;
  }

  String _currencyTarget() {
    switch (widget.trip.currency.toUpperCase()) {
      case 'EUR':
        return 'EUR';
      case 'USD':
        return 'USD';
      default:
        return 'EUR';
    }
  }

  static String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  static String _shortDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
