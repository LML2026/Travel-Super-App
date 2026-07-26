import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hotel.dart';
import '../models/saved_hotel.dart';
import '../pages/hotel_details_page.dart';
import '../providers/hotel_provider.dart';

class HotelCard extends ConsumerStatefulWidget {
  final Hotel hotel;

  const HotelCard({
    super.key,
    required this.hotel,
  });

  @override
  ConsumerState<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends ConsumerState<HotelCard> {
  void _navigateToDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelDetailsPage(hotel: widget.hotel),
      ),
    );
  }

  void _toggleSave() async {
    final isSaved = await ref.read(isHotelSavedProvider(widget.hotel.id).future);
    
    if (isSaved) {
      // Remove from saved
      final saveId = await ref.read(getSavedHotelIdProvider(widget.hotel.id).future);
      if (saveId != null) {
        await ref.read(removeSavedHotelProvider(saveId).future);
      }
    } else {
      // Add to saved
      final savedHotel = SavedHotel(
        id: '',
        hotelId: widget.hotel.id,
        name: widget.hotel.name,
        city: widget.hotel.city,
        rating: widget.hotel.rating,
        pricePerNight: widget.hotel.pricePerNight,
        totalPrice: widget.hotel.totalPrice,
        beds: widget.hotel.beds,
        image: widget.hotel.image,
        nights: widget.hotel.nights,
        savedAt: DateTime.now(),
      );
      await ref.read(saveHotelProvider(savedHotel).future);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch if this hotel is saved
    final isSavedAsync = ref.watch(isHotelSavedProvider(widget.hotel.id));

    return GestureDetector(
      onTap: _navigateToDetails,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name, Rating, and Heart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.hotel.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              widget.hotel.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.hotel.image,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(height: 8),
                      isSavedAsync.when(
                        data: (isSaved) => IconButton(
                          icon: Icon(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            color: isSaved ? Colors.red : Colors.grey,
                          ),
                          onPressed: _toggleSave,
                        ),
                        loading: () => const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, __) => IconButton(
                          icon: const Icon(Icons.favorite_border, color: Colors.grey),
                          onPressed: _toggleSave,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Details: Location, Beds, Nights
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        widget.hotel.city,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bed, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.hotel.beds} bed${widget.hotel.beds > 1 ? 's' : ''}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.nights_stay, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.hotel.nights} night${widget.hotel.nights > 1 ? 's' : ''}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Divider
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 12),

              // Price and Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Price',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${widget.hotel.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        '\$${widget.hotel.pricePerNight.toStringAsFixed(0)}/night',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${widget.hotel.name} - Booking coming soon!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('Book Now'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
