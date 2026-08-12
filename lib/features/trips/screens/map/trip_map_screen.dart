import 'package:flutter/material.dart';

import '../../models/itinerary/itinerary_item.dart';
import '../../models/trip.dart';

class TripMapScreen extends StatelessWidget {
  final Trip trip;
  final List<ItineraryItem> items;

  const TripMapScreen({
    super.key,
    required this.trip,
    required this.items,
  });

  List<ItineraryItem> get _locatedItems {
    return items
        .where(
          (item) =>
              item.latitude != null &&
              item.longitude != null,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final locatedItems = _locatedItems;

    return Scaffold(
      appBar: AppBar(
        title: Text('${trip.destination} Map'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      child: Icon(Icons.map_outlined),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.destination,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${locatedItems.length} mapped itinerary stops',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: locatedItems.isEmpty
                ? const _EmptyMapState()
                : ListView.separated(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      30,
                    ),
                    itemCount: locatedItems.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item =
                          locatedItems[index];

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              '${index + 1}',
                            ),
                          ),
                          title: Text(item.title),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              if (item.location
                                  .isNotEmpty)
                                Text(item.location),
                              Text(
                                '${item.latitude!.toStringAsFixed(5)}, '
                                '${item.longitude!.toStringAsFixed(5)}',
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons
                                .location_on_outlined,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMapState extends StatelessWidget {
  const _EmptyMapState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.map_outlined,
              size: 72,
            ),
            const SizedBox(height: 20),
            Text(
              'No mapped stops yet',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Locations with coordinates will appear here and will later become interactive map markers.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
