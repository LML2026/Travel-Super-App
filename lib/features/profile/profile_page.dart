import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../app/providers.dart';
import '../authentication/presentation/providers/auth_providers.dart';
import '../authentication/data/services/account_deletion_service.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authActionControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.goLogin();
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: AppLocalizations.of(context)!.signOut,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.account, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              Text(user?.displayName ?? AppLocalizations.of(context)!.traveler),
              const SizedBox(height: AppSpacing.xs),
              Text(user?.email ?? AppLocalizations.of(context)!.noEmailAvailable),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppLocalizations.of(context)!.profileHomeShortcutsHint,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'App Language',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: ref.watch(appLocaleProvider)?.languageCode ?? 'en',
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: AppLocalizations.supportedLocales
                    .map(
                      (locale) => DropdownMenuItem<String>(
                        value: locale.languageCode,
                        child: Text(_languageName(locale.languageCode)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) return;
                  ref.read(appLocaleProvider.notifier).state = Locale(value);
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton.icon(
                onPressed: () => _confirmDeleteAccount(context, ref, user),
                icon: const Icon(Icons.delete_forever_outlined),
                label: Text(AppLocalizations.of(context)!.deleteAccount),
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
    final confirmed = await showDialog<String?>(
      context: context,
      builder: (dialogContext) => DeleteAccountConfirmationDialog(
        hasPasswordProvider: hasPasswordProvider,
      ),
    );
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
          : AppLocalizations.of(context)!.deleteAccountFailed;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}


String _languageName(String code) {
  const names = <String, String>{
    'ar': 'Arabic',
    'bg': 'Bulgarian',
    'cs': 'Czech',
    'da': 'Danish',
    'de': 'German',
    'el': 'Greek',
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'it': 'Italian',
    'ja': 'Japanese',
    'nl': 'Dutch',
    'pl': 'Polish',
    'pt': 'Portuguese',
    'ro': 'Romanian',
    'ru': 'Russian',
    'sv': 'Swedish',
    'tr': 'Turkish',
    'zh': 'Chinese',
  };
  return names[code] ?? code.toUpperCase();
}

@visibleForTesting
class DeleteAccountConfirmationDialog extends StatefulWidget {
  const DeleteAccountConfirmationDialog({
    required this.hasPasswordProvider,
    super.key,
  });

  final bool hasPasswordProvider;

  @override
  State<DeleteAccountConfirmationDialog> createState() =>
      _DeleteAccountConfirmationDialogState();
}

class _DeleteAccountConfirmationDialogState
    extends State<DeleteAccountConfirmationDialog> {
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.deleteAccountQuestion),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.deleteAccountWarning,
          ),
          if (widget.hasPasswordProvider) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.currentPassword,
                border: const OutlineInputBorder(),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                AppLocalizations.of(context)!.reauthenticateWithProvider,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(
            context,
            widget.hasPasswordProvider ? _passwordController.text : '',
          ),
          child: Text(AppLocalizations.of(context)!.deletePermanently),
        ),
      ],
    );
  }
}
