import 'package:flutter/material.dart';

import '../../../../core/storage/itinerary_storage_service.dart';

import '../../models/itinerary/itinerary_item.dart';
import '../../models/trip.dart';
import 'add_itinerary_item_screen.dart';

class ItineraryScreen extends StatefulWidget {
  final Trip trip;

  const ItineraryScreen({
    super.key,
    required this.trip,
  });

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final List<ItineraryItem> _items = [];

  final ItineraryStorageService _storage = ItineraryStorageService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _storage.loadItems(widget.trip.id);

    if (!mounted) return;

    setState(() {
      _items
        ..clear()
        ..addAll(items);
      _isLoading = false;
    });
  }

  Future<void> _persistItems() async {
    await _storage.saveItems(widget.trip.id, _items);
  }

  Future<void> _addItem() async {
    final item = await Navigator.of(context).push<ItineraryItem>(
      MaterialPageRoute(
        builder: (_) => AddItineraryItemScreen(trip: widget.trip),
      ),
    );

    if (item != null && mounted) {
      setState(() {
        _items.add(item);
        _items.sort((a, b) {
          final dateCompare = a.date.compareTo(b.date);
          if (dateCompare != 0) return dateCompare;

          return (a.time ?? '').compareTo(b.time ?? '');
        });
      });

      await _persistItems();
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.trip.destination} Itinerary'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.route_outlined,
                      size: 72,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No itinerary items yet',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Add activities, restaurants, transport, attractions and bookings for ${widget.trip.destination}.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: _items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _items[index];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (item.isBooked)
                              const Chip(
                                label: Text('Booked'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_formatDate(item.date)}'
                          '${item.time == null ? '' : ' • ${item.time}'}',
                        ),
                        const SizedBox(height: 6),
                        Text(item.category),
                        if (item.location.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(item.location),
                              ),
                            ],
                          ),
                        ],
                        if (item.estimatedCost != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            '${item.currency} ${item.estimatedCost!.toStringAsFixed(2)}',
                          ),
                        ],
                        if (item.notes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(item.notes),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}


