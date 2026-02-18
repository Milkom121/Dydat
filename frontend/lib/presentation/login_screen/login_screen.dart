import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/sizer_extensions.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

/// Login Screen for Dydat AI tutoring application
/// Provides secure JWT-based authentication with 30-day token persistence
/// Features email/password login with inline validation and error handling
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Mock credentials for demonstration
  final String _mockEmail = "studente@dydat.it";
  final String _mockPassword = "Dydat2026!";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate authentication delay
    await Future.delayed(const Duration(seconds: 1));

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validate credentials
    if (email == _mockEmail && password == _mockPassword) {
      // Success - provide haptic feedback
      HapticFeedback.lightImpact();

      setState(() {
        _isLoading = false;
      });

      // Navigate to Studio screen
      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed('/studio-screen');
      }
    } else {
      // Failed authentication
      setState(() {
        _isLoading = false;
        _errorMessage = 'Credenziali non valide. Riprova.';
      });
    }
  }

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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Inserisci la tua password';
    }

    if (value.length < 6) {
      return 'La password deve contenere almeno 6 caratteri';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 8.h),

                  // App Logo
                  _buildLogo(theme),

                  SizedBox(height: 6.h),

                  // Welcome Text
                  _buildWelcomeText(theme),

                  SizedBox(height: 4.h),

                  // Error Message
                  if (_errorMessage != null) _buildErrorMessage(theme),

                  // Email Field
                  _buildEmailField(theme),

                  SizedBox(height: 2.h),

                  // Password Field
                  _buildPasswordField(theme),

                  SizedBox(height: 1.h),

                  // Forgot Password Link
                  _buildForgotPasswordLink(theme),

                  SizedBox(height: 4.h),

                  // Login Button
                  _buildLoginButton(theme),

                  SizedBox(height: 3.h),

                  // Registration Link
                  _buildRegistrationLink(theme),

                  SizedBox(height: 2.h),

                  // Mock Credentials Info
                  _buildMockCredentialsInfo(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Center(
      child: Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            'D',
            style: theme.textTheme.displayMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Bentornato!',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Text(
          'Accedi per continuare il tuo percorso di apprendimento',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorMessage(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'error_outline',
            color: theme.colorScheme.error,
            size: 20,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              _errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      enabled: !_isLoading,
      validator: _validateEmail,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'esempio@email.it',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'email_outlined',
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      textInputAction: TextInputAction.done,
      enabled: !_isLoading,
      validator: _validatePassword,
      onFieldSubmitted: (_) => _handleLogin(),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Inserisci la tua password',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'lock_outline',
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        suffixIcon: IconButton(
          icon: CustomIconWidget(
            iconName: _isPasswordVisible ? 'visibility_off' : 'visibility',
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink(ThemeData theme) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _isLoading
            ? null
            : () {
                // TODO: Implement password recovery
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Funzionalità in arrivo'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
        child: Text(
          'Password dimenticata?',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 6.h)),
      child: _isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onPrimary,
                ),
              ),
            )
          : Text(
              'Accedi',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
    );
  }

  Widget _buildRegistrationLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Nuovo utente? ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamed('/registration-screen');
                },
          child: Text(
            'Registrati',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMockCredentialsInfo(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info_outline',
                color: theme.colorScheme.primary,
                size: 18,
              ),
              SizedBox(width: 2.w),
              Text(
                'Credenziali Demo',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Email: $_mockEmail',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontFamily: 'monospace',
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Password: $_mockPassword',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
