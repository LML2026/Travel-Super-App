import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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
