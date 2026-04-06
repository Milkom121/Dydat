import 'package:flutter_test/flutter_test.dart';

import 'package:dydat/providers/beat_provider.dart';
import 'package:dydat/presentation/studio_screen/widgets/mascotte_widget.dart';
import 'package:dydat/presentation/studio_screen/widgets/session_sync_helper.dart';

void main() {
  group('mascotteStateFromBeat', () {
    test('accoglienza -> idle', () {
      expect(mascotteStateFromBeat(BeatState.accoglienza), MascotteState.idle);
    });

    test('spiegazione -> thinking', () {
      expect(mascotteStateFromBeat(BeatState.spiegazione), MascotteState.thinking);
    });

    test('transizione -> listening', () {
      expect(mascotteStateFromBeat(BeatState.transizione), MascotteState.listening);
    });

    test('attesa -> thinking', () {
      expect(mascotteStateFromBeat(BeatState.attesa), MascotteState.thinking);
    });

    test('esercizio -> listening', () {
      expect(mascotteStateFromBeat(BeatState.esercizio), MascotteState.listening);
    });

    test('esitoCorretto -> celebrating', () {
      expect(mascotteStateFromBeat(BeatState.esitoCorretto), MascotteState.celebrating);
    });

    test('esitoErrato -> idle (incoraggiante, mai punitivo)', () {
      expect(mascotteStateFromBeat(BeatState.esitoErrato), MascotteState.idle);
    });

    test('esitoDopoGuida -> celebrating', () {
      expect(mascotteStateFromBeat(BeatState.esitoDopoGuida), MascotteState.celebrating);
    });

    test('promozione -> celebrating', () {
      expect(mascotteStateFromBeat(BeatState.promozione), MascotteState.celebrating);
    });

    test('chiusura -> sleeping', () {
      expect(mascotteStateFromBeat(BeatState.chiusura), MascotteState.sleeping);
    });

    test('tutti i beat sono mappati (switch exhaustive)', () {
      // Se compila e non lancia, la copertura e completa
      for (final beat in BeatState.values) {
        final result = mascotteStateFromBeat(beat);
        expect(result, isA<MascotteState>());
      }
    });
  });
}
