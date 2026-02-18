import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/api_response.dart';

void main() {
  group('ApiError', () {
    test('fromJson → toJson roundtrip', () {
      final json = {'detail': 'Credenziali non valide'};
      final err = ApiError.fromJson(json);
      expect(err.detail, 'Credenziali non valide');
      expect(err.toJson(), json);
    });
  });

  group('ApiException', () {
    test('toString includes status and message', () {
      const ex = ApiException(statusCode: 401, message: 'Token non valido');
      expect(ex.toString(), 'ApiException(401): Token non valido');
      expect(ex.statusCode, 401);
      expect(ex.message, 'Token non valido');
    });
  });

  group('SseErrorEvent', () {
    test('fromJson → toJson roundtrip', () {
      final json = {
        'codice': 'llm_error',
        'messaggio': 'Timeout dopo 60s',
      };
      final e = SseErrorEvent.fromJson(json);
      expect(e.codice, 'llm_error');
      expect(e.messaggio, 'Timeout dopo 60s');

      final back = e.toJson();
      expect(back['codice'], 'llm_error');
    });
  });

  group('AchievementEvent', () {
    test('fromJson → toJson roundtrip', () {
      final json = {
        'id': 'primo_nodo',
        'nome': 'Primo passo!',
        'tipo': 'sigillo',
      };
      final e = AchievementEvent.fromJson(json);
      expect(e.id, 'primo_nodo');
      expect(e.nome, 'Primo passo!');
      expect(e.tipo, 'sigillo');

      final back = e.toJson();
      expect(back, json);
    });
  });
}
