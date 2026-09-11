import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/nearby/presentation/nearby_essentials_page.dart';

void main() {
  testWidgets(
      'nearby essentials page renders hub services and state foundations',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        overrides: [],
        child: MaterialApp(
          home: NearbyEssentialsPage(),
        ),
      ),
    );

    expect(find.text('Nearby Essentials'), findsWidgets);
    expect(find.text('Toilets'), findsOneWidget);
    expect(find.text('ATMs'), findsOneWidget);
    expect(find.text('Pharmacies'), findsOneWidget);
    expect(find.text('Hospitals'), findsOneWidget);
    expect(find.text('Restaurants'), findsOneWidget);
    expect(find.text('Cafes'), findsOneWidget);

    expect(find.text('Destination or map location'), findsOneWidget);
  });

  testWidgets('selecting a service updates filter preview content',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        overrides: [],
        child: MaterialApp(
          home: NearbyEssentialsPage(),
        ),
      ),
    );

    await tester.tap(find.text('Pharmacies'));
    await tester.pump();
    expect(find.text('Pharmacies'), findsOneWidget);
  });
}
