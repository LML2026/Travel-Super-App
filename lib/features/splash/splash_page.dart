import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../authentication/domain/entities/auth_user.dart';
import '../authentication/presentation/providers/auth_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _navigationScheduled = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    if (authState.hasValue) {
      _navigateAfterAuthResolution(authState.value);
    } else if (authState.hasError) {
      _navigateAfterAuthResolution(null);
    }

    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight_takeoff,
              color: Colors.white,
              size: 90,
            ),
            SizedBox(height: 30),
            Text(
              "ITAREVO",
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateAfterAuthResolution(AuthUser? user) {
    if (_navigationScheduled) {
      return;
    }

    _navigationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (user == null) {
        context.goLogin();
      } else if (requiresEmailVerification(user)) {
        context.goEmailVerification();
      } else {
        context.goHome();
      }
    });
  }
}
