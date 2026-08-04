import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_super_app/features/auth/domain/usecases/register_user.dart';
import 'package:travel_super_app/features/auth/domain/usecases/send_password_reset.dart';
import 'package:travel_super_app/features/auth/domain/usecases/sign_in.dart';
import 'package:travel_super_app/features/auth/forgot_password_page.dart';
import 'package:travel_super_app/features/auth/login_page.dart';
import 'package:travel_super_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_super_app/features/auth/register_page.dart';

class _MockSignIn extends Mock implements SignIn {}

class _MockRegisterUser extends Mock implements RegisterUser {}

class _MockSendPasswordReset extends Mock implements SendPasswordReset {}

void main() {
  testWidgets('Login shows mapped message for invalid credentials', (
    tester,
  ) async {
    final signIn = _MockSignIn();
    when(
      () => signIn.call(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(
      FirebaseAuthException(code: 'wrong-password', message: 'Bad password'),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [signInUseCaseProvider.overrideWithValue(signIn)],
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'abc123');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });

  testWidgets('Register shows mapped message for email already in use', (
    tester,
  ) async {
    final register = _MockRegisterUser();
    when(
      () => register.call(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(
      FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'Already used',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [registerUserUseCaseProvider.overrideWithValue(register)],
        child: const MaterialApp(home: RegisterPage()),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'taken@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'abc123');
    await tester.enterText(find.byType(TextField).at(2), 'abc123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pumpAndSettle();

    expect(
      find.text('An account already exists for this email.'),
      findsOneWidget,
    );
  });

  testWidgets('Forgot password shows mapped message for invalid email', (
    tester,
  ) async {
    final reset = _MockSendPasswordReset();
    when(() => reset.call(email: any(named: 'email'))).thenThrow(
      FirebaseAuthException(code: 'invalid-email', message: 'Invalid'),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sendPasswordResetUseCaseProvider.overrideWithValue(reset)],
        child: const MaterialApp(home: ForgotPasswordPage()),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'bad-email');
    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email address.'), findsOneWidget);
  });
}
