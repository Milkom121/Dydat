import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/onboarding_screen/onboarding_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/studio_screen/studio_screen.dart';
import '../presentation/studio_screen/recap_session_screen.dart';
import '../presentation/learning_path_screen/learning_path_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../widgets/custom_bottom_bar.dart';

/// Route path constants.
class AppPaths {
  static const splash = '/';
  static const login = '/login';
  static const registration = '/registration';
  static const onboarding = '/onboarding';
  static const studio = '/studio';
  static const percorso = '/percorso';
  static const profilo = '/profilo';
  static const recap = '/recap';
  static String recapSession(String sessioneId) => '/recap/$sessioneId';
}

/// Shell with bottom navigation bar for the three main tabs.
class _ShellScaffold extends StatelessWidget {
  final Widget child;
  final StatefulNavigationShell navigationShell;

  const _ShellScaffold({
    required this.child,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

/// GoRouter provider — depends on auth state for redirect logic.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppPaths.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final location = state.matchedLocation;

      // Authenticated users should not be on splash, login or registration.
      if (isAuthenticated) {
        if (location == AppPaths.splash ||
            location == AppPaths.login ||
            location == AppPaths.registration) {
          return AppPaths.studio;
        }
        return null;
      }

      // Not authenticated — allow splash and public routes.
      if (location == AppPaths.splash) return null;

      const publicRoutes = [
        AppPaths.login,
        AppPaths.registration,
        AppPaths.onboarding,
      ];

      if (!publicRoutes.contains(location)) {
        return AppPaths.login;
      }

      return null;
    },
    routes: [
      // Splash — entry point, handles initial auth check.
      GoRoute(
        path: AppPaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes (outside shell — no bottom bar).
      GoRoute(
        path: AppPaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppPaths.registration,
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: AppPaths.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Recap session (outside shell — no bottom bar).
      GoRoute(
        path: '${AppPaths.recap}/:sessioneId',
        builder: (context, state) {
          final sessioneId = state.pathParameters['sessioneId']!;
          return RecapSessionScreen(sessioneId: sessioneId);
        },
      ),

      // Main app — shell route with bottom navigation bar.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _ShellScaffold(
            navigationShell: navigationShell,
            child: navigationShell,
          );
        },
        branches: [
          // Tab 0 — Studio
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.studio,
                builder: (context, state) => const StudioScreen(),
              ),
            ],
          ),
          // Tab 1 — Percorso
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.percorso,
                builder: (context, state) => const LearningPathScreen(),
              ),
            ],
          ),
          // Tab 2 — Profilo
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.profilo,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
