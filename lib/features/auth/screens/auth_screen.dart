import 'package:flutter/material.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/auth/auth_user.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../l10n/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  final AuthService service;
  final bool unavailable;

  const AuthScreen({
    super.key,
    required this.service,
    this.unavailable = false,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isCreateAccount = false;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorCode;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.unavailable || !_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorCode = null;
    });

    try {
      AuthUser user;
      if (_isCreateAccount) {
        user = await widget.service.createAccount(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        user = await widget.service.signInWithEmailPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      if (!mounted) return;
      if (user.uid.isEmpty) setState(() => _errorCode = 'authFailed');
    } on AuthException catch (error) {
      if (mounted) setState(() => _errorCode = error.code);
    } catch (_) {
      if (mounted) setState(() => _errorCode = 'authFailed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _errorMessage(AppLocalizations l10n) {
    switch (_errorCode) {
      case 'invalidEmail':
        return l10n.authInvalidEmail;
      case 'invalidCredentials':
        return l10n.authInvalidCredentials;
      case 'emailAlreadyInUse':
        return l10n.authEmailAlreadyInUse;
      case 'weakPassword':
        return l10n.authWeakPassword;
      case 'networkUnavailable':
        return l10n.authNetworkUnavailable;
      case 'tooManyRequests':
        return l10n.authTooManyRequests;
      case 'authUnavailable':
        return l10n.authUnavailable;
      case 'signOutFailed':
        return l10n.authSignOutFailed;
      case 'signUpFailed':
        return l10n.authSignUpFailed;
      default:
        return l10n.authFailed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _isCreateAccount ? l10n.createAccount : l10n.signIn;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AppCard(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'ITAREVO',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.authWelcome,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 28),
                      if (widget.unavailable) ...[
                        Text(
                          l10n.authUnavailable,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      AppTextField(
                        controller: _emailController,
                        enabled: !widget.unavailable && !_isLoading,
                        label: l10n.email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (value) {
                          if (value == null || !value.contains('@')) {
                            return l10n.authInvalidEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _passwordController,
                        enabled: !widget.unavailable && !_isLoading,
                        label: l10n.password,
                        obscureText: !_isPasswordVisible,
                        autofillHints: const [AutofillHints.password],
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _isPasswordVisible
                              ? l10n.hidePassword
                              : l10n.showPassword,
                          onPressed: widget.unavailable || _isLoading
                              ? null
                              : () => setState(
                                  () =>
                                      _isPasswordVisible = !_isPasswordVisible,
                                ),
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return l10n.authPasswordRequirements;
                          }
                          return null;
                        },
                      ),
                      if (_errorCode != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _errorMessage(l10n),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      AppButton(
                        label: title,
                        onPressed: widget.unavailable || _isLoading
                            ? null
                            : _submit,
                        isLoading: _isLoading,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 8),
                      AppButton(
                        variant: AppButtonVariant.tertiary,
                        fullWidth: true,
                        label: _isCreateAccount
                            ? l10n.alreadyHaveAccount
                            : l10n.needAnAccount,
                        onPressed: widget.unavailable || _isLoading
                            ? null
                            : () => setState(() {
                                _isCreateAccount = !_isCreateAccount;
                                _errorCode = null;
                              }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
