import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../../core/validators/auth_validators.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/utils/auth_error_mapper.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/loading_overlay.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await ref.read(authMutationProvider.notifier).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (mounted) {
        context.goHome();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.messageFor(error))),
        );
      }
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);

    try {
      await ref.read(authMutationProvider.notifier).signInWithGoogle();

      if (mounted) {
        context.goHome();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.messageFor(error))),
        );
      }
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _loading = true);

    try {
      await ref.read(authMutationProvider.notifier).signInWithApple();

      if (mounted) {
        context.goHome();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.messageFor(error))),
        );
      }
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _loading,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.flight_takeoff,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'ITAREVO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          label: context.ui('email'),
                          hintText: context.ui('yourEmailExample'),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email,
                          validator: AuthValidators.validateEmail,
                          enabled: !_loading,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Password',
                          hintText: context.ui('enterPassword'),
                          controller: _passwordController,
                          obscureText: true,
                          prefixIcon: Icons.lock,
                          validator: AuthValidators.validatePassword,
                          enabled: !_loading,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _loading
                          ? null
                          : () {
                              context.pushForgotPassword();
                            },
                      child: Text(context.ui('forgotPasswordQuestion')),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: context.ui('signIn'),
                    isLoading: _loading,
                    onPressed: _loading ? null : _login,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : _signInWithGoogle,
                    icon: const Icon(Icons.account_circle_outlined),
                    label: Text(context.ui('continueWithGoogle')),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : _signInWithApple,
                    icon: const Icon(Icons.apple),
                    label: Text(context.ui('continueWithApple')),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            context.pushRegister();
                          },
                    child: const Text(
                      'Don\'t have an account? Create one',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
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
