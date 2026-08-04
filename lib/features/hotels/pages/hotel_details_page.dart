import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../weather/providers/weather_provider.dart';
import '../models/hotel.dart';
import '../models/saved_hotel.dart';
import '../providers/hotel_experience_provider.dart';
import '../providers/hotel_provider.dart';

class HotelDetailsPage extends ConsumerWidget {
  const HotelDetailsPage({
    super.key,
    required this.hotel,
  });

  final Hotel hotel;

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
        title: const Text('Hotel Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroCard(hotel: hotel),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Description',
              child: Text(hotel.description),
            ),
            const SizedBox(height: 12),
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
                    value: '${hotel.beds} bed${hotel.beds > 1 ? 's' : ''}, ${hotel.nights} night${hotel.nights > 1 ? 's' : ''}',
                  ),
                  _IconLine(
                    icon: Icons.payments_outlined,
                    label: 'Price',
                    value: '£${hotel.pricePerNight.toStringAsFixed(0)} / night',
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...hotel.amenities.map((a) => _AmenityPill(label: a)),
                      if (hotel.freeCancellation)
                        const _AmenityPill(label: 'Free Cancellation'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Interactive Map',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
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
                            color: const Color(0xFFF0F4FA),
                            alignment: Alignment.center,
                            child: const Text('Map unavailable'),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${hotel.latitude.toStringAsFixed(4)}, ${hotel.longitude.toStringAsFixed(4)}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Nearby Attractions, Restaurants & Transport',
              child: nearbyAsync.when(
                loading: () => const LinearProgressIndicator(minHeight: 6),
                error: (_, __) => const Text('Nearby places are unavailable right now.'),
                data: (nearby) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NearbyList(
                      title: 'Attractions',
                      icon: Icons.place_outlined,
                      entries: nearby.attractions.map((p) => '${p.name} (${p.distanceKm.toStringAsFixed(1)} km)').toList(),
                    ),
                    const SizedBox(height: 8),
                    _NearbyList(
                      title: 'Restaurants',
                      icon: Icons.restaurant_outlined,
                      entries: nearby.restaurants.map((p) => '${p.name} (${p.distanceKm.toStringAsFixed(1)} km)').toList(),
                    ),
                    const SizedBox(height: 8),
                    _NearbyList(
                      title: 'Transport',
                      icon: Icons.directions_transit_outlined,
                      entries: nearby.transport.map((p) => '${p.name} (${p.distanceKm.toStringAsFixed(1)} km)').toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Live Weather',
              child: weatherAsync.when(
                loading: () => const LinearProgressIndicator(minHeight: 6),
                error: (_, __) => const Text('Weather is currently unavailable.'),
                data: (weather) => Row(
                  children: [
                    Text(weather.emoji, style: const TextStyle(fontSize: 30)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${weather.city}, ${weather.country} | ${weather.tempC.toStringAsFixed(0)}°C | ${weather.description}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Currency Conversion',
              child: currencyAsync.when(
                loading: () => const LinearProgressIndicator(minHeight: 6),
                error: (_, __) => const Text('Currency conversion unavailable.'),
                data: (rate) => Text(
                  '1 ${rate.base} = ${rate.rate.toStringAsFixed(2)} ${rate.target}\n'
                  'Estimated nightly price: ${(hotel.pricePerNight * rate.rate).toStringAsFixed(0)} ${rate.target}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'AI Travel Recommendations',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _aiRecommendations(hotel)
                    .map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: isSavedAsync.when(
                    data: (isSaved) => OutlinedButton.icon(
                      onPressed: () async {
                        if (isSaved) {
                          final saveId = await ref.read(getSavedHotelIdProvider(hotel.id).future);
                          if (saveId != null) {
                            await ref.read(removeSavedHotelProvider(saveId).future);
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
                        color: isSaved ? Colors.red : null,
                      ),
                      label: Text(isSaved ? 'Saved' : 'Save Hotel'),
                    ),
                    loading: () => const LinearProgressIndicator(minHeight: 6),
                    error: (_, __) => const Text('Save unavailable'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Booking flow for ${hotel.name} will be enabled in the next sprint.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: const Text('Book Now'),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF4FF), Color(0xFFF8FAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFDDE7FB)),
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
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFDCE5F7)),
                  ),
                  child: Text(
                    hotel.imageGallery[index],
                    style: const TextStyle(fontSize: 32),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: hotel.imageGallery.length,
            ),
          ),
          const SizedBox(height: 14),
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
              const Icon(Icons.star_rounded, color: Colors.amber),
              const SizedBox(width: 2),
              Text(
                hotel.rating.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(hotel.address),
          const SizedBox(height: 8),
          Text(
            '£${hotel.pricePerNight.toStringAsFixed(0)} / night',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D4E89),
            ),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8EEF8)),
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
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF3669B3)),
          const SizedBox(width: 8),
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
        color: const Color(0xFFF7FAFF),
        border: Border.all(color: const Color(0xFFDCE7FB)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
        Icon(icon, size: 18, color: const Color(0xFF3669B3)),
        const SizedBox(width: 8),
        Expanded(
          child: Text('$title: ${entries.join(', ')}'),
        ),
      ],
    );
  }
}
