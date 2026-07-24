import 'package:go_router/go_router.dart';
import '../features/auth/login_page.dart';
import '../features/home/home_page.dart';
import '../features/splash/splash_page.dart';

class AppRouter {
  static const String splashPath = '/';
  static const String loginPath = '/login';
  static const String homePath = '/home';

  static final GoRouter router = GoRouter(
    initialLocation: splashPath,
    routes: [
      GoRoute(
        path: splashPath,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: loginPath,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: homePath,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
