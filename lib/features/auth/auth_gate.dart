import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../navigation/main_navigation_page.dart';
import 'login_page.dart';
import 'presentation/providers/auth_provider.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const LoginPage(),
      data: (User? user) {
        if (user != null) {
          return const MainNavigationPage();
        }

        return const LoginPage();
      },
    );
  }
}
