import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../models/hotel.dart';
import '../models/saved_hotel.dart';
import '../providers/hotel_provider.dart';

class HotelCard extends ConsumerStatefulWidget {
  const HotelCard({
    super.key,
    required this.hotel,
  });

  final Hotel hotel;

  @override
  ConsumerState<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends ConsumerState<HotelCard> {
  void _navigateToDetails() {
    context.pushHotelDetails(widget.hotel);
  }

  Future<void> _toggleSave() async {
    final isSaved = await ref.read(isHotelSavedProvider(widget.hotel.id).future);

    if (isSaved) {
      final saveId = await ref.read(getSavedHotelIdProvider(widget.hotel.id).future);
      if (saveId != null) {
        await ref.read(removeSavedHotelProvider(saveId).future);
      }
      return;
    }

    final savedHotel = SavedHotel(
      id: '',
      hotelId: widget.hotel.id,
      name: widget.hotel.name,
      city: widget.hotel.city,
      country: widget.hotel.country,
      address: widget.hotel.address,
      currency: widget.hotel.currency,
      rating: widget.hotel.rating,
      pricePerNight: widget.hotel.price,
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

  @override
  Widget build(BuildContext context) {
    final isSavedAsync = ref.watch(isHotelSavedProvider(widget.hotel.id));
    final displayAddress = widget.hotel.address.isEmpty
        ? widget.hotel.city
        : widget.hotel.address;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: EdgeInsets.zero,
      onTap: _navigateToDetails,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              widget.hotel.image,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  height: 220,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(
                      Icons.hotel,
                      size: 70,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.hotel.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          widget.hotel.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  displayAddress,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: widget.hotel.amenities
                      .take(3)
                      .map(
                        (amenity) => Chip(
                          label: Text(amenity),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                Text(
                  '${widget.hotel.currency} ${widget.hotel.price.toStringAsFixed(0)} / night',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: isSavedAsync.when(
                        data: (isSaved) => AppSecondaryButton(
                          onPressed: _toggleSave,
                          icon: isSaved ? Icons.favorite : Icons.favorite_border,
                          label: 'Save',
                        ),
                        loading: () => OutlinedButton.icon(
                          onPressed: null,
                          icon: const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          label: const Text('Save'),
                        ),
                        error: (_, __) => AppSecondaryButton(
                          onPressed: _toggleSave,
                          icon: Icons.favorite_border,
                          label: 'Save',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppPrimaryButton(
                        onPressed: _navigateToDetails,
                        icon: Icons.calendar_month,
                        label: 'Book Now',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
