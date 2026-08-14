import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itarevo/core/auth/auth_service.dart';
import 'package:itarevo/core/auth/auth_state.dart';
import 'package:itarevo/core/auth/auth_user.dart';
import 'package:itarevo/features/auth/screens/auth_screen.dart';
import 'package:itarevo/features/auth/widgets/auth_gate.dart';
import 'package:itarevo/features/trips/models/trip.dart';
import 'package:itarevo/l10n/app_localizations.dart';

class _FakeAuthService implements AuthService {
  final _states = StreamController<AuthState>.broadcast();
  AuthUser? user;
  AuthException? signInError;
  AuthException? createError;
  bool signedOut = false;
  int signInCalls = 0;
  int createCalls = 0;
  String? token;

  @override
  AuthUser? get currentUser => user;

  @override
  Stream<AuthState> get authStateChanges => _states.stream;

  @override
  Future<AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    if (signInError != null) throw signInError!;
    user = const AuthUser(uid: 'signed-in', email: 'user@example.com');
    _states.add(AuthState.signedIn(user!));
    return user!;
  }

  @override
  Future<AuthUser> createAccount({
    required String email,
    required String password,
  }) async {
    createCalls++;
    if (createError != null) throw createError!;
    user = const AuthUser(uid: 'created', email: 'new@example.com');
    _states.add(AuthState.signedIn(user!));
    return user!;
  }

  @override
  Future<void> signOut() async {
    signedOut = true;
    user = null;
    _states.add(const AuthState.signedOut());
  }

  @override
  Future<String?> getIdToken() async => token;

  void emit(AuthState state) => _states.add(state);

  Future<void> close() => _states.close();
}

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocaleControllerTest.locales,
  home: child,
);

class AppLocaleControllerTest {
  static const locales = [Locale('en')];
}

bool _passwordIsObscured(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText).last).obscureText;

void main() {
  testWidgets('auth gate shows loading, signed-out, then app shell', (
    tester,
  ) async {
    final service = _FakeAuthService();
    await tester.pumpWidget(
      _app(
        AuthGate(service: service, authenticatedChild: const Text('APP SHELL')),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    service.emit(const AuthState.signedOut());
    await tester.pump();
    expect(find.text('Sign in'), findsOneWidget);

    service.emit(
      const AuthState.signedIn(AuthUser(uid: 'id', email: 'user@example.com')),
    );
    await tester.pump();
    expect(find.text('APP SHELL'), findsOneWidget);
    await service.close();
  });

  testWidgets('auth gate handles unavailable service safely', (tester) async {
    final service = _FakeAuthService();
    await tester.pumpWidget(
      _app(
        AuthGate(service: service, authenticatedChild: const Text('APP SHELL')),
      ),
    );
    service.emit(const AuthState.unavailable('authUnavailable'));
    await tester.pump();
    expect(
      find.text('Authentication is currently unavailable.'),
      findsOneWidget,
    );
    expect(find.text('APP SHELL'), findsNothing);
    await service.close();
  });

  testWidgets('sign in success calls the abstraction and updates the gate', (
    tester,
  ) async {
    final service = _FakeAuthService();
    await tester.pumpWidget(
      _app(
        AuthGate(service: service, authenticatedChild: const Text('APP SHELL')),
      ),
    );
    service.emit(const AuthState.signedOut());
    await tester.pump();

    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'password');
    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(service.signInCalls, 1);
    expect(find.text('APP SHELL'), findsOneWidget);
    await service.close();
  });

  testWidgets('sign in failure is mapped without exposing provider details', (
    tester,
  ) async {
    final service = _FakeAuthService()
      ..signInError = const AuthException('invalidCredentials');
    await tester.pumpWidget(_app(AuthScreen(service: service)));

    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'password');
    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Email or password is incorrect.'), findsOneWidget);
    expect(find.text('invalidCredentials'), findsNothing);
    await service.close();
  });

  testWidgets('create account and sign out use the abstraction', (
    tester,
  ) async {
    final service = _FakeAuthService();
    await tester.pumpWidget(
      _app(
        AuthGate(service: service, authenticatedChild: const Text('APP SHELL')),
      ),
    );
    service.emit(const AuthState.signedOut());
    await tester.pump();

    await tester.tap(find.text('Need an account? Create one'));
    await tester.enterText(find.byType(TextFormField).first, 'new@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password');
    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(service.createCalls, 1);
    expect(find.text('APP SHELL'), findsOneWidget);
    await service.signOut();
    await tester.pump();
    expect(service.signedOut, isTrue);
    await service.close();
  });

  testWidgets('password visibility toggles in sign-in mode', (tester) async {
    final service = _FakeAuthService();
    await tester.pumpWidget(_app(AuthScreen(service: service)));

    expect(_passwordIsObscured(tester), isTrue);
    expect(find.byIcon(Icons.visibility), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();
    expect(_passwordIsObscured(tester), isFalse);
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(_passwordIsObscured(tester), isTrue);
    await service.close();
  });

  testWidgets('password visibility toggles in create-account mode', (
    tester,
  ) async {
    final service = _FakeAuthService();
    await tester.pumpWidget(_app(AuthScreen(service: service)));

    await tester.tap(find.text('Need an account? Create one'));
    await tester.pump();
    expect(_passwordIsObscured(tester), isTrue);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();
    expect(_passwordIsObscured(tester), isFalse);
    await service.close();
  });

  test(
    'auth operations do not mutate local trip data or expose token access',
    () async {
      final service = _FakeAuthService()..token = 'test-token';
      final trip = Trip(
        id: 'trip',
        destination: 'Rome',
        departureDate: DateTime(2026, 9, 1),
        returnDate: DateTime(2026, 9, 5),
        travellers: 2,
        notes: 'Keep local',
        budget: 1000,
        currency: 'EUR',
      );

      await service.signInWithEmailPassword(
        email: 'user@example.com',
        password: 'password',
      );
      expect(trip.destination, 'Rome');
      expect(trip.notes, 'Keep local');
      expect(trip.budget, 1000);
      expect(trip.currency, 'EUR');
      expect(await service.getIdToken(), 'test-token');
      await service.close();
    },
  );
}
