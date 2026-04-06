/// Test B31 — Home Calda con Ritorno Intelligente.
///
/// Verifica le funzioni helper pure esposte da home_screen.dart:
/// - homeCalcolaStreak: streak di giorni consecutivi
/// - homeGiorniDaUltimaSessione: giorni dall'ultima sessione
/// - homeFormatNodeName: formattazione nome nodo
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/sessione.dart';
import 'package:dydat/presentation/home_screen/home_screen.dart';

// Helper per costruire SessioneListItem con data specifica.
SessioneListItem _sessione({
  required String id,
  required String createdAt,
  String stato = 'completata',
  String? nodoFocaleNome,
  int? durataEffettivaMin,
  List<String>? nodiLavorati,
}) =>
    SessioneListItem(
      id: id,
      stato: stato,
      createdAt: createdAt,
      nodoFocaleNome: nodoFocaleNome,
      durataEffettivaMin: durataEffettivaMin,
      nodiLavorati: nodiLavorati,
    );

String _isoDate(DateTime dt) => dt.toIso8601String();

void main() {
  group('homeCalcolaStreak', () {
    test('streak 0 se nessuna sessione', () {
      expect(homeCalcolaStreak([]), 0);
    });

    test('streak 1 se solo oggi', () {
      final oggi = DateTime.now();
      final history = [_sessione(id: 's1', createdAt: _isoDate(oggi))];
      expect(homeCalcolaStreak(history), 1);
    });

    test('streak 1 se solo ieri', () {
      final ieri = DateTime.now().subtract(const Duration(days: 1));
      final history = [_sessione(id: 's1', createdAt: _isoDate(ieri))];
      expect(homeCalcolaStreak(history), 1);
    });

    test('streak 0 se ultima sessione 2+ giorni fa', () {
      final duegiorni = DateTime.now().subtract(const Duration(days: 2));
      final history = [_sessione(id: 's1', createdAt: _isoDate(duegiorni))];
      expect(homeCalcolaStreak(history), 0);
    });

    test('streak conta giorni consecutivi incluso oggi', () {
      final oggi = DateTime.now();
      final ieri = oggi.subtract(const Duration(days: 1));
      final laltroieri = oggi.subtract(const Duration(days: 2));
      final history = [
        _sessione(id: 's1', createdAt: _isoDate(oggi)),
        _sessione(id: 's2', createdAt: _isoDate(ieri)),
        _sessione(id: 's3', createdAt: _isoDate(laltroieri)),
      ];
      expect(homeCalcolaStreak(history), 3);
    });

    test('streak si interrompe se c\'è un gap', () {
      final oggi = DateTime.now();
      final ieri = oggi.subtract(const Duration(days: 1));
      final tregiorni = oggi.subtract(const Duration(days: 3));
      // Manca 2 giorni fa — streak si interrompe dopo ieri
      final history = [
        _sessione(id: 's1', createdAt: _isoDate(oggi)),
        _sessione(id: 's2', createdAt: _isoDate(ieri)),
        _sessione(id: 's3', createdAt: _isoDate(tregiorni)),
      ];
      expect(homeCalcolaStreak(history), 2);
    });

    test('più sessioni nello stesso giorno contano come 1 giorno streak', () {
      final oggi = DateTime.now();
      final ieri = oggi.subtract(const Duration(days: 1));
      final history = [
        _sessione(id: 's1', createdAt: _isoDate(oggi)),
        _sessione(id: 's2', createdAt: _isoDate(oggi)),
        _sessione(id: 's3', createdAt: _isoDate(ieri)),
      ];
      expect(homeCalcolaStreak(history), 2);
    });

    test('streak 0 se lista vuota', () {
      expect(homeCalcolaStreak([]), 0);
    });
  });

  group('homeGiorniDaUltimaSessione', () {
    test('null se nessuna sessione', () {
      expect(homeGiorniDaUltimaSessione([]), isNull);
    });

    test('0 se ultima sessione oggi', () {
      final history = [
        _sessione(id: 's1', createdAt: _isoDate(DateTime.now())),
      ];
      expect(homeGiorniDaUltimaSessione(history), 0);
    });

    test('7 se ultima sessione 7 giorni fa', () {
      final settegiornifa = DateTime.now().subtract(const Duration(days: 7));
      final history = [
        _sessione(id: 's1', createdAt: _isoDate(settegiornifa)),
      ];
      expect(homeGiorniDaUltimaSessione(history), 7);
    });

    test('null se createdAt è null', () {
      final history = [
        const SessioneListItem(id: 's1', stato: 'completata'),
      ];
      expect(homeGiorniDaUltimaSessione(history), isNull);
    });

    test('usa la prima sessione della lista (più recente)', () {
      final oggi = DateTime.now();
      final settimana = oggi.subtract(const Duration(days: 7));
      final history = [
        _sessione(id: 's1', createdAt: _isoDate(oggi)),
        _sessione(id: 's2', createdAt: _isoDate(settimana)),
      ];
      // Deve usare s1 (oggi), non s2
      expect(homeGiorniDaUltimaSessione(history), 0);
    });
  });

  group('homeFormatNodeName', () {
    test('null se input null', () {
      expect(homeFormatNodeName(null), isNull);
    });

    test('restituisce stringa invariata se no underscore', () {
      expect(homeFormatNodeName('Frazioni'), 'Frazioni');
    });

    test('formatta ID nodo con underscore: primo char maiuscolo', () {
      final result = homeFormatNodeName(
          'mat_MatematicaC3_Algebra1_numeri_relativi');
      expect(result, isNotNull);
      expect(result!.isNotEmpty, isTrue);
      expect(result[0], equals(result[0].toUpperCase()));
    });

    test('nodo semplice con un underscore', () {
      final result = homeFormatNodeName('mat_frazioni');
      expect(result, isNotNull);
      expect(result!.isNotEmpty, isTrue);
    });

    test('stringa vuota dopo split restituisce raw', () {
      // Edge case: underscore solo
      final result = homeFormatNodeName('_');
      expect(result, isNotNull);
    });
  });
}
