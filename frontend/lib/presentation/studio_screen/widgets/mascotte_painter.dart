import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import './mascotte_widget.dart';

/// Parametri visivi della mascotte per ogni beat/stato.
/// Controllano forma, occhi, glow e colore.
class MascotteVisuals {
  /// Quanto il blob si deforma (0.0 = cerchio, 1.0 = molto organico).
  final double blobDeformation;

  /// Scala globale del blob (1.0 = normale).
  final double scale;

  /// Apertura occhi (0.0 = chiusi, 1.0 = normali, 1.5 = grandi).
  final double eyeOpenness;

  /// Offset verticale delle pupille (-1.0 = su, 0.0 = centro, 1.0 = giu).
  final double pupilOffsetY;

  /// Raggio del glow esterno (moltiplicatore del raggio blob).
  final double glowRadius;

  /// Opacita del glow (0.0 - 0.6).
  final double glowOpacity;

  /// Colore base della mascotte (null = usa primary dal tema).
  final Color? baseColor;

  /// Colore glow (null = uguale a baseColor).
  final Color? glowColor;

  const MascotteVisuals({
    this.blobDeformation = 0.3,
    this.scale = 1.0,
    this.eyeOpenness = 1.0,
    this.pupilOffsetY = 0.0,
    this.glowRadius = 1.6,
    this.glowOpacity = 0.2,
    this.baseColor,
    this.glowColor,
  });

  /// Interpola tra due configurazioni visive.
  static MascotteVisuals lerp(MascotteVisuals a, MascotteVisuals b, double t) {
    return MascotteVisuals(
      blobDeformation: ui.lerpDouble(a.blobDeformation, b.blobDeformation, t)!,
      scale: ui.lerpDouble(a.scale, b.scale, t)!,
      eyeOpenness: ui.lerpDouble(a.eyeOpenness, b.eyeOpenness, t)!,
      pupilOffsetY: ui.lerpDouble(a.pupilOffsetY, b.pupilOffsetY, t)!,
      glowRadius: ui.lerpDouble(a.glowRadius, b.glowRadius, t)!,
      glowOpacity: ui.lerpDouble(a.glowOpacity, b.glowOpacity, t)!,
      baseColor: Color.lerp(a.baseColor, b.baseColor, t),
      glowColor: Color.lerp(a.glowColor, b.glowColor, t),
    );
  }
}

/// Visuals per ogni MascotteState — secondo tabella direzione visiva v2 sezione 5.
MascotteVisuals visualsForState(MascotteState state) => switch (state) {
  // Idle / accoglienza: forma rilassata, glow caldo stabile, occhi dolci
  MascotteState.idle => const MascotteVisuals(
    blobDeformation: 0.25,
    scale: 1.0,
    eyeOpenness: 0.9,
    pupilOffsetY: 0.0,
    glowRadius: 1.5,
    glowOpacity: 0.2,
  ),
  // Listening / transizione+esercizio: curiosa, occhi aperti
  MascotteState.listening => const MascotteVisuals(
    blobDeformation: 0.3,
    scale: 1.02,
    eyeOpenness: 1.2,
    pupilOffsetY: -0.15,
    glowRadius: 1.4,
    glowOpacity: 0.18,
  ),
  // Thinking / spiegazione+attesa: concentrata, forma stabile
  MascotteState.thinking => const MascotteVisuals(
    blobDeformation: 0.15,
    scale: 0.98,
    eyeOpenness: 0.8,
    pupilOffsetY: 0.1,
    glowRadius: 1.6,
    glowOpacity: 0.25,
  ),
  // Celebrating / esito corretto, promozione: brilla, occhi grandi
  MascotteState.celebrating => const MascotteVisuals(
    blobDeformation: 0.4,
    scale: 1.12,
    eyeOpenness: 1.5,
    pupilOffsetY: -0.1,
    glowRadius: 2.0,
    glowOpacity: 0.45,
  ),
  // Sleeping / chiusura: rilassata, occhi quasi chiusi
  MascotteState.sleeping => const MascotteVisuals(
    blobDeformation: 0.2,
    scale: 0.95,
    eyeOpenness: 0.15,
    pupilOffsetY: 0.2,
    glowRadius: 1.2,
    glowOpacity: 0.08,
  ),
};

/// CustomPainter che renderizza la mascotte come blob organico con occhi espressivi.
/// Ispirato a 22 di Soul (Pixar): forma amorfa, luminescente, occhi minimi.
class MascottePainter extends CustomPainter {
  final MascotteVisuals visuals;
  final Color primaryColor;
  final Color onPrimaryColor;

