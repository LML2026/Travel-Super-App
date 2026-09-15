import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/profile/profile_page.dart';

void main() {
  testWidgets('Delete account dialog cancel dismisses without framework errors',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog<String?>(
                  context: context,
                  builder: (_) => const DeleteAccountConfirmationDialog(
                    hasPasswordProvider: true,
                  ),
                );
              },
              child: const Text('Open dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Delete account?'), findsOneWidget);
    expect(find.text('Current password'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Delete account?'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
