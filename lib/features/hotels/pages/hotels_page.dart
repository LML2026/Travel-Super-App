import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hotel.dart';
import '../models/hotel_search_request.dart';
import '../providers/hotel_provider.dart';
import '../widgets/hotel_card.dart';

class HotelsPage extends ConsumerStatefulWidget {
  const HotelsPage({super.key});

  @override
  ConsumerState<HotelsPage> createState() => _HotelsPageState();
}

class _HotelsPageState extends ConsumerState<HotelsPage> {
  final _cityController = TextEditingController();
  late DateTime _checkInDate;
  late DateTime _checkOutDate;
  int _guests = 1;
  int _rooms = 1;

  HotelSearchRequest? _currentSearch;

  @override
  void initState() {
    super.initState();
    _checkInDate = DateTime.now().add(const Duration(days: 1));
    _checkOutDate = DateTime.now().add(const Duration(days: 3));
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    if (_cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a destination')),
      );
      return;
    }

    if (_checkOutDate.isBefore(_checkInDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-out must be after check-in')),
      );
      return;
    }

    final request = HotelSearchRequest(
      city: _cityController.text.trim(),
      checkInDate: _checkInDate,
      checkOutDate: _checkOutDate,
      guests: _guests,
      rooms: _rooms,
    );

    setState(() {
      _currentSearch = request;
    });

    // Invalidate cache to trigger refetch
    ref.refresh(hotelSearchProvider(request));
  }

  Future<void> _selectCheckInDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _checkInDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        _checkInDate = selectedDate;
        if (_checkOutDate.isBefore(_checkInDate)) {
          _checkOutDate = _checkInDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _checkOutDate,
      firstDate: _checkInDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        _checkOutDate = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Hotels')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Form
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                        hintText: 'e.g. Paris, London, Tokyo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: _selectCheckInDate,
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
                                        'Check-in: ${_checkInDate.day}/${_checkInDate.month}/${_checkInDate.year}',
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
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: _selectCheckOutDate,
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
                                        'Check-out: ${_checkOutDate.day}/${_checkOutDate.month}/${_checkOutDate.year}',
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
                          child: _Counter(
                            label: 'Guests',
                            value: _guests,
                            onDecrement:
                                _guests > 1 ? () => setState(() => _guests--) : null,
                            onIncrement: () => setState(() => _guests++),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _Counter(
                            label: 'Rooms',
                            value: _rooms,
                            onDecrement: _rooms > 1 ? () => setState(() => _rooms--) : null,
                            onIncrement: () => setState(() => _rooms++),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _triggerSearch,
                        icon: const Icon(Icons.search),
                        label: const Text('Search Hotels'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Results
            if (_currentSearch != null)
              _HotelResults(request: _currentSearch!),
          ],
        ),
      ),
    );
  }
}

class _HotelResults extends ConsumerWidget {
  final HotelSearchRequest request;

  const _HotelResults({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hotelsAsync = ref.watch(hotelSearchProvider(request));

    return hotelsAsync.when(
      loading: () => Column(
        children: [
          Text(
            'Searching ${request.guests} guest${request.guests > 1 ? 's' : ''} in ${request.city}...',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) => _SkeletonHotelCard(),
          ),
        ],
      ),
      error: (error, stackTrace) => Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: ${error.toString()}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
      data: (hotels) {
        // Save the search to Firestore (fire and forget after successful results)
        if (hotels.isNotEmpty) {
          Future.microtask(() {
            try {
              ref.read(saveRecentHotelSearchProvider(request));
            } catch (e) {
              // Silently fail - don't interrupt user experience
            }
          });
        }

        if (hotels.isEmpty) {
          return Center(
            child: Column(
              children: [
                Icon(Icons.luggage, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No hotels found for ${request.city}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${hotels.length} hotels found',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: hotels.length,
              itemBuilder: (context, index) => HotelCard(hotel: hotels[index]),
            ),
          ],
        );
      },
    );
  }
}

class _SkeletonHotelCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 12,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  const _Counter({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onDecrement,
                icon: const Icon(Icons.remove_circle_outline),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text('$value', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: onIncrement,
                icon: const Icon(Icons.add_circle_outline),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
