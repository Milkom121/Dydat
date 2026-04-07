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

  group('FormulaCurriculum', () {
    test('fromJson con tutti i campi', () {
      final json = {
        'latex': r'a^2 + b^2 = c^2',
        'descrizione': 'Teorema di Pitagora',
      };
      final f = FormulaCurriculum.fromJson(json);
      expect(f.latex, r'a^2 + b^2 = c^2');
      expect(f.descrizione, 'Teorema di Pitagora');
    });

    test('fromJson senza descrizione usa default', () {
      final json = {'latex': 'x = 1', 'descrizione': ''};
      final f = FormulaCurriculum.fromJson(json);
      expect(f.latex, 'x = 1');
      expect(f.descrizione, '');
    });

    test('toJson round-trip', () {
      const f = FormulaCurriculum(latex: 'E=mc^2', descrizione: 'Einstein');
      final json = f.toJson();
      final f2 = FormulaCurriculum.fromJson(json);
      expect(f2.latex, f.latex);
      expect(f2.descrizione, f.descrizione);
    });
  });

  group('ErroreComune', () {
    test('fromJson con tutti i campi', () {
      final json = {
        'tipo': 'concettuale',
        'descrizione': 'Credere che 5-8 dia zero',
        'esempio_sbagliato': '5 - 8 = 0',
        'correzione': '5 - 8 = -3',
        'suggerimento': 'Pensa a debiti',
      };
      final e = ErroreComune.fromJson(json);
      expect(e.tipo, 'concettuale');
      expect(e.descrizione, 'Credere che 5-8 dia zero');
      expect(e.esempioSbagliato, '5 - 8 = 0');
      expect(e.correzione, '5 - 8 = -3');
      expect(e.suggerimento, 'Pensa a debiti');
    });

    test('fromJson con campi opzionali null', () {
      final json = {
        'tipo': 'procedurale',
        'descrizione': 'Errore nel calcolo',
      };
      final e = ErroreComune.fromJson(json);
      expect(e.tipo, 'procedurale');
      expect(e.esempioSbagliato, isNull);
      expect(e.correzione, isNull);
      expect(e.suggerimento, isNull);
    });
  });

  group('SchedaNodo', () {
    test('fromJson completa', () {
      final json = {
        'definizione_testo': 'I numeri interi estendono i naturali',
        'formule': [
          {'latex': 'a - b', 'descrizione': 'Sottrazione'},
        ],
        'esempi': ['5 - 8 = -3', '0 - 1 = -1'],
        'errori_comuni': [
          {
            'tipo': 'concettuale',
            'descrizione': 'Confondere segno',
          },
        ],
        'parole_chiave': ['interi', 'negativi', 'sottrazione'],
      };
      final scheda = SchedaNodo.fromJson(json);
      expect(scheda.definizioneTesto, 'I numeri interi estendono i naturali');
      expect(scheda.formule.length, 1);
      expect(scheda.formule.first.latex, 'a - b');
      expect(scheda.esempi.length, 2);
      expect(scheda.erroriComuni.length, 1);
      expect(scheda.erroriComuni.first.tipo, 'concettuale');
      expect(scheda.paroleChiave, ['interi', 'negativi', 'sottrazione']);
    });

    test('fromJson vuota con default', () {
      final json = <String, dynamic>{};
      final scheda = SchedaNodo.fromJson(json);
      expect(scheda.definizioneTesto, isNull);
      expect(scheda.formule, isEmpty);
      expect(scheda.esempi, isEmpty);
      expect(scheda.erroriComuni, isEmpty);
      expect(scheda.paroleChiave, isEmpty);
    });
  });

  group('NotaUtente', () {
    test('fromJson con tutti i campi', () {
      final json = {
        'testo': 'Ricordare la regola dei segni',
        'updated_at': '2026-04-07T10:00:00Z',
      };
      final nota = NotaUtente.fromJson(json);
      expect(nota.testo, 'Ricordare la regola dei segni');
      expect(nota.updatedAt, '2026-04-07T10:00:00Z');
    });

    test('fromJson senza updated_at', () {
      final json = {'testo': 'Appunto veloce'};
      final nota = NotaUtente.fromJson(json);
      expect(nota.testo, 'Appunto veloce');
      expect(nota.updatedAt, isNull);
    });
  });

  group('QuadernoNodo con scheda e notaUtente', () {
    test('fromJson parsing con scheda e nota', () {
      final json = {
        'nodo_id': 'nodo_1',
        'nodo_nome': 'Numeri interi',
        'tema_nome': 'Algebra',
        'stato': {
          'livello': 'operativo',
          'presunto': false,
          'spiegazione_data': true,
          'esercizi_completati': 3,
        },
        'sessioni_count': 2,
        'esercizi': <dynamic>[],
        'formule': <dynamic>[],
        'spiegazioni': <dynamic>[],
        'scheda': {
          'definizione_testo': 'Testo def',
          'formule': [
            {'latex': 'x^2', 'descrizione': 'Quadrato'},
          ],
          'esempi': ['Esempio 1'],
          'errori_comuni': <dynamic>[],
          'parole_chiave': ['algebra'],
        },
        'nota_utente': {
          'testo': 'Le mie note',
          'updated_at': '2026-04-07T10:00:00Z',
        },
      };
      final q = QuadernoNodo.fromJson(json);
      expect(q.scheda, isNotNull);
      expect(q.scheda!.definizioneTesto, 'Testo def');
      expect(q.scheda!.formule.length, 1);
      expect(q.scheda!.paroleChiave, ['algebra']);
      expect(q.notaUtente, isNotNull);
      expect(q.notaUtente!.testo, 'Le mie note');
    });

    test('fromJson senza scheda e nota (null)', () {
      final json = {
        'nodo_id': 'nodo_2',
        'nodo_nome': 'Test',
        'stato': {'livello': 'non_iniziato'},
        'sessioni_count': 0,
      };
      final q = QuadernoNodo.fromJson(json);
      expect(q.scheda, isNull);
      expect(q.notaUtente, isNull);
    });

    test('copyWith aggiorna notaUtente', () {
      final q = QuadernoNodo(
        nodoId: 'n1',
        nodoNome: 'Test',
        stato: const StatoNodoQuaderno(),
      );
      expect(q.notaUtente, isNull);
      final updated =
          q.copyWith(notaUtente: const NotaUtente(testo: 'Nuova nota'));
      expect(updated.notaUtente, isNotNull);
      expect(updated.notaUtente!.testo, 'Nuova nota');
      // I campi originali restano invariati
      expect(updated.nodoId, 'n1');
      expect(updated.nodoNome, 'Test');
    });
  });
}
