import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hotel.dart';
import '../models/saved_hotel.dart';
import '../providers/hotel_provider.dart';

class HotelDetailsPage extends ConsumerWidget {
  final Hotel hotel;

  const HotelDetailsPage({
    super.key,
    required this.hotel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSavedAsync = ref.watch(isHotelSavedProvider(hotel.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            Container(
              color: const Color(0xFF1976D2).withOpacity(0.1),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Hotel image and name
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          hotel.image,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotel.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  hotel.city,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  '${hotel.rating.toStringAsFixed(1)} out of 5',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '\$${hotel.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room Details
                  _DetailSection(
                    title: 'Room Details',
                    child: Column(
                      children: [
                        _DetailsRow(
                          label: 'Number of Beds',
                          value: '${hotel.beds} bed${hotel.beds > 1 ? 's' : ''}',
                        ),
                        _DetailsRow(
                          label: 'Number of Nights',
                          value: '${hotel.nights} night${hotel.nights > 1 ? 's' : ''}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Pricing Breakdown
                  _DetailSection(
                    title: 'Pricing',
                    child: Column(
                      children: [
                        _DetailsRow(
                          label: 'Price per Night',
                          value: '\$${hotel.pricePerNight.toStringAsFixed(0)}',
                        ),
                        _DetailsRow(
                          label: 'Number of Nights',
                          value: '${hotel.nights}',
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Colors.grey[300]),
                        ),
                        _DetailsRow(
                          label: 'Total Price',
                          value: '\$${hotel.totalPrice.toStringAsFixed(0)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Hotel Information
                  _DetailSection(
                    title: 'Hotel Information',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotel.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 20, color: Color(0xFF1976D2)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  hotel.city,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 20, color: Colors.amber),
                              const SizedBox(width: 12),
                              Text(
                                '${hotel.rating.toStringAsFixed(1)} Star Rating',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      // Save button
                      Expanded(
                        child: isSavedAsync.when(
                          data: (isSaved) => OutlinedButton.icon(
                            onPressed: () {
                              if (isSaved) {
                                ref.read(getSavedHotelIdProvider(hotel.id).future).then((saveId) {
                                  if (saveId != null) {
                                    ref.read(removeSavedHotelProvider(saveId).future);
                                  }
                                });
                              } else {
                                final savedHotel = SavedHotel(
                                  id: '',
                                  hotelId: hotel.id,
                                  name: hotel.name,
                                  city: hotel.city,
                                  rating: hotel.rating,
                                  pricePerNight: hotel.pricePerNight,
                                  totalPrice: hotel.totalPrice,
                                  beds: hotel.beds,
                                  image: hotel.image,
                                  nights: hotel.nights,
                                  savedAt: DateTime.now(),
                                );
                                ref.read(saveHotelProvider(savedHotel).future);
                              }
                            },
                            icon: Icon(
                              isSaved ? Icons.favorite : Icons.favorite_border,
                              color: isSaved ? Colors.red : null,
                            ),
                            label: Text(isSaved ? 'Saved' : 'Save Hotel'),
                          ),
                          loading: () => OutlinedButton.icon(
                            onPressed: null,
                            icon: const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            label: const Text('Loading...'),
                          ),
                          error: (_, __) => OutlinedButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.error),
                            label: const Text('Error'),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Book button
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Booking ${hotel.name} - Coming soon!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.done),
                          label: const Text('Reserve'),
                        ),
                      ),
                    ],
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

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _DetailsRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _DetailsRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.black : Colors.grey[600],
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? const Color(0xFF1976D2) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
