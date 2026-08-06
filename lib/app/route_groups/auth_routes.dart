import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/pages/email_verification_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../app_routes.dart';

List<RouteBase> buildAuthRoutes() {
  return [
    GoRoute(
      name: AppRoute.login.routeName,
      path: AppRoute.login.path,
      builder: (context, state) => const AuthenticationLoginPage(),
    ),
    GoRoute(
      name: AppRoute.register.routeName,
      path: AppRoute.register.path,
      builder: (context, state) => const AuthenticationRegisterPage(),
    ),
    GoRoute(
      name: AppRoute.forgotPassword.routeName,
      path: AppRoute.forgotPassword.path,
      builder: (context, state) => const AuthenticationForgotPasswordPage(),
    ),
    GoRoute(
      name: AppRoute.emailVerification.routeName,
      path: AppRoute.emailVerification.path,
      builder: (context, state) => const EmailVerificationPage(),
    ),
  ];
}
