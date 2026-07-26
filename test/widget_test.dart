import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the app title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Travel Super App'),
          ),
        ),
      ),
    );

    expect(find.text('Travel Super App'), findsOneWidget);
  });
}
