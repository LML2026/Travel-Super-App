import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../auth/presentation/utils/auth_error_mapper.dart';
import '../providers/auth_providers.dart';

class AuthenticationRegisterPage extends ConsumerStatefulWidget {
  const AuthenticationRegisterPage({super.key});

  @override
  ConsumerState<AuthenticationRegisterPage> createState() =>
      _AuthenticationRegisterPageState();
}

class _AuthenticationRegisterPageState
    extends ConsumerState<AuthenticationRegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _acceptedTerms = false;
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept terms to continue.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final destination = await ref
          .read(authActionControllerProvider.notifier)
          .registerWithEmail(
            displayName: _nameController.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _loading,
      child: AppScaffold(
        appBar: AppBar(title: const Text('Create Account')),
        maxContentWidth: 420,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create your account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  enabled: !_loading,
                  validator: AuthValidators.validateName,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_loading,
                  validator: AuthValidators.validateEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _passwordController,
                  enabled: !_loading,
                  validator: AuthValidators.validatePassword,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _confirmPasswordController,
                  enabled: !_loading,
                  labelText: 'Confirm Password',
                  validator: (value) => AuthValidators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: _acceptedTerms,
                  onChanged: _loading
                      ? null
                      : (value) {
                          setState(() => _acceptedTerms = value ?? false);
                        },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('I accept Terms and Privacy Policy'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: const Text('Create Account'),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
