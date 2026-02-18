import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/sizer_extensions.dart';

import './widgets/registration_form_widget.dart';
import './widgets/registration_header_widget.dart';

/// Registration screen for new user account creation
/// Handles temporary user conversion and mobile-optimized form inputs
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomeController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

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

  /// Handles account creation with temporary user conversion
  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate API call for registration
      await Future.delayed(const Duration(seconds: 2));

      // Mock registration logic
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final nome = _nomeController.text.trim();

      // Simulate duplicate email check
      if (email == 'test@example.com') {
        throw Exception('duplicate_email');
      }

      // Success - provide haptic feedback
      HapticFeedback.mediumImpact();

      // Navigate to studio screen
      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamedAndRemoveUntil('/studio-screen', (route) => false);
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('duplicate_email')) {
          _errorMessage = 'Questa email è già registrata. Prova ad accedere.';
        } else if (e.toString().contains('network')) {
          _errorMessage = 'Errore di connessione. Verifica la tua rete.';
        } else {
          _errorMessage = 'Si è verificato un errore. Riprova più tardi.';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Navigates to login screen
  void _navigateToLogin() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacementNamed('/login-screen');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
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
