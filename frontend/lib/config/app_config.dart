class AppConfig {
  AppConfig._();

  static const String appName = 'Dydat';
  static const String version = '1.0.0';

  // Feature flags — placeholder per loop futuri
  static const bool enableSse = false;
  static const bool enableLatex = false;
  static const bool enableCelebrations = false;

  // Dev quick-login credentials (only shown in debug mode)
  static const String devEmail = 'dev@dydat.dev';
  static const String devPassword = 'dev12345';
  static const String devNome = 'Dev User';
}
