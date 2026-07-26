import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../flights/models/saved_flight.dart';
import '../../flights/providers/flight_provider.dart';
import '../../hotels/models/saved_hotel.dart';
import '../../hotels/providers/hotel_experience_provider.dart';
import '../../hotels/providers/hotel_provider.dart';
import '../../weather/providers/weather_provider.dart';
import '../models/saved_trip.dart';
import '../providers/trip_provider.dart';

class TripPlannerPage extends ConsumerStatefulWidget {
  const TripPlannerPage({super.key});

  @override
  ConsumerState<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends ConsumerState<TripPlannerPage> {
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();

  DateTime? _departureDate;
  DateTime? _returnDate;
  int _travelers = 1;

  @override
  void dispose() {
    _destinationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickDepartureDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (date != null) {
      setState(() {
        _departureDate = date;
        if (_returnDate != null && _returnDate!.isBefore(_departureDate!)) {
          _returnDate = _departureDate!.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _pickReturnDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _returnDate ?? _departureDate?.add(const Duration(days: 1)) ?? DateTime.now().add(const Duration(days: 2)),
      firstDate: _departureDate ?? DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (date != null) {
      setState(() {
        _returnDate = date;
      });
    }
  }

  Future<void> _saveTrip() async {
    if (_destinationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a destination')),
      );
      return;
    }

    if (_departureDate == null || _returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select departure and return dates')),
      );
      return;
    }

    if (_returnDate!.isBefore(_departureDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Return date must be after departure date')),
      );
      return;
    }

    final destination = _destinationController.text.trim();
    final savedFlights = ref.read(savedFlightsProvider).valueOrNull ?? const <SavedFlight>[];
    final savedHotels = ref.read(savedHotelsProvider).valueOrNull ?? const <SavedHotel>[];

    final linkedFlight = _pickFlightForDestination(savedFlights, destination);
    final linkedHotel = _pickHotelForDestination(savedHotels, destination);

    await addTrip(
      ref,
      destination: destination,
      departureDate: _departureDate!,
      returnDate: _returnDate!,
      travelers: _travelers,
      totalBudget: double.tryParse(_budgetController.text),
      flightIds: linkedFlight == null ? const [] : [linkedFlight.flightId],
      hotelIds: linkedHotel == null ? const [] : [linkedHotel.hotelId],
    );

    _destinationController.clear();
    _budgetController.clear();
    setState(() {
      _departureDate = null;
      _returnDate = null;
      _travelers = 1;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            linkedFlight != null || linkedHotel != null
                ? 'Trip saved and linked to existing bookings.'
                : 'Trip saved. You can link flights and hotels anytime.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(savedTripsProvider);
    final flightsAsync = ref.watch(savedFlightsProvider);
    final hotelsAsync = ref.watch(savedHotelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Builder'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFEFF6FF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Build Complete Trips',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    hintText: 'e.g. Paris, Tokyo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: _pickDepartureDate,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _departureDate == null
                                        ? 'Departure'
                                        : '${_departureDate!.day}/${_departureDate!.month}/${_departureDate!.year}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: _pickReturnDate,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _returnDate == null
                                        ? 'Return'
                                        : '${_returnDate!.day}/${_returnDate!.month}/${_returnDate!.year}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Budget (optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_pound),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _travelers > 1 ? () => setState(() => _travelers--) : null,
                            ),
                            Text('$_travelers'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => setState(() => _travelers++),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saveTrip,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Trip'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tripsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (trips) {
                final flights = flightsAsync.valueOrNull ?? const <SavedFlight>[];
                final hotels = hotelsAsync.valueOrNull ?? const <SavedHotel>[];

                if (trips.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.luggage_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No trips planned yet',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return _TripBuilderCard(
                      trip: trip,
                      linkedFlight: _findTripFlight(trip, flights),
                      linkedHotel: _findTripHotel(trip, hotels),
                      onDelete: () => deleteTrip(ref, trip.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  SavedFlight? _pickFlightForDestination(List<SavedFlight> flights, String destination) {
    final lower = destination.toLowerCase();
    for (final flight in flights) {
      if (flight.destination.toLowerCase().contains(lower) || flight.origin.toLowerCase().contains(lower)) {
        return flight;
      }
    }
    return flights.isEmpty ? null : flights.first;
  }

  SavedHotel? _pickHotelForDestination(List<SavedHotel> hotels, String destination) {
    final lower = destination.toLowerCase();
    for (final hotel in hotels) {
      if (hotel.city.toLowerCase().contains(lower) || hotel.name.toLowerCase().contains(lower)) {
        return hotel;
      }
    }
    return hotels.isEmpty ? null : hotels.first;
  }

  SavedFlight? _findTripFlight(SavedTrip trip, List<SavedFlight> flights) {
    for (final id in trip.flightIds) {
      for (final f in flights) {
        if (f.flightId == id) {
          return f;
        }
      }
    }
    return null;
  }

  SavedHotel? _findTripHotel(SavedTrip trip, List<SavedHotel> hotels) {
    for (final id in trip.hotelIds) {
      for (final h in hotels) {
        if (h.hotelId == id) {
          return h;
        }
      }
    }
    return null;
  }
}

class _TripBuilderCard extends ConsumerWidget {
  const _TripBuilderCard({
    required this.trip,
    required this.linkedFlight,
    required this.linkedHotel,
    required this.onDelete,
  });

  final SavedTrip trip;
  final SavedFlight? linkedFlight;
  final SavedHotel? linkedHotel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider(trip.destination));
    final nearbyAsync = ref.watch(nearbyBundleProvider(trip.destination));
    final target = _currencyTarget(linkedHotel?.country ?? '');
    final currencyAsync = ref.watch(currencyRateProvider(target));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Trip to ${trip.destination}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${trip.departureDate.day}/${trip.departureDate.month}/${trip.departureDate.year} - ${trip.returnDate.day}/${trip.returnDate.month}/${trip.returnDate.year}',
            ),
            const SizedBox(height: 10),
            _Line(icon: Icons.flight_outlined, title: 'Flight', value: _flightLine(linkedFlight)),
            const SizedBox(height: 6),
            _Line(icon: Icons.hotel_outlined, title: 'Hotel', value: _hotelLine(linkedHotel)),
            const SizedBox(height: 6),
            weatherAsync.when(
              loading: () => const _Line(icon: Icons.wb_sunny_outlined, title: 'Weather', value: 'Loading...'),
              error: (_, __) => const _Line(icon: Icons.wb_sunny_outlined, title: 'Weather', value: 'Unavailable'),
              data: (weather) => _Line(
                icon: Icons.wb_sunny_outlined,
                title: 'Weather',
                value: '${weather.tempC.toStringAsFixed(0)}°C ${weather.description}',
              ),
            ),
            const SizedBox(height: 6),
            currencyAsync.when(
              loading: () => const _Line(icon: Icons.currency_exchange, title: 'Currency', value: 'Loading...'),
              error: (_, __) => const _Line(icon: Icons.currency_exchange, title: 'Currency', value: 'Unavailable'),
              data: (rate) => _Line(
                icon: Icons.currency_exchange,
                title: 'Currency',
                value: '1 GBP = ${rate.rate.toStringAsFixed(2)} ${rate.target}',
              ),
            ),
            const SizedBox(height: 6),
            nearbyAsync.when(
              loading: () => const _Line(icon: Icons.place_outlined, title: 'Attractions', value: 'Loading...'),
              error: (_, __) => const _Line(icon: Icons.place_outlined, title: 'Attractions', value: 'Unavailable'),
              data: (nearby) {
                final names = nearby.attractions.take(2).map((e) => e.name).join(', ');
                return _Line(icon: Icons.place_outlined, title: 'Attractions', value: names.isEmpty ? 'None' : names);
              },
            ),
            const SizedBox(height: 6),
            _Line(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Budget',
              value: trip.totalBudget > 0
                  ? '£${trip.totalBudget.toStringAsFixed(0)}'
                  : (linkedFlight != null || linkedHotel != null
                      ? '£${_estimatedBudget(trip, linkedFlight, linkedHotel).toStringAsFixed(0)} (estimated)'
                      : 'Not set'),
            ),
            const SizedBox(height: 10),
            _UpcomingReminder(trip: trip),
          ],
        ),
      ),
    );
  }

  static String _flightLine(SavedFlight? f) {
    if (f == null) {
      return 'No linked flight';
    }
    return '${f.airline} ${f.flightNumber}';
  }

  static String _hotelLine(SavedHotel? h) {
    if (h == null) {
      return 'No linked hotel';
    }
    return '${h.name} (${h.city})';
  }

  static String _currencyTarget(String country) {
    switch (country.toLowerCase()) {
      case 'france':
      case 'spain':
        return 'EUR';
      case 'united states':
        return 'USD';
      case 'japan':
        return 'JPY';
      default:
        return 'EUR';
    }
  }

  static double _estimatedBudget(SavedTrip trip, SavedFlight? flight, SavedHotel? hotel) {
    final flightCost = flight?.amount ?? 0;
    final hotelCost = hotel?.pricePerNight ?? 0;
    return flightCost + (hotelCost * trip.nights * trip.travelers);
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2F5EAA)),
        const SizedBox(width: 8),
        Expanded(child: Text('$title: $value')),
      ],
    );
  }
}

class _UpcomingReminder extends StatelessWidget {
  const _UpcomingReminder({required this.trip});

  final SavedTrip trip;

  @override
  Widget build(BuildContext context) {
    final days = trip.departureDate.difference(DateTime.now()).inDays;

    if (days < 0) {
      return const Chip(
        avatar: Icon(Icons.check_circle_outline),
        label: Text('Trip dates have passed'),
      );
    }

    if (days <= 3) {
      return Chip(
        avatar: const Icon(Icons.notifications_active_outlined),
        label: Text('Reminder: Your trip starts in $days day${days == 1 ? '' : 's'}'),
      );
    }

    return Chip(
      avatar: const Icon(Icons.schedule_outlined),
      label: Text('Upcoming in $days days'),
    );
  }
}
