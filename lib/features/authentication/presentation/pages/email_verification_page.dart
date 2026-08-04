import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/utils/auth_error_mapper.dart';
import '../providers/auth_providers.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  ConsumerState<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  bool _loading = false;

  Future<void> _resend() async {
    setState(() => _loading = true);
    try {
      await ref
          .read(authActionControllerProvider.notifier)
          .resendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent again.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.messageFor(error))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _continueAfterVerification() async {
    setState(() => _loading = true);
    try {
      final isVerified = await ref
          .read(authActionControllerProvider.notifier)
          .refreshEmailVerificationStatus();

      if (!mounted) {
        return;
      }

      if (isVerified) {
        context.goHome();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email is not verified yet.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.messageFor(error))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _signOut() async {
    setState(() => _loading = true);
    try {
      await ref.read(authActionControllerProvider.notifier).signOut();
      if (mounted) {
        context.goLogin();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.messageFor(error))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user =
        ref.watch(currentUserProvider) ??
        ref.watch(immediateCurrentUserProvider);

    return AppScaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      maxContentWidth: 560,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Verify your email to continue',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'We sent a verification email to ${user?.email ?? 'your account email'}.',
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _continueAfterVerification,
            child: const Text('I have verified my email'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _loading ? null : _resend,
            child: const Text('Resend verification email'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loading ? null : _signOut,
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
