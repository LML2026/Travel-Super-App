import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/app/app.dart';

void main() {
  testWidgets('app boots with root widget', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TravelSuperApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
