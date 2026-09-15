import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/validators/auth_validators.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/utils/auth_error_mapper.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/loading_overlay.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await ref.read(authMutationProvider.notifier).register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.ui('registrationSuccessful'))),
        );
        Navigator.pop(context);
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
        appBar: AppBar(
          title: Text(context.ui('createAccount')),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Join us today',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your account to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
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
                        hintText: context.ui('atLeastSixCharacters'),
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: Icons.lock,
                        validator: AuthValidators.validatePassword,
                        enabled: !_loading,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: context.ui('confirmPassword'),
                        hintText: context.ui('reenterPassword'),
                        controller: _confirmPasswordController,
                        obscureText: true,
                        prefixIcon: Icons.lock,
                        validator: (value) =>
                            AuthValidators.validateConfirmPassword(
                              value,
                              _passwordController.text,
                            ),
                        enabled: !_loading,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: context.ui('createAccount'),
                  isLoading: _loading,
                  onPressed: _loading ? null : _register,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    child: Text(context.ui('alreadyHaveAccountSignIn')),
                  ),
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
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
