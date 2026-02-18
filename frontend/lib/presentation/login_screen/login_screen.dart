import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_config.dart';
import '../../core/sizer_extensions.dart';

import '../../core/app_export.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_icon_widget.dart';

/// Login Screen for Dydat AI tutoring application
/// Provides secure JWT-based authentication with 30-day token persistence
/// Features email/password login with inline validation and error handling
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

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

    ref.read(authProvider.notifier).clearError();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    await ref.read(authProvider.notifier).login(
          email: email,
          password: password,
        );

    // On success, GoRouter redirect handles navigation automatically.
    // On error, authProvider.error is set and the UI rebuilds via ref.watch.
    if (!mounted) return;
    if (ref.read(authProvider).isAuthenticated) {
      HapticFeedback.lightImpact();
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
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final errorMessage = authState.error;

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
                  if (errorMessage != null)
                    _buildErrorMessage(theme, errorMessage),

                  // Email Field
                  _buildEmailField(theme, isLoading),

                  SizedBox(height: 2.h),

                  // Password Field
                  _buildPasswordField(theme, isLoading),

                  SizedBox(height: 1.h),

                  // Forgot Password Link
                  _buildForgotPasswordLink(theme, isLoading),

                  SizedBox(height: 4.h),

                  // Login Button
                  _buildLoginButton(theme, isLoading),

                  SizedBox(height: 3.h),

                  // Registration Link
                  _buildRegistrationLink(theme, isLoading),

                  // Dev quick login (debug only)
                  if (kDebugMode) ...[
                    SizedBox(height: 2.h),
                    _buildDevLoginButton(theme, isLoading),
                  ],

                  SizedBox(height: 2.h),
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

  Widget _buildErrorMessage(ThemeData theme, String errorMessage) {
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
              errorMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(ThemeData theme, bool isLoading) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      enabled: !isLoading,
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

  Widget _buildPasswordField(ThemeData theme, bool isLoading) {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      textInputAction: TextInputAction.done,
      enabled: !isLoading,
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

  Widget _buildForgotPasswordLink(ThemeData theme, bool isLoading) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: isLoading
            ? null
            : () {
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

  Widget _buildLoginButton(ThemeData theme, bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 6.h)),
      child: isLoading
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

  Widget _buildRegistrationLink(ThemeData theme, bool isLoading) {
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
          onPressed: isLoading
              ? null
              : () {
                  context.go('/onboarding');
                },
          child: Text(
            'Inizia qui',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleDevLogin() async {
    ref.read(authProvider.notifier).clearError();

    // Try login first (faster path when user already exists)
    await ref.read(authProvider.notifier).login(
          email: AppConfig.devEmail,
          password: AppConfig.devPassword,
        );

    if (!mounted) return;

    // If login failed (user doesn't exist yet), register instead
    if (!ref.read(authProvider).isAuthenticated) {
      ref.read(authProvider.notifier).clearError();
      await ref.read(authProvider.notifier).register(
            email: AppConfig.devEmail,
            password: AppConfig.devPassword,
            nome: AppConfig.devNome,
          );
    }

    if (!mounted) return;
    if (ref.read(authProvider).isAuthenticated) {
      HapticFeedback.lightImpact();
    }
  }

  Widget _buildDevLoginButton(ThemeData theme, bool isLoading) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : _handleDevLogin,
      icon: CustomIconWidget(
        iconName: 'bug_report',
        color: theme.colorScheme.onSurfaceVariant,
        size: 18,
      ),
      label: Text(
        'Login rapido dev',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 5.h),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
