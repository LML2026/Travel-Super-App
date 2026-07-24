import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../../core/validators/auth_validators.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/loading_overlay.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _auth.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
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
          title: const Text('Create Account'),
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
                        label: 'Email',
                        hintText: 'your@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email,
                        validator: AuthValidators.validateEmail,
                        enabled: !_loading,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Password',
                        hintText: 'At least 6 characters',
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: Icons.lock,
                        validator: AuthValidators.validatePassword,
                        enabled: !_loading,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Confirm Password',
                        hintText: 'Re-enter your password',
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
                  label: 'Create Account',
                  isLoading: _loading,
                  onPressed: _loading ? null : _register,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    child: const Text('Already have an account? Sign in'),
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
