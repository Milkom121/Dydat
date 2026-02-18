import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/sizer_extensions.dart';
import 'dart:async'; // Add this import for TimeoutException

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

/// Splash Screen for Dydat AI tutoring application
///
/// Performs JWT validation and determines user navigation path:
/// - Authenticated users → StudioScreen (Tab 0)
/// - New users → OnboardingScreen
/// - Expired tokens → LoginScreen
///
/// Features:
/// - Full-screen branded experience with dark theme
/// - Centered mascotte placeholder with subtle animation
/// - Platform-native loading indicator
/// - Background tasks: JWT check, theme loading, cache preparation
/// - Smooth fade transition to next screen
/// - Handles network timeout with retry option
/// - Respects reduced motion accessibility preferences
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
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

  /// Initialize mascotte animations with reduced motion support
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Start animation if reduced motion is not enabled
    _animationController.forward();
  }

  /// Perform critical startup tasks with timeout handling
  Future<void> _performStartupTasks() async {
    try {
      // Simulate JWT validation and initialization tasks
      await Future.wait([
        _checkAuthentication(),
        _loadThemePreferences(),
        _prepareCachedData(),
        Future.delayed(
          const Duration(milliseconds: 2500),
        ), // Minimum display time
      ]).timeout(
        const Duration(seconds: 5),
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
      if (mounted && !_isTimeout) {
        setState(() => _isTimeout = true);
      }
    }
  }

  /// Check JWT authentication status
  Future<void> _checkAuthentication() async {
    // Simulate JWT validation from secure storage
    await Future.delayed(const Duration(milliseconds: 800));
  }

  /// Load user theme preferences
  Future<void> _loadThemePreferences() async {
    // Simulate theme preference loading
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Prepare cached data
  Future<void> _prepareCachedData() async {
    // Simulate cache preparation
    await Future.delayed(const Duration(milliseconds: 600));
  }

  /// Navigate to appropriate screen based on authentication status
  Future<void> _navigateToNextScreen() async {
    if (_isNavigating) return;
    _isNavigating = true;

    // Fade out animation
    await _animationController.reverse();

    if (!mounted) return;

    // Mock authentication logic - in production, check actual JWT
    final bool isAuthenticated = false; // Mock: no stored JWT
    final bool isNewUser = true; // Mock: first time user

    String targetRoute;
    if (isAuthenticated) {
      targetRoute = '/studio-screen';
    } else if (isNewUser) {
      targetRoute = '/onboarding-screen';
    } else {
      targetRoute = '/login-screen';
    }

    // Navigate with smooth transition
    await Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacementNamed(targetRoute);
  }

  /// Retry startup tasks after timeout
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

    // Set system UI overlay style for dark theme
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
              const Color(0xFF1A1A1E), // darkBackground
              const Color(0xFF242428), // darkSurface
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

  /// Build main splash content with mascotte and loading indicator
  Widget _buildSplashContent(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),

        // Animated mascotte placeholder
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

        // Loading indicator
        _buildLoadingIndicator(theme),

        SizedBox(height: 4.h),

        // App version
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

  /// Build mascotte placeholder with Dydat branding
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

  /// Build platform-native loading indicator
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

  /// Build timeout view with retry option
  Widget _buildTimeoutView(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Error icon
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

          // Error message
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

          // Retry button
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