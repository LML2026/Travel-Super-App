import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../models/saved_hotel.dart';
import '../providers/hotel_provider.dart';

class SavedHotelDetailsPage extends ConsumerWidget {
  const SavedHotelDetailsPage({
    super.key,
    required this.hotel,
  });

  final SavedHotel hotel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Hotel Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hotel.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(hotel.address.isEmpty ? '${hotel.city}, ${hotel.country}' : hotel.address),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: AppSpacing.xs),
                      Text(hotel.rating.toStringAsFixed(1)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PriceTag(
                    currency: hotel.currency,
                    amount: hotel.pricePerNight,
                    suffix: '/ night',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stay Details', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  Text('Room: ${hotel.roomType}'),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Beds: ${hotel.beds}'),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Nights: ${hotel.nights}'),
                  const SizedBox(height: AppSpacing.xs),
                  Text(hotel.freeCancellation ? 'Free cancellation available' : 'Cancellation policy restricted'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amenities', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: hotel.amenities.map((amenity) => Chip(label: Text(amenity))).toList(),
                  ),
                ],
              ),
            ),
            if (hotel.description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.md),
                    Text(hotel.description),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Remove',
                    icon: Icons.delete_outline,
                    onPressed: () async {
                      await ref.read(removeSavedHotelProvider(hotel.id).future);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${hotel.name} removed from saved hotels')),
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PrimaryButton(
                    text: 'Book Now',
                    icon: Icons.calendar_month,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Booking ${hotel.name} - Coming soon!')),
                      );
                    },
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
