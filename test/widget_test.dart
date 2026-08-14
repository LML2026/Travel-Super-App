import 'package:flutter_test/flutter_test.dart';

import 'package:itarevo/main.dart';

void main() {
  testWidgets('startup gates the app when auth is unavailable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ItarevoApp());
    await tester.pump();

    expect(
      find.text('Authentication is currently unavailable.'),
      findsOneWidget,
    );
    expect(find.text('APP SHELL'), findsNothing);
  });
}
