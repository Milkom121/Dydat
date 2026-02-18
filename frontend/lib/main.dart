import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/auth_provider.dart';
import 'providers/path_provider.dart';
import 'providers/theme_provider.dart';
import 'routes/app_router.dart';
import 'services/auth_service.dart';
import 'services/dio_client.dart';
import 'services/path_service.dart';
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
