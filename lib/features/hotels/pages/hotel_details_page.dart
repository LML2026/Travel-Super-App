import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../trips/presentation/providers/trip_provider.dart';
import '../../trips/presentation/providers/trip_booking_link_provider.dart';
import '../../trips/domain/entities/trip.dart';
import '../../weather/providers/weather_provider.dart';
import '../models/hotel.dart';
import '../models/saved_hotel.dart';
import '../providers/hotel_experience_provider.dart';
import '../providers/hotel_provider.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class HotelDetailsPage extends ConsumerWidget {
  const HotelDetailsPage({
    super.key,
    required this.hotel,
  });

  final Hotel hotel;

  Future<void> _addToTrip(BuildContext context, WidgetRef ref) async {
    final trips = await ref.read(tripsProvider.future);
    if (trips.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(context.ui('createTripBeforeLinkingHotel'))),
        );
      }
      return;
    }
    final trip = await showModalBottomSheet<Trip>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: trips
              .map((trip) => ListTile(
                    title: Text(trip.title),
                    subtitle: Text(trip.destination),
                    onTap: () => Navigator.pop(sheetContext, trip),
                  ))
              .toList(growable: false),
        ),
      ),
    );
    if (trip == null) return;
    final link = await ref.read(tripBookingLinkActionsProvider).linkHotel(
          trip: trip,
          hotel: hotel,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            link.isSuccess
                ? link.wasAlreadyLinked
                    ? 'This hotel is already linked to ${trip.title}.'
                    : 'Hotel added to ${trip.title}.'
                : 'We could not link this hotel. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSavedAsync = ref.watch(isHotelSavedProvider(hotel.id));
    final weatherAsync = ref.watch(weatherProvider(hotel.city));
    final nearbyAsync = ref.watch(nearbyBundleProvider(hotel.city));
    final targetCurrency = _targetCurrencyForCountry(hotel.country);
    final currencyAsync = ref.watch(currencyRateProvider(targetCurrency));
    final experienceService = ref.read(hotelExperienceServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.ui('hotelDetails')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroCard(hotel: hotel),
            const SizedBox(height: AppSpacing.lg),
            _SectionCard(
              title: 'Description',
              child: Text(hotel.description),
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              title: 'Room & Facilities',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IconLine(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: hotel.address,
                  ),
                  _IconLine(
                    icon: Icons.king_bed_outlined,
                    label: 'Room Type',
                    value: hotel.roomType,
                  ),
                  _IconLine(
                    icon: Icons.bed_outlined,
                    label: 'Stay',
                    value:
                        '${hotel.beds} bed${hotel.beds > 1 ? 's' : ''}, ${hotel.nights} night${hotel.nights > 1 ? 's' : ''}',
                  ),
                  _IconLine(
                    icon: Icons.payments_outlined,
                    label: 'Price',
                    value: '£${hotel.pricePerNight.toStringAsFixed(0)} / night',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      ...hotel.amenities.map((a) => _AmenityPill(label: a)),
                      if (hotel.freeCancellation)
                        const _AmenityPill(label: 'Free Cancellation'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              title: 'Interactive Map',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: Image.network(
                          experienceService.staticMapUrl(
                            latitude: hotel.latitude,
                            longitude: hotel.longitude,
                          ),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.navy50,
                            alignment: Alignment.center,
                            child: Text(context.ui('mapUnavailable')),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${hotel.latitude.toStringAsFixed(4)}, ${hotel.longitude.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              title: 'Nearby Attractions, Restaurants & Transport',
              child: nearbyAsync.when(
                loading: () => const LinearProgressIndicator(minHeight: 6),
                error: (_, __) =>
                    Text(context.ui('nearbyPlacesUnavailable')),
                data: (nearby) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NearbyList(
                      title: 'Attractions',
                      icon: Icons.place_outlined,
                      entries: nearby.attractions
                          .map((p) =>
                              '${p.name} (${p.distanceKm.toStringAsFixed(1)} km)')
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _NearbyList(
                      title: 'Restaurants',
                      icon: Icons.restaurant_outlined,
                      entries: nearby.restaurants
                          .map((p) =>
                              '${p.name} (${p.distanceKm.toStringAsFixed(1)} km)')
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _NearbyList(
                      title: 'Transport',
                      icon: Icons.directions_transit_outlined,
                      entries: nearby.transport
                          .map((p) =>
                              '${p.name} (${p.distanceKm.toStringAsFixed(1)} km)')
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              title: 'Live Weather',
              child: weatherAsync.when(
                loading: () => const LinearProgressIndicator(minHeight: 6),
                error: (_, __) =>
                    Text(context.ui('weatherUnavailableNow')),
                data: (weather) => Row(
                  children: [
                    Text(
                      weather.emoji,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        '${weather.city}, ${weather.country} | ${weather.tempC.toStringAsFixed(0)}°C | ${weather.description}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              title: 'Currency Conversion',
              child: currencyAsync.when(
                loading: () => const LinearProgressIndicator(minHeight: 6),
                error: (_, __) =>
                    Text(context.ui('currencyConversionUnavailable')),
                data: (rate) => Text(
                  '1 ${rate.base} = ${rate.rate.toStringAsFixed(2)} ${rate.target}\n'
                  'Estimated nightly price: ${(hotel.pricePerNight * rate.rate).toStringAsFixed(0)} ${rate.target}',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              title: 'AI Travel Recommendations',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _aiRecommendations(hotel)
                    .map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• '),
                            Expanded(child: Text(tip)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: isSavedAsync.when(
                    data: (isSaved) => OutlinedButton.icon(
                      onPressed: () async {
                        if (isSaved) {
                          final saveId = await ref
                              .read(getSavedHotelIdProvider(hotel.id).future);
                          if (saveId != null) {
                            await ref
                                .read(removeSavedHotelProvider(saveId).future);
                          }
                          return;
                        }

                        final savedHotel = SavedHotel(
                          id: '',
                          hotelId: hotel.id,
                          name: hotel.name,
                          city: hotel.city,
                          country: hotel.country,
                          address: hotel.address,
                          currency: hotel.currency,
                          rating: hotel.rating,
                          pricePerNight: hotel.pricePerNight,
                          totalPrice: hotel.totalPrice,
                          beds: hotel.beds,
                          roomType: hotel.roomType,
                          amenities: hotel.amenities,
                          freeCancellation: hotel.freeCancellation,
                          description: hotel.description,
                          image: hotel.image,
                          nights: hotel.nights,
                          savedAt: DateTime.now(),
                        );

                        await ref.read(saveHotelProvider(savedHotel).future);
                      },
                      icon: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? AppColors.error : null,
                      ),
                      label: Text(isSaved ? 'Saved' : 'Save Hotel'),
                    ),
                    loading: () => const LinearProgressIndicator(minHeight: 6),
                    error: (_, __) => Text(context.ui('saveUnavailable')),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _addToTrip(context, ref),
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: Text(context.ui('addToTrip')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static List<String> _aiRecommendations(Hotel hotel) {
    return [
      'Arrive before 17:00 to check in smoothly and settle in before evening traffic.',
      'Use transport passes near ${hotel.address} for lower daily travel cost.',
      'Reserve dining spots within 1-2 km for easier evening plans after sightseeing.',
      'For ${hotel.roomType.toLowerCase()}, booking now is typically better than same-day pricing.',
    ];
  }

  static String _targetCurrencyForCountry(String country) {
    switch (country.toLowerCase()) {
      case 'france':
      case 'spain':
        return 'EUR';
      case 'united states':
        return 'USD';
      case 'japan':
        return 'JPY';
      default:
        return 'EUR';
    }
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.hotel});

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.card),
        gradient: LinearGradient(
          colors: [AppColors.navy50, AppColors.warmWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    color: AppColors.warmWhite,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    hotel.imageGallery[index],
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemCount: hotel.imageGallery.length,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  hotel.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const Icon(Icons.star_rounded, color: AppColors.champagne),
              const SizedBox(width: AppSpacing.xs),
              Text(
                hotel.rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(hotel.address),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '£${hotel.pricePerNight.toStringAsFixed(0)} / night',
            style: AppTextStyles.price,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.card),
        color: AppColors.warmWhite,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.navy600),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text('$label: $value'),
          ),
        ],
      ),
    );
  }
}

class _AmenityPill extends StatelessWidget {
  const _AmenityPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.navy50,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

class _NearbyList extends StatelessWidget {
  const _NearbyList({
    required this.title,
    required this.icon,
    required this.entries,
  });

  final String title;
  final IconData icon;
  final List<String> entries;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.navy600),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text('$title: ${entries.join(', ')}'),
        ),
      ],
    );
  }
}