  /// Valore animazione pulsazione (0.0 - 1.0, ciclico).
  final double pulseValue;

  /// Valore animazione deformazione blob (0.0 - 1.0, ciclico).
  final double wobbleValue;

  MascottePainter({
    required this.visuals,
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.pulseValue,
    required this.wobbleValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) / 2 * 0.75;
    final radius = baseRadius * visuals.scale;

    _drawGlow(canvas, center, radius);
    _drawBlob(canvas, center, radius);
    _drawEyes(canvas, center, radius);
  }

  /// Glow esterno ambra — luminescenza della creatura di luce.
  void _drawGlow(Canvas canvas, Offset center, double radius) {
    if (visuals.glowOpacity <= 0.01) return;

    final glowR = radius * visuals.glowRadius;
    final glowColor = visuals.glowColor ?? primaryColor;

    // Pulsazione morbida del glow
    final pulseScale = 1.0 + 0.08 * math.sin(pulseValue * math.pi * 2);
    final effectiveGlowR = glowR * pulseScale;

    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        effectiveGlowR,
        [
          glowColor.withValues(alpha: visuals.glowOpacity * 0.8),
          glowColor.withValues(alpha: visuals.glowOpacity * 0.3),
          glowColor.withValues(alpha: 0.0),
        ],
        [0.0, 0.5, 1.0],
      );

    canvas.drawCircle(center, effectiveGlowR, glowPaint);
  }

  /// Corpo blob organico con curve di Bezier.
  void _drawBlob(Canvas canvas, Offset center, double radius) {
    final path = _buildBlobPath(center, radius);

    // Gradiente radiale per profondita — piu chiaro al centro
    final bodyPaint = Paint()
      ..shader = ui.Gradient.radial(
        center + Offset(0, -radius * 0.15), // luce dall'alto
        radius * 1.2,
        [
          _lighten(visuals.baseColor ?? primaryColor, 0.25),
          visuals.baseColor ?? primaryColor,
          _darken(visuals.baseColor ?? primaryColor, 0.15),
        ],
        [0.0, 0.6, 1.0],
      );

    canvas.drawPath(path, bodyPaint);

    // Bordo luminoso sottile
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = (visuals.baseColor ?? primaryColor).withValues(alpha: 0.4);
    canvas.drawPath(path, borderPaint);
  }

  /// Genera il path del blob con N punti controllati da curve di Bezier cubiche.
  /// La deformazione varia con wobbleValue per dare vita alla forma.
  Path _buildBlobPath(Offset center, double radius) {
    const int points = 8; // Numero di punti di controllo
    final deform = visuals.blobDeformation;

    final path = Path();
    final List<Offset> blobPoints = [];

    // Genera punti deformati attorno al centro
    for (int i = 0; i < points; i++) {
      final angle = (i / points) * math.pi * 2;
      // Deformazione unica per punto, varia con wobbleValue
      final noise = math.sin(angle * 2 + wobbleValue * math.pi * 2) * deform +
          math.cos(angle * 3 - wobbleValue * math.pi * 1.5) * deform * 0.5;
      final r = radius * (1.0 + noise * 0.15);
      blobPoints.add(Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      ));
    }

    // Curve di Bezier cubiche smooth tra i punti
    path.moveTo(blobPoints[0].dx, blobPoints[0].dy);
    for (int i = 0; i < points; i++) {
      final p0 = blobPoints[i];
      final p1 = blobPoints[(i + 1) % points];
      final p2 = blobPoints[(i + 2) % points];
      final pPrev = blobPoints[(i - 1 + points) % points];

      // Tangenti smooth
      final cp1 = Offset(
        p0.dx + (p1.dx - pPrev.dx) / 4,
        p0.dy + (p1.dy - pPrev.dy) / 4,
      );
      final cp2 = Offset(
        p1.dx - (p2.dx - p0.dx) / 4,
        p1.dy - (p2.dy - p0.dy) / 4,
      );

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
    }

    path.close();
    return path;
  }

  /// Occhi espressivi — il canale emotivo principale della mascotte.
  void _drawEyes(Canvas canvas, Offset center, double radius) {
    final eyeOpenness = visuals.eyeOpenness.clamp(0.0, 2.0);
    if (eyeOpenness < 0.05) return; // Occhi chiusi

    final eyeSpacing = radius * 0.35;
    final eyeY = center.dy - radius * 0.08;
    final leftEyeCenter = Offset(center.dx - eyeSpacing, eyeY);
    final rightEyeCenter = Offset(center.dx + eyeSpacing, eyeY);

    final eyeWidth = radius * 0.2;
    final eyeHeight = eyeWidth * eyeOpenness.clamp(0.0, 1.5) * 0.7;

    // Se gli occhi sono quasi chiusi, disegna linea
    if (eyeOpenness < 0.3) {
      final linePaint = Paint()
        ..color = onPrimaryColor.withValues(alpha: 0.7)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final halfW = eyeWidth * 0.7;
      canvas.drawLine(
        Offset(leftEyeCenter.dx - halfW, leftEyeCenter.dy),
        Offset(leftEyeCenter.dx + halfW, leftEyeCenter.dy),
        linePaint,
      );
      canvas.drawLine(
        Offset(rightEyeCenter.dx - halfW, rightEyeCenter.dy),
        Offset(rightEyeCenter.dx + halfW, rightEyeCenter.dy),
        linePaint,
      );
      return;
    }

    _drawSingleEye(canvas, leftEyeCenter, eyeWidth, eyeHeight);
    _drawSingleEye(canvas, rightEyeCenter, eyeWidth, eyeHeight);
  }

  void _drawSingleEye(Canvas canvas, Offset center, double w, double h) {
    // Sclera (bianco/crema) — ovale
    final scleraPaint = Paint()
      ..color = onPrimaryColor.withValues(alpha: 0.9);

    final scleraRect = Rect.fromCenter(center: center, width: w, height: h);
    canvas.drawOval(scleraRect, scleraPaint);

    // Pupilla — segue lo stato emotivo (pupilOffsetY)
    final pupilRadius = w * 0.32;
    final pupilOffset = Offset(
      center.dx,
      center.dy + h * 0.15 * visuals.pupilOffsetY,
    );
    final pupilPaint = Paint()
      ..color = const Color(0xFF1A1A2E); // Scuro profondo
    canvas.drawCircle(pupilOffset, pupilRadius, pupilPaint);

    // Riflesso di luce — da vita
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85);
    final highlightOffset = Offset(
      pupilOffset.dx - pupilRadius * 0.35,
      pupilOffset.dy - pupilRadius * 0.35,
    );
    canvas.drawCircle(highlightOffset, pupilRadius * 0.3, highlightPaint);
  }

  /// Schiarisce un colore.
  Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  /// Scurisce un colore.
  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(covariant MascottePainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.wobbleValue != wobbleValue ||
        oldDelegate.visuals != visuals ||
        oldDelegate.primaryColor != primaryColor;
  }
}

