import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_repository.dart';
import 'package:travel_super_app/features/trips/presentation/screens/create_trip_page.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_provider.dart';

class _FailingRepo extends TripRepository {
  @override
  Future<void> createTrip(Trip trip) async {
    throw Exception('Firebase unavailable at https://example.invalid');
  }

  @override
  Future<void> updateTrip(Trip trip) async {}

  @override
  Future<void> deleteTrip(String tripId) async {}

  @override
  Stream<List<Trip>> watchTrips() => const Stream.empty();

  @override
  Future<Trip?> get(String tripId) async => null;

  @override
  Future<List<Trip>> getAll() async => const [];
}

void main() {
  testWidgets('renders the create trip form', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CreateTripPage(),
        ),
      ),
    );

    expect(find.text('Create Trip'), findsWidgets);
    expect(find.text('Destination'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('Travellers'), findsOneWidget);
    expect(find.text('Create Trip'), findsWidgets);
  });

  testWidgets('failed create stays on form with values and safe error',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripRepositoryProvider.overrideWithValue(_FailingRepo()),
        ],
        child: MaterialApp(
          home: CreateTripPage(
            initialDepartureDate: DateTime(2026, 9, 15),
            initialReturnDate: DateTime(2026, 9, 18),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Paris');
    await tester.enterText(find.byType(TextFormField).at(1), '1500');
    final submitButton = find.byType(ElevatedButton, skipOffstage: false);
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pump();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.byType(CreateTripPage), findsOneWidget);
    expect(
      tester.widget<TextFormField>(
              find.byType(TextFormField, skipOffstage: false).at(0))
          .controller!
          .text,
      'Paris',
    );
    expect(
      tester.widget<TextFormField>(
              find.byType(TextFormField, skipOffstage: false).at(1))
          .controller!
          .text,
      '1500',
    );
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    final message = (snackBar.content as Text).data!;
    expect(message, isNot(contains('example.invalid')));
    expect(message, isNot(contains('Firebase unavailable')));
  });
}
