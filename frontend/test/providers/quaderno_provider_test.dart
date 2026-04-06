/// Test B35 — QuadernoState e QuadernoNotifier.
///
/// Verifica stato iniziale, copyWith, clearQuaderno.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/quaderno.dart';
import 'package:dydat/providers/quaderno_provider.dart';

QuadernoNodo _quaderno({String nodoId = 'n1'}) => QuadernoNodo(
      nodoId: nodoId,
      nodoNome: 'Test',
      stato: const StatoNodoQuaderno(),
    );

void main() {
  group('QuadernoState', () {
    test('stato iniziale vuoto', () {
      const s = QuadernoState();
      expect(s.quaderno, isNull);
      expect(s.isLoading, false);
      expect(s.error, isNull);
    });

    test('copyWith aggiorna quaderno', () {
      const s = QuadernoState();
      final s2 = s.copyWith(quaderno: _quaderno());
      expect(s2.quaderno, isNotNull);
      expect(s2.quaderno!.nodoId, 'n1');
    });

    test('copyWith isLoading', () {
      const s = QuadernoState();
      final s2 = s.copyWith(isLoading: true);
      expect(s2.isLoading, true);
    });

    test('copyWith clearError azzera errore', () {
      const s = QuadernoState(error: 'Qualcosa');
      final s2 = s.copyWith(clearError: true);
      expect(s2.error, isNull);
    });

    test('copyWith clearQuaderno resetta quaderno', () {
      final s = QuadernoState(quaderno: _quaderno());
      final s2 = s.copyWith(clearQuaderno: true);
      expect(s2.quaderno, isNull);
    });

    test('copyWith mantiene valori precedenti se non specificati', () {
      final s = QuadernoState(quaderno: _quaderno(), isLoading: true);
      final s2 = s.copyWith(isLoading: false);
      expect(s2.quaderno, isNotNull);
      expect(s2.isLoading, false);
    });
  });
}
