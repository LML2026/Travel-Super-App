import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import 'route_groups/auth_routes.dart';
import 'route_groups/core_routes.dart';
import 'route_groups/flight_routes.dart';
import 'route_groups/hotel_routes.dart';
import 'route_groups/trip_routes.dart';

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable()
      : _subscription =
            FirebaseAuth.instance.authStateChanges().listen((_) {}) {
    _subscription.onData((_) => notifyListeners());
  }

  final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

bool _isProtectedPath(String path) {
  return path.startsWith('/wallet') ||
      path.startsWith('/documents') ||
      path.startsWith('/trips');
}

GoRouter createAppRouter() {
  final authRefresh = _AuthRefreshListenable();

  return GoRouter(
    initialLocation: AppRoute.splash.path,
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthenticated = FirebaseAuth.instance.currentUser != null;

      if (!isAuthenticated && _isProtectedPath(path)) {
        return AppRoute.login.path;
      }

      final isAuthEntryPath = path == AppRoute.login.path ||
          path == AppRoute.register.path ||
          path == AppRoute.forgotPassword.path;

      if (isAuthenticated && isAuthEntryPath) {
        return AppRoute.home.path;
      }

      return null;
    },
    routes: [
      ...buildCoreRoutes(),
      ...buildAuthRoutes(),
      ...buildFlightRoutes(),
      ...buildHotelRoutes(),
      ...buildTripRoutes(),
    ],
  );
}
