import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/statistiche.dart';

void main() {
  group('PeriodoStats', () {
    final json = {
      'minuti_studio': 120,
      'esercizi_svolti': 15,
      'esercizi_corretti': 12,
      'nodi_completati': 3,
      'giorni_attivi': 5,
    };

    test('fromJson → toJson roundtrip', () {
      final ps = PeriodoStats.fromJson(json);
      expect(ps.minutiStudio, 120);
      expect(ps.eserciziSvolti, 15);
      expect(ps.eserciziCorretti, 12);
      expect(ps.nodiCompletati, 3);
      expect(ps.giorniAttivi, 5);

      final back = ps.toJson();
      expect(back['minuti_studio'], 120);
      expect(back['giorni_attivi'], 5);
    });
  });

  group('StatisticheUtente', () {
    final json = {
      'streak': 7,
      'nodi_completati': 10,
      'sessioni_completate': 5,
      'settimana': {
        'minuti_studio': 60,
        'esercizi_svolti': 8,
        'esercizi_corretti': 6,
        'nodi_completati': 2,
        'giorni_attivi': 3,
      },
      'mese': {
        'minuti_studio': 240,
        'esercizi_svolti': 30,
        'esercizi_corretti': 25,
        'nodi_completati': 8,
        'giorni_attivi': 12,
      },
      'sempre': {
        'minuti_studio': 480,
        'esercizi_svolti': 50,
        'esercizi_corretti': 40,
        'nodi_completati': 10,
        'giorni_attivi': 20,
      },
    };

    test('fromJson → toJson roundtrip', () {
      final s = StatisticheUtente.fromJson(json);
      expect(s.streak, 7);
      expect(s.nodiCompletati, 10);
      expect(s.sessioniCompletate, 5);
      expect(s.settimana.minutiStudio, 60);
      expect(s.mese.eserciziSvolti, 30);
      expect(s.sempre.giorniAttivi, 20);

      final back = s.toJson();
      expect(back['streak'], 7);
      expect(back['nodi_completati'], 10);
      expect(back['sessioni_completate'], 5);
      final settBack = (back['settimana'] as PeriodoStats).toJson();
      expect(settBack['minuti_studio'], 60);
    });
  });
}
