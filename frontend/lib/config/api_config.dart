import 'dart:io' show Platform;

class ApiConfig {
  ApiConfig._();

  static String get baseUrl =>
      Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://localhost:8000';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sseTimeout = Duration(seconds: 90);

  // Auth
  static const String register = '/auth/registrazione';
  static const String login = '/auth/login';

  // Utente
  static const String me = '/utente/me';
  static const String preferences = '/utente/me/preferenze';
  static const String stats = '/utente/me/statistiche';

  // Onboarding
  static const String onboardingStart = '/onboarding/inizia';
  static const String onboardingTurn = '/onboarding/turno';
  static const String onboardingComplete = '/onboarding/completa';

  // Sessione
  static const String sessionStart = '/sessione/inizia';
  static String sessionTurn(String id) => '/sessione/$id/turno';
  static String sessionSuspend(String id) => '/sessione/$id/sospendi';
  static String sessionEnd(String id) => '/sessione/$id/termina';
  static String sessionGet(String id) => '/sessione/$id';

  // Percorsi
  static const String paths = '/percorsi/';
  static String pathMap(int id) => '/percorsi/$id/mappa';

  // Temi
  static const String topics = '/temi/';
  static String topicDetail(String id) => '/temi/$id';

  // Achievement
  static const String achievements = '/achievement/';

  // Health
  static const String health = '/health';
}
