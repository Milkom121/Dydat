import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/utente.dart';

void main() {
  group('Utente', () {
    final json = {
      'id': '550e8400-e29b-41d4-a716-446655440000',
      'email': 'mario@test.com',
      'nome': 'Mario',
      'preferenze_tutor': {'input': 'voce', 'velocita': 'lento'},
      'contesto_personale': {'obiettivo': 'esame analisi 1'},
      'materie_attive': ['matematica'],
      'obiettivo_giornaliero_min': 30,
    };

    test('fromJson → toJson roundtrip', () {
      final utente = Utente.fromJson(json);
      expect(utente.id, '550e8400-e29b-41d4-a716-446655440000');
      expect(utente.email, 'mario@test.com');
      expect(utente.nome, 'Mario');
      expect(utente.preferenzeTutor!['input'], 'voce');
      expect(utente.contestoPersonale!['obiettivo'], 'esame analisi 1');
      expect(utente.materieAttive, ['matematica']);
      expect(utente.obiettvoGiornalieroMin, 30);

      final backToJson = utente.toJson();
      expect(backToJson['id'], json['id']);
      expect(backToJson['email'], json['email']);
      expect(backToJson['obiettivo_giornaliero_min'], 30);
    });

    test('fromJson with nulls', () {
      final minimal = {
        'id': 'abc-123',
        'obiettivo_giornaliero_min': 20,
      };
      final utente = Utente.fromJson(minimal);
      expect(utente.id, 'abc-123');
      expect(utente.email, isNull);
      expect(utente.nome, isNull);
      expect(utente.preferenzeTutor, isNull);
      expect(utente.materieAttive, isNull);
      expect(utente.obiettvoGiornalieroMin, 20);
    });
  });

  group('PreferenzeStudio', () {
    test('fromJson → toJson roundtrip', () {
      final json = {
        'input': 'testo',
        'velocita': 'normale',
        'incoraggiamento': 'alto',
      };
      final pref = PreferenzeStudio.fromJson(json);
      expect(pref.input, 'testo');
      expect(pref.velocita, 'normale');
      expect(pref.incoraggiamento, 'alto');

      final back = pref.toJson();
      expect(back['input'], 'testo');
      expect(back['velocita'], 'normale');
    });
  });

  group('LoginRequest', () {
    test('fromJson → toJson roundtrip', () {
      final json = {'email': 'a@b.com', 'password': 'secret'};
      final req = LoginRequest.fromJson(json);
      expect(req.email, 'a@b.com');
      expect(req.password, 'secret');

      final back = req.toJson();
      expect(back, json);
    });
  });

  group('LoginResponse', () {
    test('fromJson → toJson roundtrip', () {
      final json = {'access_token': 'eyJ...', 'token_type': 'bearer'};
      final resp = LoginResponse.fromJson(json);
      expect(resp.accessToken, 'eyJ...');
      expect(resp.tokenType, 'bearer');

      final back = resp.toJson();
      expect(back['access_token'], 'eyJ...');
      expect(back['token_type'], 'bearer');
    });
  });

  group('RegisterRequest', () {
    test('fromJson → toJson roundtrip', () {
      final json = {
        'email': 'a@b.com',
        'password': 'secret',
        'nome': 'Mario',
        'utente_temp_id': 'temp-uuid',
      };
      final req = RegisterRequest.fromJson(json);
      expect(req.email, 'a@b.com');
      expect(req.nome, 'Mario');
      expect(req.utenteTempId, 'temp-uuid');

      final back = req.toJson();
      expect(back['utente_temp_id'], 'temp-uuid');
    });

    test('fromJson without utente_temp_id', () {
      final json = {
        'email': 'a@b.com',
        'password': 'secret',
        'nome': 'Mario',
      };
      final req = RegisterRequest.fromJson(json);
      expect(req.utenteTempId, isNull);
    });
  });
}
