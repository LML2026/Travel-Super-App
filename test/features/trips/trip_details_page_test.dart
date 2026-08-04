import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/flights/models/saved_flight.dart';
import 'package:travel_super_app/features/flights/providers/flight_provider.dart';
import 'package:travel_super_app/features/hotels/models/currency_rate.dart';
import 'package:travel_super_app/features/hotels/models/nearby_bundle.dart';
import 'package:travel_super_app/features/hotels/models/nearby_place.dart';
import 'package:travel_super_app/features/hotels/models/saved_hotel.dart';
import 'package:travel_super_app/features/hotels/providers/hotel_experience_provider.dart';
import 'package:travel_super_app/features/hotels/providers/hotel_provider.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart'
    as domain;
import 'package:travel_super_app/features/trips/domain/repositories/trip_repository.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_provider.dart';
import 'package:travel_super_app/features/trips/presentation/screens/trip_details_page.dart';
import 'package:travel_super_app/features/weather/providers/weather_provider.dart';

class _FakeTripRepository implements TripRepository {
  _FakeTripRepository(this._trips);

  final List<domain.Trip> _trips;
  final List<domain.Trip> updatedTrips = <domain.Trip>[];

  @override
  Future<void> createTrip(domain.Trip trip) async {}

  @override
  Future<void> deleteTrip(String tripId) async {}

  @override
  Future<domain.Trip?> get(String tripId) async {
    for (final trip in _trips) {
      if (trip.id == tripId) {
        return trip;
      }
    }
    return null;
  }

  @override
  Future<List<domain.Trip>> getAll() async {
    return watchTrips().first;
  }

  @override
  Future<void> updateTrip(domain.Trip trip) async {
    updatedTrips.add(trip);
  }

  @override
  Stream<List<domain.Trip>> watchTrips() {
    return const Stream<List<domain.Trip>>.empty();
  }
}

