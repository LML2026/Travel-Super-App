import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/transport/presentation/screens/transport_hub_page.dart';

void main() {
  testWidgets('shows supported transport paths and honest unavailable states',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: TransportHubPage()),
    );

    expect(find.text('Taxi'), findsOneWidget);
    expect(find.text('Ride Sharing'), findsOneWidget);
    expect(find.text('Airport Transfer'), findsOneWidget);
    expect(
      find.text('Plan and save estimated rides to your trips'),
      findsOneWidget,
    );
    expect(find.text('Plan an airport ride with the existing taxi flow'),
        findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Walking'),
      find.byType(ListView),
      const Offset(0, -400),
    );
    expect(find.text('Walking'), findsOneWidget);
    expect(find.text('Open walking routes in Maps'), findsOneWidget);
    expect(find.text('Not available in this release'), findsWidgets);
    expect(find.textContaining('coming soon'), findsNothing);
  });
}
