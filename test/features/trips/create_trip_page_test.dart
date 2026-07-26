import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/trips/models/trip.dart';
import 'package:travel_super_app/features/trips/presentation/screens/create_trip_page.dart';

void main() {
  Widget buildTestApp() {
    return const ProviderScope(
      child: MaterialApp(
        home: CreateTripPage(),
      ),
    );
  }

  testWidgets('shows destination required validation', (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('Create Trip').last);
    await tester.pump();

    expect(find.text('Destination must not be empty.'), findsOneWidget);
  });

  testWidgets('shows date required validation when destination is filled', (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.enterText(find.byType(TextField).at(0), 'Paris');
    await tester.tap(find.text('Create Trip').last);
    await tester.pump();

    expect(find.text('Please select departure and return dates.'), findsOneWidget);
  });

  testWidgets('shows budget validation after dates are selected', (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.enterText(find.byType(TextField).at(0), 'Paris');

    await tester.tap(find.text('Select Date').at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select Date').at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(1), '0');
    await tester.tap(find.text('Create Trip').last);
    await tester.pump();

    expect(find.text('Budget must be greater than zero.'), findsOneWidget);
  });

  testWidgets('edit mode pre-fills trip fields', (tester) async {
    final initialTrip = Trip(
      id: 'trip-1',
      destination: 'Rome',
      startDate: DateTime(2026, 10, 5),
      endDate: DateTime(2026, 10, 10),
      budget: 1200,
      currency: 'EUR',
      travellers: 3,
      notes: 'Family trip',
      createdAt: DateTime(2026, 7, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: CreateTripPage(initialTrip: initialTrip),
        ),
      ),
    );

    expect(find.text('Edit Trip'), findsWidgets);
    expect(find.text('Rome'), findsOneWidget);
    expect(find.text('1200'), findsOneWidget);
    expect(find.text('Family trip'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('edit mode shows update action', (tester) async {
    final initialTrip = Trip(
      id: 'trip-2',
      destination: 'Paris',
      startDate: DateTime(2026, 9, 14),
      endDate: DateTime(2026, 9, 18),
      budget: 1500,
      currency: 'GBP',
      travellers: 2,
      notes: 'Anniversary trip',
      createdAt: DateTime(2026, 7, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: CreateTripPage(initialTrip: initialTrip),
        ),
      ),
    );

    expect(find.text('Update Trip'), findsOneWidget);
    expect(find.text('Create Trip'), findsNothing);
  });

  testWidgets('duplicate mode pre-fills fields but keeps create action', (tester) async {
    final initialTrip = Trip(
      id: 'trip-3',
      destination: 'Lisbon',
      startDate: DateTime(2026, 11, 2),
      endDate: DateTime(2026, 11, 6),
      budget: 980,
      currency: 'EUR',
      travellers: 2,
      notes: 'Food-focused itinerary',
      createdAt: DateTime(2026, 7, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: CreateTripPage(
            initialTrip: initialTrip,
            forceCreateMode: true,
          ),
        ),
      ),
    );

    expect(find.text('Duplicate Trip'), findsWidgets);
    expect(find.text('Lisbon (Copy)'), findsOneWidget);
    expect(find.text('980'), findsOneWidget);
    expect(find.text('Food-focused itinerary'), findsOneWidget);
    expect(find.text('Create Trip'), findsOneWidget);
    expect(find.text('Update Trip'), findsNothing);
  });
}
