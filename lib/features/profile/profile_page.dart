import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/widgets.dart';
import '../authentication/presentation/providers/auth_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authActionControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.goLogin();
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Account', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              Text(user?.displayName ?? 'Traveler'),
              const SizedBox(height: AppSpacing.xs),
              Text(user?.email ?? 'No email available'),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Hotels, Weather, Wallet, and Translator remain available from the Home dashboard shortcuts.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
