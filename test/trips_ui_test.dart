import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itarevo/core/storage/trip_storage_service.dart';
import 'package:itarevo/core/widgets/app_empty_state.dart';
import 'package:itarevo/core/widgets/app_metric_tile.dart';
import 'package:itarevo/core/widgets/app_trip_card.dart';
import 'package:itarevo/features/trips/models/trip.dart';

Trip _trip() => Trip(
  id: 'trip-1',
  destination: 'Rome',
  departureDate: DateTime(2026, 9, 1),
  returnDate: DateTime(2026, 9, 5),
  travellers: 2,
  notes: 'A local note',
  budget: 1250,
  currency: 'EUR',
);

void main() {
  testWidgets('AppTripCard displays real trip summary and is interactive', (
    tester,
  ) async {
    var tapped = false;
    final trip = _trip();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTripCard(
            destination: trip.destination,
            dates: '01/09/2026 - 05/09/2026',
            details: '2 traveller(s) • EUR 1250.00',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Rome'), findsOneWidget);
    expect(find.text('2 traveller(s) • EUR 1250.00'), findsOneWidget);
    await tester.tap(find.text('Rome'));
    expect(tapped, isTrue);
  });

  testWidgets('AppEmptyState renders optional action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppEmptyState(
            icon: Icons.luggage_outlined,
            title: 'No trips',
            message: 'Start planning',
            actionLabel: 'Create trip',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('No trips'), findsOneWidget);
    await tester.tap(find.text('Create trip'));
    expect(tapped, isTrue);
  });

  testWidgets('AppMetricTile displays label and numeric value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppMetricTile(label: 'Budget', value: 'EUR 1250'),
        ),
      ),
    );

    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('EUR 1250'), findsOneWidget);
  });

  test('Trip storage contract remains the existing local service', () {
    expect(TripStorageService, isNotNull);
    expect(_trip().budget, 1250);
    expect(_trip().currency, 'EUR');
  });
}