/// Painter per l'animazione di celebrazione promozione.
/// Raggi di luce che si espandono dal centro della mascotte.
class PromotionBurstPainter extends CustomPainter {
  final Color color;
  final double progress; // 0.0 - 1.0

  PromotionBurstPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.max(size.width, size.height) * 0.8;

    // Raggi di luce
    const int rays = 12;
    final rayLength = maxRadius * progress;
    final opacity = (1.0 - progress).clamp(0.0, 1.0) * 0.6;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < rays; i++) {
      final angle = (i / rays) * math.pi * 2;
      final innerR = maxRadius * 0.2 * progress;
      final start = Offset(
        center.dx + innerR * math.cos(angle),
        center.dy + innerR * math.sin(angle),
      );
      final end = Offset(
        center.dx + rayLength * math.cos(angle),
        center.dy + rayLength * math.sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }

    // Cerchio centrale che si espande
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color.withValues(alpha: opacity * 0.5);
    canvas.drawCircle(center, rayLength * 0.6, ringPaint);
  }

  @override
  bool shouldRepaint(covariant PromotionBurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Painter per l'animazione "la mascotte ti apre la porta" (ingresso sessione).
/// Cerchi concentrici che si espandono, come un portale che si apre.
class EntrancePortalPainter extends CustomPainter {
  final Color color;
  final double progress; // 0.0 - 1.0

  EntrancePortalPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.max(size.width, size.height) * 0.6;

    // 3 cerchi concentrici con timing sfalsato
    for (int i = 0; i < 3; i++) {
      final delay = i * 0.15;
      final ringProgress = ((progress - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      if (ringProgress <= 0.0) continue;

      final radius = maxRadius * ringProgress;
      final opacity = (1.0 - ringProgress) * 0.3;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 - i * 0.5
        ..color = color.withValues(alpha: opacity);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant EntrancePortalPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
