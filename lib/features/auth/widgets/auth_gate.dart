import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/auth/auth_service_scope.dart';
import '../../../core/auth/auth_state.dart';
import '../screens/auth_screen.dart';

class AuthGate extends StatefulWidget {
  final AuthService service;
  final Widget authenticatedChild;

  const AuthGate({
    super.key,
    required this.service,
    required this.authenticatedChild,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late AuthState _state = const AuthState.loading();
  StreamSubscription<AuthState>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.service.authStateChanges.listen(
      _handleState,
      onError: (_, _) =>
          _handleState(const AuthState.unavailable('authUnavailable')),
    );
  }

  void _handleState(AuthState state) {
    if (!mounted) return;
    setState(() => _state = state);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    switch (_state.status) {
      case AuthStateStatus.loading:
        child = const _AuthLoadingScreen();
      case AuthStateStatus.signedOut:
        child = AuthScreen(service: widget.service);
      case AuthStateStatus.signedIn:
        child = widget.authenticatedChild;
      case AuthStateStatus.unavailable:
        child = AuthScreen(service: widget.service, unavailable: true);
    }

    return AuthServiceScope(service: widget.service, child: child);
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
