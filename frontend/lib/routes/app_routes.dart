import 'package:flutter/material.dart';
import '../presentation/onboarding_screen/onboarding_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/learning_path_screen/learning_path_screen.dart';
import '../presentation/studio_screen/studio_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String onboarding = '/onboarding-screen';
  static const String splash = '/splash-screen';
  static const String learningPath = '/learning-path-screen';
  static const String studio = '/studio-screen';
  static const String login = '/login-screen';
  static const String registration = '/registration-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    splash: (context) => const SplashScreen(),
    learningPath: (context) => const LearningPathScreen(),
    studio: (context) => const StudioScreen(),
    login: (context) => const LoginScreen(),
    registration: (context) => const RegistrationScreen(),
    // TODO: Add your other routes here
  };
}
