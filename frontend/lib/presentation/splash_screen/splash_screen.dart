import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/sizer_extensions.dart';
import 'dart:async';

import '../../core/app_export.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_icon_widget.dart';

/// Splash Screen for Dydat AI tutoring application
///
/// Performs JWT validation via auth_provider.checkAuth() and determines navigation:
/// - Authenticated users → StudioScreen (Tab 0) via GoRouter redirect
/// - New/expired users → LoginScreen via GoRouter redirect
///
/// Features:
/// - Full-screen branded experience with dark theme
/// - Centered mascotte placeholder with subtle animation
/// - Real JWT check against backend
/// - Timeout handling with retry option
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isTimeout = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _performStartupTasks();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  /// Perform startup tasks: real JWT check + minimum display time
  Future<void> _performStartupTasks() async {
    try {
      await Future.wait([
        ref.read(authProvider.notifier).checkAuth(),
        Future.delayed(const Duration(milliseconds: 2000)),
      ]).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          if (mounted) {
            setState(() => _isTimeout = true);
          }
          throw TimeoutException('Startup tasks timed out');
        },
      );

      if (mounted && !_isTimeout) {
        await _navigateToNextScreen();
      }
    } catch (e) {
      if (e is TimeoutException) return;
      // checkAuth can fail silently (no token, 401) — navigate normally
      if (mounted && !_isTimeout) {
        await _navigateToNextScreen();
      }
    }
  }

  /// Navigate based on auth state — GoRouter redirect handles the logic
  Future<void> _navigateToNextScreen() async {
    if (_isNavigating) return;
    _isNavigating = true;

    await _animationController.reverse();

    if (!mounted) return;

    // Read auth state after checkAuth() completed
    final isAuthenticated = ref.read(authProvider).isAuthenticated;

    if (isAuthenticated) {
      context.go('/studio');
    } else {
      context.go('/login');
    }
  }

  Future<void> _retryStartup() async {
    setState(() {
      _isTimeout = false;
      _isNavigating = false;
    });
    _animationController.forward();
    await _performStartupTasks();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: const Color(0xFF1A1A1E),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1A1E),
              const Color(0xFF242428),
            ],
          ),
        ),
        child: SafeArea(
          child: _isTimeout
              ? _buildTimeoutView(theme)
              : _buildSplashContent(theme),
        ),
      ),
    );
  }

  Widget _buildSplashContent(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),

        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: _buildMascottePlaceholder(theme),
              ),
            );
          },
        ),

        const Spacer(),

        _buildLoadingIndicator(theme),

        SizedBox(height: 4.h),

        Text(
          'Versione 1.0.0',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
          ),
        ),

        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _buildMascottePlaceholder(ThemeData theme) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.3),
            theme.colorScheme.primary.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'school',
              color: theme.colorScheme.primary,
              size: 15.w,
            ),
            SizedBox(height: 1.h),
            Text(
              'Dydat',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
    return SizedBox(
      width: 8.w,
      height: 8.w,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
      ),
    );
  }

  Widget _buildTimeoutView(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.error.withValues(alpha: 0.1),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'wifi_off',
                color: theme.colorScheme.error,
                size: 10.w,
              ),
            ),
          ),

          SizedBox(height: 3.h),

          Text(
            'Connessione non riuscita',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 1.h),

          Text(
            'Verifica la tua connessione internet e riprova',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _retryStartup,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
              child: Text('Riprova'),
            ),
          ),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}