void main() {
  testWidgets(
    'TripDetailsPage shows saved snapshot label when live weather fails',
    (tester) async {
      final trip = domain.Trip(
        id: 'trip-1',
        title: 'Paris Getaway',
        destination: 'Paris',
        startDate: DateTime(2026, 9, 14),
        endDate: DateTime(2026, 9, 18),
        budget: 1250,
        currency: 'GBP',
        selectedFlightId: 'flight-1',
        selectedHotelId: 'hotel-1',
        weatherSnapshot: const {
          'city': 'Paris',
          'country': 'France',
          'tempC': 22,
          'tempF': 71.6,
          'description': 'Sunny',
          'iconCode': '0',
          'humidity': 50,
          'windKph': 12,
          'condition': 'clear',
        },
        weatherSnapshotCapturedAt: DateTime(2026, 7, 26, 10, 30),
        createdAt: DateTime(2026, 7, 26),
      );
      final fakeTripRepository = _FakeTripRepository(<domain.Trip>[trip]);

      final savedFlight = SavedFlight(
        id: 'doc-1',
        flightId: 'flight-1',
        airline: 'British Airways',
        airlineLogo: '',
        flightNumber: 'BA304',
        origin: 'London',
        destination: 'Paris',
        departureAt: '2026-09-14T09:30:00',
        arrivalAt: '2026-09-14T12:15:00',
        duration: 'PT1H45M',
        stops: 0,
        amount: 320,
        currency: 'GBP',
        cabinClass: 'economy',
        savedAt: DateTime(2026, 7, 26),
      );

      final savedHotel = SavedHotel(
        id: 'doc-2',
        hotelId: 'hotel-1',
        name: 'Hilton Paris Opera',
        city: 'Paris',
        country: 'France',
        address: 'Paris, France',
        currency: 'GBP',
        rating: 4.6,
        pricePerNight: 185,
        totalPrice: 740,
        beds: 1,
        roomType: 'Deluxe Room',
        amenities: const ['Free Wi-Fi'],
        freeCancellation: true,
        description: 'Central stay',
        image: 'https://example.com/hotel.jpg',
        nights: 4,
        savedAt: DateTime(2026, 7, 26),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripRepositoryProvider.overrideWithValue(fakeTripRepository),
            savedFlightsProvider.overrideWith(
              (ref) => Stream.value([savedFlight]),
            ),
            savedHotelsProvider.overrideWith(
              (ref) => Stream.value([savedHotel]),
            ),
            weatherProvider(
              'Paris',
            ).overrideWith((ref) async => throw Exception('offline')),
            nearbyBundleProvider('Paris').overrideWith(
              (ref) async => const NearbyBundle(
                city: 'Paris',
                attractions: [
                  NearbyPlace(
                    name: 'Eiffel Tower',
                    distanceKm: 2.1,
                    type: 'attraction',
                  ),
                ],
                restaurants: [],
                transport: [],
              ),
            ),
            currencyRateProvider('EUR').overrideWith(
              (ref) async =>
                  const CurrencyRate(base: 'GBP', target: 'EUR', rate: 1.17),
            ),
          ],
          child: MaterialApp(home: TripDetailsPage(tripId: trip.id)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Trip Dashboard'), findsOneWidget);
      expect(find.text('Paris'), findsOneWidget);
      expect(find.text('14 Sep 2026 -> 18 Sep 2026'), findsOneWidget);
      expect(find.text('GBP 1250.00'), findsOneWidget);
      expect(find.text('Spent GBP 1060.00'), findsOneWidget);
      expect(find.text('Remaining GBP 190.00'), findsOneWidget);

      expect(find.text('Weather unavailable.'), findsOneWidget);
      expect(find.text('BA304'), findsOneWidget);
      expect(find.text('Hilton Paris Opera'), findsOneWidget);
    },
  );

  testWidgets('TripDetailsPage shows fallback when no linked flight', (
    tester,
  ) async {
    final trip = domain.Trip(
      id: 'trip-2',
      title: 'Paris Getaway',
      destination: 'Paris',
      startDate: DateTime(2026, 9, 20),
      endDate: DateTime(2026, 9, 24),
      budget: 980,
      currency: 'GBP',
      selectedHotelId: 'hotel-1',
      createdAt: DateTime(2026, 7, 26),
    );
    final fakeTripRepository = _FakeTripRepository(<domain.Trip>[trip]);

    final savedFlight = SavedFlight(
      id: 'doc-3',
      flightId: 'flight-attach-1',
      airline: 'Air France',
      airlineLogo: '',
      flightNumber: 'AF188',
      origin: 'London',
      destination: 'Paris',
      departureAt: '2026-09-20T09:00:00',
      arrivalAt: '2026-09-20T11:00:00',
      duration: 'PT2H',
      stops: 0,
      amount: 210,
      currency: 'GBP',
      cabinClass: 'economy',
      savedAt: DateTime(2026, 7, 26),
    );

    final savedHotel = SavedHotel(
      id: 'doc-4',
      hotelId: 'hotel-1',
      name: 'Hilton Paris Opera',
      city: 'Paris',
      country: 'France',
      address: 'Paris, France',
      currency: 'GBP',
      rating: 4.6,
      pricePerNight: 185,
      totalPrice: 740,
      beds: 1,
      roomType: 'Deluxe Room',
      amenities: const ['Free Wi-Fi'],
      freeCancellation: true,
      description: 'Central stay',
      image: 'https://example.com/hotel.jpg',
      nights: 4,
      savedAt: DateTime(2026, 7, 26),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripRepositoryProvider.overrideWithValue(fakeTripRepository),
          savedFlightsProvider.overrideWith(
            (ref) => Stream.value([savedFlight]),
          ),
          savedHotelsProvider.overrideWith((ref) => Stream.value([savedHotel])),
          weatherProvider(
            'Paris',
          ).overrideWith((ref) async => throw Exception('offline')),
          nearbyBundleProvider('Paris').overrideWith(
            (ref) async => const NearbyBundle(
              city: 'Paris',
              attractions: [
                NearbyPlace(
                  name: 'Eiffel Tower',
                  distanceKm: 2.1,
                  type: 'attraction',
                ),
              ],
              restaurants: [],
              transport: [],
            ),
          ),
          currencyRateProvider('EUR').overrideWith(
            (ref) async =>
                const CurrencyRate(base: 'GBP', target: 'EUR', rate: 1.17),
          ),
        ],
        child: MaterialApp(home: TripDetailsPage(tripId: trip.id)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No linked flight yet.'), findsOneWidget);
    expect(find.text('Hilton Paris Opera'), findsOneWidget);
  });

  testWidgets('TripDetailsPage shows fallback when no linked hotel', (
    tester,
  ) async {
    final trip = domain.Trip(
      id: 'trip-3',
      title: 'Paris Getaway',
      destination: 'Paris',
      startDate: DateTime(2026, 9, 20),
      endDate: DateTime(2026, 9, 24),
      budget: 980,
      currency: 'GBP',
      selectedFlightId: 'flight-keep-1',
      createdAt: DateTime(2026, 7, 26),
    );
    final fakeTripRepository = _FakeTripRepository(<domain.Trip>[trip]);

    final savedFlight = SavedFlight(
      id: 'doc-5',
      flightId: 'flight-keep-1',
      airline: 'Air France',
      airlineLogo: '',
      flightNumber: 'AF188',
      origin: 'London',
      destination: 'Paris',
      departureAt: '2026-09-20T09:00:00',
      arrivalAt: '2026-09-20T11:00:00',
      duration: 'PT2H',
      stops: 0,
      amount: 210,
      currency: 'GBP',
      cabinClass: 'economy',
      savedAt: DateTime(2026, 7, 26),
    );

    final savedHotel = SavedHotel(
      id: 'doc-6',
      hotelId: 'hotel-attach-1',
      name: 'Le Grand Paris',
      city: 'Paris',
      country: 'France',
      address: '1 Rue de Rivoli, Paris',
      currency: 'GBP',
      rating: 4.8,
      pricePerNight: 220,
      totalPrice: 880,
      beds: 1,
      roomType: 'Suite',
      amenities: const ['Free Wi-Fi'],
      freeCancellation: true,
      description: 'Luxury stay',
      image: 'https://example.com/hotel2.jpg',
      nights: 4,
      savedAt: DateTime(2026, 7, 26),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripRepositoryProvider.overrideWithValue(fakeTripRepository),
          savedFlightsProvider.overrideWith(
            (ref) => Stream.value([savedFlight]),
          ),
          savedHotelsProvider.overrideWith((ref) => Stream.value([savedHotel])),
          weatherProvider(
            'Paris',
          ).overrideWith((ref) async => throw Exception('offline')),
          nearbyBundleProvider('Paris').overrideWith(
            (ref) async => const NearbyBundle(
              city: 'Paris',
              attractions: [
                NearbyPlace(
                  name: 'Eiffel Tower',
                  distanceKm: 2.1,
                  type: 'attraction',
                ),
              ],
              restaurants: [],
              transport: [],
            ),
          ),
          currencyRateProvider('EUR').overrideWith(
            (ref) async =>
                const CurrencyRate(base: 'GBP', target: 'EUR', rate: 1.17),
          ),
        ],
        child: MaterialApp(home: TripDetailsPage(tripId: trip.id)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No linked hotel yet.'), findsOneWidget);
    expect(find.text('AF188'), findsOneWidget);
  });
}
