import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/onboarding_screen/onboarding_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/home_screen/home_screen.dart';
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
  static const home = '/home';
  static const studi = '/studi';
  static const studio = '/studio';
  static const profilo = '/profilo';
  static const recap = '/recap';
  static String recapSession(String sessioneId) => '/recap/$sessioneId';
}

/// Shell con bottom navigation bar per i 3 tab principali: Home, I miei studi, Profilo.
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
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

/// Notifier che forza il redirect GoRouter al cambio di stato auth.
///
/// Evita di ricreare l'intero GoRouter (e ricostruire il widget tree)
/// ad ogni cambio auth — esegue solo il redirect.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    _sub = ref.listen(authProvider, (_, __) {
      notifyListeners();
    });
  }

  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

/// GoRouter provider — usa refreshListenable per reagire ai cambi auth
/// SENZA ricreare l'istanza router.
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(() => refreshNotifier.dispose());

  return GoRouter(
    initialLocation: AppPaths.splash,
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      // Legge auth state al momento del redirect (non alla creazione del GoRouter).
      final isAuthenticated = ref.read(authProvider).isAuthenticated;
      final location = state.matchedLocation;

      // Utenti autenticati non devono stare su splash, login o registration.
      if (isAuthenticated) {
        if (location == AppPaths.splash ||
            location == AppPaths.login ||
            location == AppPaths.registration) {
          return AppPaths.home;
        }
        return null;
      }

      // Non autenticato — permette splash e route pubbliche.
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
      // Splash — entry point, gestisce il check auth iniziale.
      GoRoute(
        path: AppPaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Route auth (fuori dalla shell — niente bottom bar).
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

      // Studio — fuori dalla shell, fullscreen modale senza bottom bar.
      // Accetta query param: tipo (media|ripasso), default: media.
      GoRoute(
        path: AppPaths.studio,
        builder: (context, state) {
          final tipo = state.uri.queryParameters['tipo'] ?? 'media';
          return StudioScreen(tipo: tipo);
        },
      ),

      // Recap sessione (fuori dalla shell — niente bottom bar).
      GoRoute(
        path: '${AppPaths.recap}/:sessioneId',
        builder: (context, state) {
          final sessioneId = state.pathParameters['sessioneId']!;
          return RecapSessionScreen(sessioneId: sessioneId);
        },
      ),

      // App principale — shell route con bottom navigation bar (3 tab).
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _ShellScaffold(
            navigationShell: navigationShell,
            child: navigationShell,
          );
        },
        branches: [
          // Tab 0 — Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Tab 1 — I miei studi
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.studi,
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
