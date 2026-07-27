import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import '../features/authentication/domain/entities/auth_user.dart';
import '../features/authentication/presentation/providers/auth_providers.dart';
import 'route_groups/auth_routes.dart';
import 'route_groups/core_routes.dart';
import 'route_groups/flight_routes.dart';
import 'route_groups/hotel_routes.dart';
import 'route_groups/trip_routes.dart';

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Stream<AuthUser?> authStateChanges)
      : _subscription = authStateChanges.listen((_) {}) {
    _subscription.onData((_) => notifyListeners());
  }

  final StreamSubscription<AuthUser?> _subscription;

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

GoRouter createAppRouter(Ref ref) {
  final authRefresh = _AuthRefreshListenable(
    ref.watch(watchAuthStateProvider).call(),
  );

  return GoRouter(
    initialLocation: AppRoute.splash.path,
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final path = state.uri.path;
      final user = ref.read(immediateCurrentUserProvider);
      final isAuthenticated = user != null;
      final needsVerification = user != null && requiresEmailVerification(user);

      if (!isAuthenticated && _isProtectedPath(path)) {
        return AppRoute.login.path;
      }

      if (!isAuthenticated && path == AppRoute.emailVerification.path) {
        return AppRoute.login.path;
      }

      if (isAuthenticated &&
          needsVerification &&
          path != AppRoute.emailVerification.path) {
        return AppRoute.emailVerification.path;
      }

      if (isAuthenticated &&
          !needsVerification &&
          path == AppRoute.emailVerification.path) {
        return AppRoute.home.path;
      }

      final isAuthEntryPath = path == AppRoute.login.path ||
          path == AppRoute.register.path ||
          path == AppRoute.forgotPassword.path;

      if (isAuthenticated && isAuthEntryPath) {
        return needsVerification
            ? AppRoute.emailVerification.path
            : AppRoute.home.path;
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
