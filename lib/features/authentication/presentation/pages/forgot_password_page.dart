import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/validators/auth_validators.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../auth/presentation/utils/auth_error_mapper.dart';
import '../providers/auth_providers.dart';

class AuthenticationForgotPasswordPage extends ConsumerStatefulWidget {
  const AuthenticationForgotPasswordPage({super.key});

  @override
  ConsumerState<AuthenticationForgotPasswordPage> createState() =>
      _AuthenticationForgotPasswordPageState();
}

class _AuthenticationForgotPasswordPageState
    extends ConsumerState<AuthenticationForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _emailSent = false;

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);
    try {
      await ref
          .read(authActionControllerProvider.notifier)
          .sendPasswordReset(email: _emailController.text.trim());
      if (mounted) {
        setState(() => _emailSent = true);
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
    return LoadingOverlay(
      isLoading: _loading,
      child: AppScaffold(
        appBar: AppBar(title: const Text('Reset Password')),
        maxContentWidth: 520,
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Forgot your password?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your account email and we will send a reset link.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_emailSent,
                validator: AuthValidators.validateEmail,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _emailSent || _loading ? null : _sendReset,
                child: Text(_emailSent ? 'Email Sent' : 'Send Reset Link'),
              ),
              if (_emailSent)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text('Check your inbox for reset instructions.'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
