import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../models/hotel.dart';
import '../models/saved_hotel.dart';
import '../providers/hotel_provider.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

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
  String? get _sourceLabel {
    switch (widget.hotel.dataSource) {
      case HotelDataSource.amadeusTest:
        return 'Test data';
      case HotelDataSource.backend:
        return null;
      case HotelDataSource.duffelStays:
        return 'Duffel Stays data';
      case HotelDataSource.demo:
        return 'Demo hotel data';
    }
  }

  void _navigateToDetails() {
    context.pushHotelDetails(widget.hotel);
  }

  Future<void> _toggleSave() async {
    final isSaved =
        await ref.read(isHotelSavedProvider(widget.hotel.id).future);

    if (isSaved) {
      final saveId =
          await ref.read(getSavedHotelIdProvider(widget.hotel.id).future);
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
    final displayAddress =
        widget.hotel.address.isEmpty ? widget.hotel.city : widget.hotel.address;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: EdgeInsets.zero,
      onTap: _navigateToDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.card),
            child: Image.network(
              widget.hotel.image,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  height: 220,
                  color: AppColors.navy50,
                  child: const Center(
                    child: Icon(
                      Icons.hotel,
                      size: 70,
                      color: AppColors.navy600,
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
                if (_sourceLabel case final label?) ...[
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.hotel.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.champagne,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          widget.hotel.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  displayAddress,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
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
                  style: AppTextStyles.price,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: isSavedAsync.when(
                        data: (isSaved) => AppSecondaryButton(
                          onPressed: _toggleSave,
                          icon:
                              isSaved ? Icons.favorite : Icons.favorite_border,
                          label: context.ui('save'),
                        ),
                        loading: () => OutlinedButton.icon(
                          onPressed: null,
                          icon: const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          label: Text(context.ui('save')),
                        ),
                        error: (_, __) => AppSecondaryButton(
                          onPressed: _toggleSave,
                          icon: Icons.favorite_border,
                          label: context.ui('save'),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppPrimaryButton(
                        onPressed: _navigateToDetails,
                        icon: Icons.info_outline,
                        label: context.ui('viewDetails'),
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
