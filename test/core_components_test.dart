import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itarevo/core/widgets/app_button.dart';
import 'package:itarevo/core/widgets/app_card.dart';
import 'package:itarevo/core/widgets/app_text_field.dart';

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('AppButton supports primary, secondary, and tertiary variants', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Column(
          children: [
            AppButton(label: 'Primary', onPressed: () {}),
            AppButton(
              label: 'Secondary',
              variant: AppButtonVariant.secondary,
              onPressed: () {},
            ),
            AppButton(
              label: 'Tertiary',
              variant: AppButtonVariant.tertiary,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    expect(find.byType(FilledButton), findsNWidgets(2));
    expect(find.byType(TextButton), findsOneWidget);
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Secondary'), findsOneWidget);
    expect(find.text('Tertiary'), findsOneWidget);
  });

  testWidgets(
    'AppButton loading state disables interaction and shows progress',
    (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _app(
          AppButton(
            label: 'Save',
            isLoading: true,
            fullWidth: true,
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      expect(tapped, isFalse);
    },
  );

  testWidgets(
    'AppTextField preserves validator, obscuring, and suffix action',
    (tester) async {
      final controller = TextEditingController();
      var suffixTapped = false;
      await tester.pumpWidget(
        _app(
          Form(
            child: AppTextField(
              controller: controller,
              label: 'Password',
              obscureText: true,
              suffixIcon: IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () => suffixTapped = true,
              ),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isTrue,
      );
      await tester.tap(find.byIcon(Icons.visibility));
      expect(suffixTapped, isTrue);
    },
  );

  testWidgets('AppCard builds a token-backed reusable surface', (tester) async {
    await tester.pumpWidget(_app(const AppCard(child: Text('Card content'))));

    expect(find.byType(AppCard), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
    expect(find.text('Card content'), findsOneWidget);
  });
}
