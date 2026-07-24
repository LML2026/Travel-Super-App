import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/main.dart';

void main() {
  testWidgets('shows the app title', (tester) async {
    await tester.pumpWidget(const TravelSuperApp());

    expect(find.text('TravelSuperApp'), findsOneWidget);
  });
}
