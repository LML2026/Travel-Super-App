import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/trips/presentation/screens/create_trip_page.dart';

void main() {
  testWidgets('renders the create trip form', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: CreateTripPage())),
    );

    expect(find.text('Create Trip'), findsOneWidget);
    expect(find.text('Destination'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('Travellers'), findsOneWidget);
    expect(find.text('Create Trip'), findsWidgets);
  });
}
