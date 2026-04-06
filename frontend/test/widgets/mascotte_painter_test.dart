import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dydat/presentation/studio_screen/widgets/mascotte_painter.dart';
import 'package:dydat/presentation/studio_screen/widgets/mascotte_widget.dart';

void main() {
  group('MascotteVisuals', () {
    test('lerp interpola correttamente tra due configurazioni', () {
      const a = MascotteVisuals(
        blobDeformation: 0.0,
        scale: 1.0,
        eyeOpenness: 0.0,
        pupilOffsetY: -1.0,
        glowRadius: 1.0,
        glowOpacity: 0.0,
      );
      const b = MascotteVisuals(
        blobDeformation: 1.0,
        scale: 2.0,
        eyeOpenness: 1.0,
        pupilOffsetY: 1.0,
        glowRadius: 2.0,
        glowOpacity: 1.0,
      );

      final mid = MascotteVisuals.lerp(a, b, 0.5);
      expect(mid.blobDeformation, closeTo(0.5, 0.001));
      expect(mid.scale, closeTo(1.5, 0.001));
      expect(mid.eyeOpenness, closeTo(0.5, 0.001));
      expect(mid.pupilOffsetY, closeTo(0.0, 0.001));
      expect(mid.glowRadius, closeTo(1.5, 0.001));
      expect(mid.glowOpacity, closeTo(0.5, 0.001));
    });

    test('lerp a t=0 restituisce primo valore', () {
      const a = MascotteVisuals(scale: 1.0);
      const b = MascotteVisuals(scale: 2.0);
      final result = MascotteVisuals.lerp(a, b, 0.0);
      expect(result.scale, closeTo(1.0, 0.001));
    });

    test('lerp a t=1 restituisce secondo valore', () {
      const a = MascotteVisuals(scale: 1.0);
      const b = MascotteVisuals(scale: 2.0);
      final result = MascotteVisuals.lerp(a, b, 1.0);
      expect(result.scale, closeTo(2.0, 0.001));
    });

    test('lerp gestisce colori null', () {
      const a = MascotteVisuals(baseColor: null);
      const b = MascotteVisuals(baseColor: Colors.amber);
      final mid = MascotteVisuals.lerp(a, b, 0.5);
      // Color.lerp con null restituisce una versione semi-trasparente
      expect(mid.baseColor, isNotNull);
    });
  });

  group('visualsForState', () {
    test('tutti gli stati producono visuals validi', () {
      for (final state in MascotteState.values) {
        final v = visualsForState(state);
        expect(v.blobDeformation, greaterThanOrEqualTo(0.0));
        expect(v.scale, greaterThan(0.0));
        expect(v.eyeOpenness, greaterThanOrEqualTo(0.0));
        expect(v.glowRadius, greaterThan(0.0));
        expect(v.glowOpacity, greaterThanOrEqualTo(0.0));
      }
    });

    test('celebrating ha scala e glow piu alti di idle', () {
      final idle = visualsForState(MascotteState.idle);
      final celebrating = visualsForState(MascotteState.celebrating);
      expect(celebrating.scale, greaterThan(idle.scale));
      expect(celebrating.glowOpacity, greaterThan(idle.glowOpacity));
      expect(celebrating.eyeOpenness, greaterThan(idle.eyeOpenness));
    });

    test('sleeping ha occhi quasi chiusi e glow basso', () {
      final sleeping = visualsForState(MascotteState.sleeping);
      expect(sleeping.eyeOpenness, lessThan(0.3));
      expect(sleeping.glowOpacity, lessThan(0.1));
    });

    test('thinking ha deformazione bassa (forma stabile)', () {
      final thinking = visualsForState(MascotteState.thinking);
      expect(thinking.blobDeformation, lessThanOrEqualTo(0.2));
    });
  });

  group('MascottePainter', () {
    test('paint non lancia eccezioni per tutti gli stati', () {
      for (final state in MascotteState.values) {
        final painter = MascottePainter(
          visuals: visualsForState(state),
          primaryColor: Colors.amber,
          onPrimaryColor: Colors.white,
          pulseValue: 0.5,
          wobbleValue: 0.3,
        );

        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);
        // Nessuna eccezione attesa
        painter.paint(canvas, const Size(100, 100));
        recorder.endRecording();
      }
    });

    test('shouldRepaint rileva cambio di pulseValue', () {
      final v = visualsForState(MascotteState.idle);
      final a = MascottePainter(
        visuals: v, primaryColor: Colors.amber,
        onPrimaryColor: Colors.white, pulseValue: 0.0, wobbleValue: 0.0,
      );
      final b = MascottePainter(
        visuals: v, primaryColor: Colors.amber,
        onPrimaryColor: Colors.white, pulseValue: 0.5, wobbleValue: 0.0,
      );
      expect(a.shouldRepaint(b), isTrue);
    });

    test('shouldRepaint rileva cambio di wobbleValue', () {
      final v = visualsForState(MascotteState.idle);
      final a = MascottePainter(
        visuals: v, primaryColor: Colors.amber,
        onPrimaryColor: Colors.white, pulseValue: 0.0, wobbleValue: 0.0,
      );
      final b = MascottePainter(
        visuals: v, primaryColor: Colors.amber,
        onPrimaryColor: Colors.white, pulseValue: 0.0, wobbleValue: 0.5,
      );
      expect(a.shouldRepaint(b), isTrue);
    });

    test('shouldRepaint false con stessi parametri', () {
      final v = visualsForState(MascotteState.idle);
      final a = MascottePainter(
        visuals: v, primaryColor: Colors.amber,
        onPrimaryColor: Colors.white, pulseValue: 0.5, wobbleValue: 0.3,
      );
      final b = MascottePainter(
        visuals: v, primaryColor: Colors.amber,
        onPrimaryColor: Colors.white, pulseValue: 0.5, wobbleValue: 0.3,
      );
      expect(a.shouldRepaint(b), isFalse);
    });

    test('paint con glow opacity 0 non lancia eccezioni', () {
      final painter = MascottePainter(
        visuals: const MascotteVisuals(glowOpacity: 0.0),
        primaryColor: Colors.amber,
        onPrimaryColor: Colors.white,
        pulseValue: 0.0,
        wobbleValue: 0.0,
      );
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(80, 80));
      recorder.endRecording();
    });

    test('paint con eyeOpenness 0 (occhi chiusi) non lancia', () {
      final painter = MascottePainter(
        visuals: const MascotteVisuals(eyeOpenness: 0.0),
        primaryColor: Colors.amber,
        onPrimaryColor: Colors.white,
        pulseValue: 0.0,
        wobbleValue: 0.0,
      );
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(80, 80));
      recorder.endRecording();
    });

    test('paint con eyeOpenness bassa (linea) non lancia', () {
      final painter = MascottePainter(
        visuals: const MascotteVisuals(eyeOpenness: 0.15),
        primaryColor: Colors.amber,
        onPrimaryColor: Colors.white,
        pulseValue: 0.0,
        wobbleValue: 0.0,
      );
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(80, 80));
      recorder.endRecording();
    });
  });

  group('PromotionBurstPainter', () {
    test('paint non lancia per vari progress', () {
      for (final p in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        final painter = PromotionBurstPainter(
          color: Colors.amber,
          progress: p,
        );
        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);
        painter.paint(canvas, const Size(100, 100));
        recorder.endRecording();
      }
    });

    test('shouldRepaint rileva cambio progress', () {
      final a = PromotionBurstPainter(color: Colors.amber, progress: 0.0);
      final b = PromotionBurstPainter(color: Colors.amber, progress: 0.5);
      expect(a.shouldRepaint(b), isTrue);
    });
  });

  group('EntrancePortalPainter', () {
    test('paint non lancia per vari progress', () {
      for (final p in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        final painter = EntrancePortalPainter(
          color: Colors.amber,
          progress: p,
        );
        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);
        painter.paint(canvas, const Size(100, 100));
        recorder.endRecording();
      }
    });

    test('shouldRepaint rileva cambio progress', () {
      final a = EntrancePortalPainter(color: Colors.amber, progress: 0.0);
      final b = EntrancePortalPainter(color: Colors.amber, progress: 0.5);
      expect(a.shouldRepaint(b), isTrue);
    });
  });
}
