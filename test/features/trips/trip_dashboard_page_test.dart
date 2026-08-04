import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/expenses/domain/entities/expense.dart';
import 'package:travel_super_app/features/expenses/presentation/providers/expense_provider.dart';
import 'package:travel_super_app/features/flights/models/saved_flight.dart';
import 'package:travel_super_app/features/flights/providers/flight_provider.dart';
import 'package:travel_super_app/features/hotels/models/saved_hotel.dart';
import 'package:travel_super_app/features/hotels/providers/hotel_provider.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart'
    as domain;
import 'package:travel_super_app/features/trips/domain/repositories/trip_repository.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_provider.dart';
import 'package:travel_super_app/features/trips/presentation/screens/trip_dashboard_page.dart';
import 'package:travel_super_app/features/weather/models/weather_data.dart';
import 'package:travel_super_app/features/weather/providers/weather_provider.dart';

class _FakeTripRepository implements TripRepository {
  _FakeTripRepository(this.currentTrip);

  domain.Trip currentTrip;
  final List<domain.Trip> updatedTrips = <domain.Trip>[];

  @override
  Future<void> createTrip(domain.Trip trip) async {}

  @override
  Future<void> deleteTrip(String tripId) async {}

  @override
  Future<domain.Trip?> get(String tripId) async {
    if (currentTrip.id == tripId) {
      return currentTrip;
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
    currentTrip = trip;
  }

  @override
  Stream<List<domain.Trip>> watchTrips() {
    return Stream.value(<domain.Trip>[currentTrip]);
  }
}

domain.Trip _makeTrip({
  String id = 'trip-1',
  String? selectedFlightId,
  String? selectedHotelId,
}) {
  return domain.Trip(
    id: id,
    title: 'Paris Getaway',
    destination: 'Paris',
    departureDate: DateTime(2026, 9, 1),
    returnDate: DateTime(2026, 9, 5),
    budget: 1000,
    currency: 'GBP',
    travellers: 2,
    notes: 'Test trip',
    selectedFlightId: selectedFlightId,
    selectedHotelId: selectedHotelId,
    createdAt: DateTime(2026, 7, 1),
    updatedAt: DateTime(2026, 7, 1),
  );
}

SavedFlight _makeSavedFlight({String flightId = 'flight-1'}) {
  return SavedFlight(
    id: 'saved-flight-doc',
    flightId: flightId,
    airline: 'Air France',
    airlineLogo: '',
    flightNumber: 'AF188',
    origin: 'London',
    destination: 'Paris',
    departureAt: '2026-09-01T09:00:00',
    arrivalAt: '2026-09-01T11:00:00',
    duration: 'PT2H',
    stops: 0,
    amount: 210,
    currency: 'GBP',
    cabinClass: 'economy',
    savedAt: DateTime(2026, 7, 26),
  );
}

SavedHotel _makeSavedHotel({String hotelId = 'hotel-1'}) {
  return SavedHotel(
    id: 'saved-hotel-doc',
    hotelId: hotelId,
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
    amenities: const <String>['Free Wi-Fi'],
    freeCancellation: true,
    description: 'Central stay',
    image: 'https://example.com/hotel.jpg',
    nights: 4,
    savedAt: DateTime(2026, 7, 26),
  );
}

Expense _makeExpense({
  required String id,
  required String tripId,
  required double amount,
}) {
  return Expense(
    id: id,
    tripId: tripId,
    title: 'Expense $id',
    amount: amount,
    currency: 'GBP',
    category: 'Other',
    date: DateTime(2026, 9, 2),
    notes: '',
  );
}

void main() {
  const weather = WeatherData(
    city: 'Paris',
    country: 'France',
    tempC: 21,
    tempF: 69.8,
    description: 'Clear',
    iconCode: '113',
    humidity: 50,
    windKph: 8,
    condition: 'clear',
  );

  testWidgets(
    'TripDashboardPage links selected saved flight and persists update',
    (tester) async {
      final initialTrip = _makeTrip(id: 'trip-link-flight');
      final repo = _FakeTripRepository(initialTrip);
      final savedFlight = _makeSavedFlight(flightId: 'flight-link-1');

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            tripRepositoryProvider.overrideWithValue(repo),
            savedFlightsProvider.overrideWith(
              (ref) => Stream.value(<SavedFlight>[savedFlight]),
            ),
            savedHotelsProvider.overrideWith(
              (ref) => Stream.value(const <SavedHotel>[]),
            ),
            tripExpensesProvider(
              'trip-link-flight',
            ).overrideWith((ref) => Stream.value(const <Expense>[])),
            weatherProvider('Paris').overrideWith((ref) async => weather),
          ],
          child: MaterialApp(home: TripDashboardPage(trip: initialTrip)),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Link Flight'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Air France AF188'));
      await tester.pumpAndSettle();

