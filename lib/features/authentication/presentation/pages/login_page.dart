import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../auth/presentation/utils/auth_error_mapper.dart';
import '../providers/auth_providers.dart';

class AuthenticationLoginPage extends ConsumerStatefulWidget {
  const AuthenticationLoginPage({super.key});

  @override
  ConsumerState<AuthenticationLoginPage> createState() =>
      _AuthenticationLoginPageState();
}

class _AuthenticationLoginPageState
    extends ConsumerState<AuthenticationLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _rememberMe = true;
  bool _loading = false;

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);
    try {
      final destination =
          await ref.read(authActionControllerProvider.notifier).signInWithEmail(
                email: _emailController.text.trim(),
                password: _passwordController.text,
              );

      if (!mounted) {
        return;
      }

      if (destination == AuthDestination.emailVerification) {
        context.goEmailVerification();
      } else {
        context.goHome();
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

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final destination = await ref
          .read(authActionControllerProvider.notifier)
          .signInWithGoogle();
      if (!mounted) {
        return;
      }
      if (destination == AuthDestination.emailVerification) {
        context.goEmailVerification();
      } else {
        context.goHome();
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

  Future<void> _signInWithApple() async {
    setState(() => _loading = true);
    try {
      final destination = await ref
          .read(authActionControllerProvider.notifier)
          .signInWithApple();
      if (!mounted) {
        return;
      }
      if (destination == AuthDestination.emailVerification) {
        context.goEmailVerification();
      } else {
        context.goHome();
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
        appBar: AppBar(title: const Text('Sign In')),
        maxContentWidth: 420,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue planning your trips.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_loading,
                  validator: AuthValidators.validateEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _passwordController,
                  enabled: !_loading,
                  validator: AuthValidators.validatePassword,
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Remember me'),
                  subtitle: const Text(
                    'Session is securely persisted on this device.',
                  ),
                  value: _rememberMe,
                  onChanged: _loading
                      ? null
                      : (value) {
                          setState(() => _rememberMe = value ?? true);
                        },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            context.pushForgotPassword();
                          },
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _signInWithEmail,
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _signInWithGoogle,
                  icon: const Icon(Icons.account_circle_outlined),
                  label: const Text('Continue with Google'),
                ),
                if (!kIsWeb)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: OutlinedButton.icon(
                      onPressed: _loading ? null : _signInWithApple,
                      icon: const Icon(Icons.apple),
                      label: const Text('Continue with Apple'),
                    ),
                  ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () {
                          context.pushRegister();
                        },
                  child: const Text('Create an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
