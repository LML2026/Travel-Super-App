import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/trip_provider.dart';
import '../models/saved_trip.dart';

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

    await addTrip(
      ref,
      destination: _destinationController.text.trim(),
      departureDate: _departureDate!,
      returnDate: _returnDate!,
      travelers: _travelers,
      totalBudget: double.tryParse(_budgetController.text),
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
        const SnackBar(content: Text('✅ Trip saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(savedTripsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
      ),
      body: Column(
        children: [
          // Add Trip Form
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✈️ Plan Your Next Trip',
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _departureDate == null
                                        ? 'Departure'
                                        : '${_departureDate!.day}/${_departureDate!.month}',
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _returnDate == null
                                        ? 'Return'
                                        : '${_returnDate!.day}/${_returnDate!.month}',
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
                          prefixIcon: Icon(Icons.attach_money),
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
                              onPressed: _travelers > 1
                                  ? () => setState(() => _travelers--)
                                  : null,
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

          // Saved Trips List
          Expanded(
            child: tripsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
              data: (trips) {
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
                    return _TripCard(
                      trip: trip,
                      onDelete: () async {
                        await deleteTrip(ref, trip.id);
                      },
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
}

class _TripCard extends StatelessWidget {
  final SavedTrip trip;
  final VoidCallback onDelete;

  const _TripCard({
    required this.trip,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.destination,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${trip.nights} night${trip.nights > 1 ? 's' : ''} • ${trip.travelers} traveler${trip.travelers > 1 ? 's' : ''}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Departure',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '${trip.departureDate.day}/${trip.departureDate.month}/${trip.departureDate.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Return',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '${trip.returnDate.day}/${trip.returnDate.month}/${trip.returnDate.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                if (trip.totalBudget > 0)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          '\$${trip.totalBudget.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