      expect(repo.updatedTrips.length, 1);
      expect(repo.updatedTrips.single.selectedFlightId, 'flight-link-1');
    },
  );

  testWidgets('TripDashboardPage asks confirmation before unlinking hotel', (
    tester,
  ) async {
    final initialTrip = _makeTrip(
      id: 'trip-unlink-hotel',
      selectedHotelId: 'hotel-linked-1',
    );
    final repo = _FakeTripRepository(initialTrip);
    final savedHotel = _makeSavedHotel(hotelId: 'hotel-linked-1');

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          tripRepositoryProvider.overrideWithValue(repo),
          savedFlightsProvider.overrideWith(
            (ref) => Stream.value(const <SavedFlight>[]),
          ),
          savedHotelsProvider.overrideWith(
            (ref) => Stream.value(<SavedHotel>[savedHotel]),
          ),
          tripExpensesProvider(
            'trip-unlink-hotel',
          ).overrideWith((ref) => Stream.value(const <Expense>[])),
          weatherProvider('Paris').overrideWith((ref) async => weather),
        ],
        child: MaterialApp(home: TripDashboardPage(trip: initialTrip)),
      ),
    );

    await tester.pumpAndSettle();

    final unlinkButton = find.widgetWithText(OutlinedButton, 'Unlink');
    final firstUnlinkButton = tester.widget<OutlinedButton>(unlinkButton);
    firstUnlinkButton.onPressed!.call();
    await tester.pumpAndSettle();

    expect(find.text('Unlink hotel?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repo.updatedTrips, isEmpty);

    final secondUnlinkButton = tester.widget<OutlinedButton>(unlinkButton);
    secondUnlinkButton.onPressed!.call();
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Unlink'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.updatedTrips.length, 1);
    expect(repo.updatedTrips.single.selectedHotelId, isNull);
  });

  testWidgets(
    'TripDashboardPage shows view-details actions for linked flight and hotel',
    (tester) async {
      final initialTrip = _makeTrip(
        id: 'trip-view-details',
        selectedFlightId: 'flight-linked-2',
        selectedHotelId: 'hotel-linked-2',
      );
      final repo = _FakeTripRepository(initialTrip);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            tripRepositoryProvider.overrideWithValue(repo),
            savedFlightsProvider.overrideWith(
              (ref) => Stream.value(<SavedFlight>[
                _makeSavedFlight(flightId: 'flight-linked-2'),
              ]),
            ),
            savedHotelsProvider.overrideWith(
              (ref) => Stream.value(<SavedHotel>[
                _makeSavedHotel(hotelId: 'hotel-linked-2'),
              ]),
            ),
            tripExpensesProvider(
              'trip-view-details',
            ).overrideWith((ref) => Stream.value(const <Expense>[])),
            weatherProvider('Paris').overrideWith((ref) async => weather),
          ],
          child: MaterialApp(home: TripDashboardPage(trip: initialTrip)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('View Details'), findsNWidgets(2));
    },
  );

  testWidgets(
    'TripDashboardPage displays linked flight, hotel, and calculated budget values',
    (tester) async {
      final initialTrip = _makeTrip(
        id: 'trip-budget-check',
        selectedFlightId: 'flight-budget-1',
        selectedHotelId: 'hotel-budget-1',
      );
      final repo = _FakeTripRepository(initialTrip);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            tripRepositoryProvider.overrideWithValue(repo),
            savedFlightsProvider.overrideWith(
              (ref) => Stream.value(<SavedFlight>[
                _makeSavedFlight(flightId: 'flight-budget-1'),
              ]),
            ),
            savedHotelsProvider.overrideWith(
              (ref) => Stream.value(<SavedHotel>[
                _makeSavedHotel(hotelId: 'hotel-budget-1'),
              ]),
            ),
            tripExpensesProvider('trip-budget-check').overrideWith(
              (ref) => Stream.value(<Expense>[
                _makeExpense(
                  id: 'expense-1',
                  tripId: 'trip-budget-check',
                  amount: 420,
                ),
                _makeExpense(
                  id: 'expense-2',
                  tripId: 'trip-budget-check',
                  amount: 80,
                ),
              ]),
            ),
            weatherProvider('Paris').overrideWith((ref) async => weather),
          ],
          child: MaterialApp(home: TripDashboardPage(trip: initialTrip)),
        ),
      );

      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.text('Trip Budget: GBP 1000.00'),
        find.byType(ListView),
        const Offset(0, -200),
      );

      expect(find.textContaining('Air France AF188'), findsOneWidget);
      expect(find.textContaining('Rating: 4.6'), findsOneWidget);
      expect(find.text('Trip Budget: GBP 1000.00'), findsOneWidget);
      expect(find.text('Spent: GBP 500.00'), findsOneWidget);
      expect(find.text('Remaining: GBP 500.00'), findsOneWidget);
    },
  );

  testWidgets('TripDashboardPage weather follows selected trip destination', (
    tester,
  ) async {
    final parisTrip = _makeTrip(id: 'trip-weather-paris');
    final londonTrip = parisTrip.copyWith(
      id: 'trip-weather-london',
      destination: 'London',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          tripRepositoryProvider.overrideWithValue(
            _FakeTripRepository(parisTrip),
          ),
          savedFlightsProvider.overrideWith(
            (ref) => Stream.value(const <SavedFlight>[]),
          ),
          savedHotelsProvider.overrideWith(
            (ref) => Stream.value(const <SavedHotel>[]),
          ),
          tripExpensesProvider(
            'trip-weather-paris',
          ).overrideWith((ref) => Stream.value(const <Expense>[])),
          tripExpensesProvider(
            'trip-weather-london',
          ).overrideWith((ref) => Stream.value(const <Expense>[])),
          weatherProvider('Paris').overrideWith((ref) async => weather),
          weatherProvider('London').overrideWith(
            (ref) async => const WeatherData(
              city: 'London',
              country: 'UK',
              tempC: 14,
              tempF: 57.2,
              description: 'Cloudy',
              iconCode: '116',
              humidity: 65,
              windKph: 12,
              condition: 'cloud',
            ),
          ),
        ],
        child: MaterialApp(home: TripDashboardPage(trip: parisTrip)),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('21°C • Clear'), findsOneWidget);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          tripRepositoryProvider.overrideWithValue(
            _FakeTripRepository(londonTrip),
          ),
          savedFlightsProvider.overrideWith(
            (ref) => Stream.value(const <SavedFlight>[]),
          ),
          savedHotelsProvider.overrideWith(
            (ref) => Stream.value(const <SavedHotel>[]),
          ),
          tripExpensesProvider(
            'trip-weather-paris',
          ).overrideWith((ref) => Stream.value(const <Expense>[])),
          tripExpensesProvider(
            'trip-weather-london',
          ).overrideWith((ref) => Stream.value(const <Expense>[])),
          weatherProvider('Paris').overrideWith((ref) async => weather),
          weatherProvider('London').overrideWith(
            (ref) async => const WeatherData(
              city: 'London',
              country: 'UK',
              tempC: 14,
              tempF: 57.2,
              description: 'Cloudy',
              iconCode: '116',
              humidity: 65,
              windKph: 12,
              condition: 'cloud',
            ),
          ),
        ],
        child: MaterialApp(home: TripDashboardPage(trip: londonTrip)),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('14°C • Cloudy'), findsOneWidget);
  });

  testWidgets('TripDashboardPage cards handle empty linked data gracefully', (
    tester,
  ) async {
    final initialTrip = _makeTrip(id: 'trip-empty-state');

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          tripRepositoryProvider.overrideWithValue(
            _FakeTripRepository(initialTrip),
          ),
          savedFlightsProvider.overrideWith(
            (ref) => Stream.value(const <SavedFlight>[]),
          ),
          savedHotelsProvider.overrideWith(
            (ref) => Stream.value(const <SavedHotel>[]),
          ),
          tripExpensesProvider(
            'trip-empty-state',
          ).overrideWith((ref) => Stream.value(const <Expense>[])),
          weatherProvider('Paris').overrideWith((ref) async => weather),
        ],
        child: MaterialApp(home: TripDashboardPage(trip: initialTrip)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No flight added yet.'), findsOneWidget);
    expect(find.text('No hotel linked yet. Tap to add one.'), findsOneWidget);
  });
}
