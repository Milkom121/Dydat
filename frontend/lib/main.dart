import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/achievement_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/path_provider.dart';
import 'providers/session_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'routes/app_router.dart';
import 'services/achievement_service.dart';
import 'services/auth_service.dart';
import 'services/dio_client.dart';
import 'services/onboarding_service.dart';
import 'services/path_service.dart';
import 'services/session_service.dart';
import 'services/sse_client.dart';
import 'services/storage_service.dart';
import 'services/user_service.dart';
import 'theme/app_theme.dart';
import 'widgets/custom_error_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool hasShownError = false;

  // Custom error handling
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!hasShownError) {
      hasShownError = true;
      Future.delayed(const Duration(seconds: 5), () {
        hasShownError = false;
      });
      return CustomErrorWidget(errorDetails: details);
    }
    return const SizedBox.shrink();
  };

  // Create services for dependency injection.
  final storageService = StorageService();
  final dioClient = DioClient(storageService: storageService);
  final authService = AuthService(client: dioClient);
  final userService = UserService(client: dioClient);
  final pathService = PathService(client: dioClient);
  final achievementService = AchievementService(client: dioClient);
  final sseClient = SseClient(storageService: storageService);
  final sessionService = SessionService(
    client: dioClient,
    sseClient: sseClient,
  );
  final onboardingService = OnboardingService(
    client: dioClient,
    sseClient: sseClient,
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    ProviderScope(
      overrides: [
        authProvider.overrideWith(
          (ref) => AuthNotifier(
            authService: authService,
            userService: userService,
            storageService: storageService,
          ),
        ),
        pathProvider.overrideWith(
          (ref) => PathNotifier(pathService: pathService),
        ),
        userProvider.overrideWith(
          (ref) => UserNotifier(userService: userService),
        ),
        statsProvider.overrideWith(
          (ref) => StatsNotifier(userService: userService),
        ),
        achievementProvider.overrideWith(
          (ref) => AchievementNotifier(achievementService: achievementService),
        ),
        sessionProvider.overrideWith(
          (ref) => SessionNotifier(sessionService: sessionService),
        ),
        onboardingProvider.overrideWith(
          (ref) => OnboardingNotifier(
            onboardingService: onboardingService,
            storageService: storageService,
          ),
        ),
      ],
      child: const DydatApp(),
    ),
  );
}

class DydatApp extends ConsumerWidget {
  const DydatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Dydat',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
