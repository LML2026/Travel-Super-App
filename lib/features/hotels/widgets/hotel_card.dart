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
        country: widget.hotel.country,
        address: widget.hotel.address,
        rating: widget.hotel.rating,
        pricePerNight: widget.hotel.pricePerNight,
        totalPrice: widget.hotel.totalPrice,
        beds: widget.hotel.beds,
        roomType: widget.hotel.roomType,
        amenities: widget.hotel.amenities,
        freeCancellation: widget.hotel.freeCancellation,
        description: widget.hotel.description,
        image: widget.hotel.image,
        nights: widget.hotel.nights,
        savedAt: DateTime.now(),
      );
      await ref.read(saveHotelProvider(savedHotel).future);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSavedAsync = ref.watch(isHotelSavedProvider(widget.hotel.id));
    final theme = Theme.of(context);
    final displayAddress = widget.hotel.address.isEmpty
      ? (widget.hotel.country.isEmpty
        ? widget.hotel.city
        : '${widget.hotel.city}, ${widget.hotel.country}')
      : widget.hotel.address;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _navigateToDetails,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.image_outlined, size: 18, color: Color(0xFF335C99)),
                    const SizedBox(width: 8),
                    Text(
                      'Hotel Image',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF335C99),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.hotel.image,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.hotel.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        widget.hotel.rating.toStringAsFixed(1),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_pin, size: 16, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      displayAddress,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.king_bed_outlined, size: 16, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.hotel.roomType,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...widget.hotel.amenities
                      .take(3)
                      .map(
                        (amenity) => _HotelTag(
                          label: amenity,
                          icon: _amenityIcon(amenity),
                        ),
                      ),
                  if (widget.hotel.freeCancellation)
                    const _HotelTag(
                      label: 'Free Cancellation',
                      icon: Icons.event_available_outlined,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '£${widget.hotel.pricePerNight.toStringAsFixed(0)} / night',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF1D4E89),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  isSavedAsync.when(
                    data: (isSaved) => OutlinedButton.icon(
                      onPressed: _toggleSave,
                      icon: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? Colors.red : null,
                        size: 18,
                      ),
                      label: const Text('Save'),
                    ),
                    loading: () => const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, __) => OutlinedButton.icon(
                      onPressed: _toggleSave,
                      icon: const Icon(Icons.favorite_border, size: 18),
                      label: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _navigateToDetails,
                      child: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _navigateToDetails,
                      child: const Text('Book Now'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _amenityIcon(String amenity) {
    final normalized = amenity.toLowerCase();

    if (normalized.contains('wifi')) {
      return Icons.wifi_rounded;
    }

    if (normalized.contains('breakfast')) {
      return Icons.free_breakfast_outlined;
    }

    if (normalized.contains('cancellation')) {
      return Icons.event_available_outlined;
    }

    if (normalized.contains('transport')) {
      return Icons.directions_transit_outlined;
    }

    return Icons.check_circle_outline;
  }
}

class _HotelTag extends StatelessWidget {
  const _HotelTag({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFDFE8F4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF335C99)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
