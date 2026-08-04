import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/nearby/presentation/nearby_essentials_page.dart';

void main() {
  testWidgets('nearby essentials page renders hub services and state foundations',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NearbyEssentialsPage(),
      ),
    );

    expect(find.text('Nearby Essentials'), findsWidgets);
    expect(find.text('Toilets'), findsOneWidget);
    expect(find.text('ATMs'), findsOneWidget);
    expect(find.text('Pharmacies'), findsOneWidget);
    expect(find.text('Hospitals'), findsOneWidget);
    expect(find.text('Restaurants'), findsOneWidget);
    expect(find.text('Cafes'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('No nearby results yet'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('No nearby results yet'), findsOneWidget);
    expect(find.text('Nearby Essentials unavailable'), findsOneWidget);
  });

  testWidgets('selecting a service updates filter preview content',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NearbyEssentialsPage(),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Pharmacies'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    await tester.tap(find.text('Pharmacies'));
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('Pharmacies filters'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('Pharmacies filters'), findsOneWidget);
    expect(find.text('Within 1 km'), findsWidgets);
  });
}