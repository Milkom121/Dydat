/// Test B35 — Modello QuadernoNodo e sotto-modelli.
///
/// Verifica fromJson, toJson, computed properties.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/quaderno.dart';

void main() {
  group('QuadernoNodo', () {
    test('fromJson parsing completo', () {
      final json = {
        'nodo_id': 'nodo_1',
        'nodo_nome': 'Equazioni lineari',
        'tema_nome': 'Algebra',
        'stato': {
          'livello': 'operativo',
          'presunto': false,
          'spiegazione_data': true,
          'esercizi_completati': 5,
          'sr_prossimo_ripasso': '2026-04-10T10:00:00Z',
          'sr_ripetizioni': 2,
          'ultima_interazione': '2026-04-06T14:00:00Z',
        },
        'sessioni_count': 3,
        'esercizi': [
          {
            'id': 1,
            'esercizio_id': 'es_1',
            'esito': 'corretto',
            'testo': 'Risolvi 2x = 4',
            'tipo': 'algebrico',
            'difficolta': 2,
            'data': '2026-04-06T14:00:00Z',
          },
          {
            'id': 2,
            'esercizio_id': 'es_2',
            'esito': 'errato',
            'testo': 'Risolvi 3x + 1 = 10',
            'tipo': 'algebrico',
            'difficolta': 3,
            'data': '2026-04-06T14:05:00Z',
          },
        ],
        'formule': [
          {
            'titolo': 'Formula risolutiva',
            'formula': 'x = -b/2a',
            'spiegazione': 'Si usa per...',
            'data': '2026-04-06T14:00:00Z',
          },
        ],
        'spiegazioni': [
          {
            'contenuto': 'Le equazioni lineari sono...',
            'sessione_id': 'sess_1',
            'data': '2026-04-06T14:00:00Z',
          },
        ],
      };

      final quaderno = QuadernoNodo.fromJson(json);
      expect(quaderno.nodoId, 'nodo_1');
      expect(quaderno.nodoNome, 'Equazioni lineari');
      expect(quaderno.temaNome, 'Algebra');
      expect(quaderno.stato.livello, 'operativo');
      expect(quaderno.stato.eserciziCompletati, 5);
      expect(quaderno.stato.srRipetizioni, 2);
      expect(quaderno.sessioniCount, 3);
      expect(quaderno.esercizi.length, 2);
      expect(quaderno.formule.length, 1);
      expect(quaderno.spiegazioni.length, 1);
    });

    test('eserciziCorretti e eserciziErrati calcolati', () {
      final quaderno = QuadernoNodo(
        nodoId: 'n1',
        nodoNome: 'Test',
        stato: const StatoNodoQuaderno(),
        esercizi: const [
          EsercizioQuaderno(id: 1, esito: 'corretto'),
          EsercizioQuaderno(id: 2, esito: 'corretto'),
          EsercizioQuaderno(id: 3, esito: 'errato'),
        ],
      );
      expect(quaderno.eserciziCorretti, 2);
      expect(quaderno.eserciziErrati, 1);
    });

    test('quaderno vuoto ha 0 esercizi corretti', () {
      final quaderno = QuadernoNodo(
        nodoId: 'n1',
        nodoNome: 'Test',
        stato: const StatoNodoQuaderno(),
      );
      expect(quaderno.eserciziCorretti, 0);
      expect(quaderno.eserciziErrati, 0);
    });
  });

  group('StatoNodoQuaderno', () {
    test('valori default', () {
      const stato = StatoNodoQuaderno();
      expect(stato.livello, 'non_iniziato');
      expect(stato.presunto, false);
      expect(stato.spiegazioneData, false);
      expect(stato.eserciziCompletati, 0);
      expect(stato.srProssimoRipasso, isNull);
      expect(stato.srRipetizioni, 0);
    });
  });

  group('FormulaQuaderno', () {
    test('fromJson con tutti i campi', () {
      final json = {
        'titolo': 'F = ma',
        'formula': 'F = ma',
        'spiegazione': 'Seconda legge di Newton',
        'data': '2026-04-06T14:00:00Z',
      };
      final formula = FormulaQuaderno.fromJson(json);
      expect(formula.titolo, 'F = ma');
      expect(formula.formula, 'F = ma');
      expect(formula.spiegazione, 'Seconda legge di Newton');
    });
  });

  group('SpiegazioneQuaderno', () {
    test('fromJson con tutti i campi', () {
      final json = {
        'contenuto': 'Le equazioni...',
        'sessione_id': 'sess_abc',
        'data': '2026-04-06T14:00:00Z',
      };
      final spiegazione = SpiegazioneQuaderno.fromJson(json);
      expect(spiegazione.contenuto, 'Le equazioni...');
      expect(spiegazione.sessioneId, 'sess_abc');
    });
  });
}
