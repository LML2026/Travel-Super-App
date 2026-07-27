import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../auth/presentation/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }

      // Check if user is already signed in
      if (ref.read(immediateCurrentUserProvider) != null) {
        context.goHome();
      } else {
        context.goLogin();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
              "Travel Super App",
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
}
