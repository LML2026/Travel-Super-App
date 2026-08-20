import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/widgets.dart';
import '../authentication/presentation/providers/auth_providers.dart';
import '../authentication/data/services/account_deletion_service.dart';

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
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton.icon(
                onPressed: () => _confirmDeleteAccount(context, ref, user),
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('Delete account'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
    User? user,
  ) async {
    if (user == null) return;
    final hasPasswordProvider =
        user.providerData.any((provider) => provider.providerId == 'password');
    final passwordController = TextEditingController();
    final confirmed = await showDialog<String?>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This permanently removes your ITAREVO profile and data owned by this account. This action cannot be undone.',
            ),
            if (hasPasswordProvider) ...[
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current password',
                  border: OutlineInputBorder(),
                ),
              ),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'You will be asked to authenticate with your sign-in provider.',
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(
              dialogContext,
              hasPasswordProvider ? passwordController.text : '',
            ),
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    );
    passwordController.dispose();
    if (confirmed == null || !context.mounted) return;

    try {
      await ref
          .read(authActionControllerProvider.notifier)
          .deleteAccount(password: confirmed);
      if (context.mounted) context.goLogin();
    } catch (error) {
      if (!context.mounted) return;
      final message = error is AccountDeletionException
          ? error.message
          : 'We could not delete your account. Please try again.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
