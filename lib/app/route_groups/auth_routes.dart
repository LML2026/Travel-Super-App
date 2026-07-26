import 'package:go_router/go_router.dart';

import '../../features/auth/auth_gate.dart';
import '../../features/auth/forgot_password_page.dart';
import '../../features/auth/register_page.dart';
import '../app_routes.dart';

List<RouteBase> buildAuthRoutes() {
  return [
    GoRoute(
      name: AppRoute.login.routeName,
      path: AppRoute.login.path,
      builder: (context, state) => const AuthGate(),
    ),
    GoRoute(
      name: AppRoute.register.routeName,
      path: AppRoute.register.path,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      name: AppRoute.forgotPassword.routeName,
      path: AppRoute.forgotPassword.path,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
  ];
}
