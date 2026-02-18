import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/sizer_extensions.dart';

import './widgets/registration_form_widget.dart';
import './widgets/registration_header_widget.dart';
import '../../providers/auth_provider.dart';

/// Registration screen for new user account creation
/// Handles temporary user conversion and mobile-optimized form inputs
class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() =>
      _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomeController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  /// Validates email format
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Inserisci la tua email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Inserisci un\'email valida';
    }
    return null;
  }

  /// Validates password strength
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Inserisci la tua password';
    }
    if (value.length < 8) {
      return 'La password deve contenere almeno 8 caratteri';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'La password deve contenere almeno una lettera maiuscola';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'La password deve contenere almeno un numero';
    }
    return null;
  }

  /// Validates name field
  String? _validateNome(String? value) {
    if (value == null || value.isEmpty) {
      return 'Inserisci il tuo nome';
    }
    if (value.length < 2) {
      return 'Il nome deve contenere almeno 2 caratteri';
    }
    return null;
  }

  /// Handles account creation via auth_provider.register()
  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ref.read(authProvider.notifier).clearError();

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final nome = _nomeController.text.trim();

    await ref.read(authProvider.notifier).register(
          email: email,
          password: password,
          nome: nome,
        );

    // On success, GoRouter redirect handles navigation automatically.
    // On error, authProvider.error is set and the UI rebuilds via ref.watch.
    if (!mounted) return;
    if (ref.read(authProvider).isAuthenticated) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Navigates to login screen
  void _navigateToLogin() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final errorMessage = authState.error;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with branding
                  RegistrationHeaderWidget(),

                  SizedBox(height: 4.h),

                  // Registration form
                  RegistrationFormWidget(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    nomeController: _nomeController,
                    isPasswordVisible: _isPasswordVisible,
                    isLoading: isLoading,
                    errorMessage: errorMessage,
                    onPasswordVisibilityToggle: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    validateEmail: _validateEmail,
                    validatePassword: _validatePassword,
                    validateNome: _validateNome,
                    onSubmit: _handleRegistration,
                  ),

                  SizedBox(height: 3.h),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hai già un account? ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      GestureDetector(
                        onTap: _navigateToLogin,
                        child: Text(
                          'Accedi',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
