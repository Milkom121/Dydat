import 'package:flutter/material.dart';

import '../../../providers/beat_provider.dart';

/// Overlay atmosferico che riflette il beat emotivo corrente.
/// Opacita 0.05-0.15, mai invasivo. Transizioni animate < 500ms.
/// Posizionato come layer sotto il contenuto in uno Stack.
class BeatOverlayWidget extends StatefulWidget {
  final BeatState beat;

  const BeatOverlayWidget({super.key, required this.beat});

  @override
  State<BeatOverlayWidget> createState() => _BeatOverlayWidgetState();
}

class _BeatOverlayWidgetState extends State<BeatOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _applyBeatAnimation(widget.beat);
  }

  @override
  void didUpdateWidget(covariant BeatOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.beat != widget.beat) {
      _applyBeatAnimation(widget.beat);
    }
  }

  void _applyBeatAnimation(BeatState beat) {
    _controller.stop();
    final config = _animConfig(beat);
    _controller.duration = config.cycleDuration;
    _pulseAnimation = Tween<double>(
      begin: config.opacityMin,
      end: config.opacityMax,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (config.shouldRepeat) {
      _controller.repeat(reverse: true);
    } else {
      // Beat transitori: anima una volta e resta
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final config = _beatVisual(widget.beat, cs);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, _) {
        return IgnorePointer(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: config.gradientCenter,
                radius: config.gradientRadius,
                colors: [
                  config.color.withValues(alpha: _pulseAnimation.value),
                  config.color.withValues(alpha: _pulseAnimation.value * 0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Configurazione dell'animazione per ogni beat.
class _BeatAnimConfig {
  final double opacityMin;
  final double opacityMax;
  final Duration cycleDuration;
  final bool shouldRepeat;

  const _BeatAnimConfig({
    required this.opacityMin,
    required this.opacityMax,
    required this.cycleDuration,
    this.shouldRepeat = true,
  });
}

_BeatAnimConfig _animConfig(BeatState beat) => switch (beat) {
      // Accoglienza: glow stabile, pulsazione lenta
      BeatState.accoglienza => const _BeatAnimConfig(
          opacityMin: 0.06,
          opacityMax: 0.09,
          cycleDuration: Duration(milliseconds: 3000),
        ),
      // Spiegazione: quasi impercettibile, non distrae
      BeatState.spiegazione => const _BeatAnimConfig(
          opacityMin: 0.03,
          opacityMax: 0.06,
          cycleDuration: Duration(milliseconds: 2000),
        ),
      // Transizione: micro-burst
      BeatState.transizione => const _BeatAnimConfig(
          opacityMin: 0.05,
          opacityMax: 0.12,
          cycleDuration: Duration(milliseconds: 400),
          shouldRepeat: false,
        ),
      // Attesa: shimmer sottile
      BeatState.attesa => const _BeatAnimConfig(
          opacityMin: 0.04,
          opacityMax: 0.08,
          cycleDuration: Duration(milliseconds: 1200),
        ),
      // Esercizio: focus stabile, il canvas aspetta
      BeatState.esercizio => const _BeatAnimConfig(
          opacityMin: 0.04,
          opacityMax: 0.06,
          cycleDuration: Duration(milliseconds: 4000),
        ),
      // Esito corretto (primo tentativo): burst rapido
      BeatState.esitoCorretto => const _BeatAnimConfig(
          opacityMin: 0.06,
          opacityMax: 0.14,
          cycleDuration: Duration(milliseconds: 800),
          shouldRepeat: false,
        ),
      // Errore: segnale morbido, mai punitivo
      BeatState.esitoErrato => const _BeatAnimConfig(
          opacityMin: 0.03,
          opacityMax: 0.06,
          cycleDuration: Duration(milliseconds: 300),
          shouldRepeat: false,
        ),
      // Corretto dopo guida: diffusione calda, piu lenta
      BeatState.esitoDopoGuida => const _BeatAnimConfig(
          opacityMin: 0.05,
          opacityMax: 0.12,
          cycleDuration: Duration(milliseconds: 1500),
          shouldRepeat: false,
        ),
      // Promozione: il momento piu grande
      BeatState.promozione => const _BeatAnimConfig(
          opacityMin: 0.08,
          opacityMax: 0.15,
          cycleDuration: Duration(milliseconds: 1000),
          shouldRepeat: false,
        ),
      // Chiusura: fading calmo
      BeatState.chiusura => const _BeatAnimConfig(
          opacityMin: 0.04,
          opacityMax: 0.07,
          cycleDuration: Duration(milliseconds: 3500),
        ),
    };

/// Configurazione visiva: colore e posizione gradiente per ogni beat.
class _BeatVisualConfig {
  final Color color;
  final Alignment gradientCenter;
  final double gradientRadius;

  const _BeatVisualConfig({
    required this.color,
    this.gradientCenter = Alignment.center,
    this.gradientRadius = 1.5,
  });
}

_BeatVisualConfig _beatVisual(BeatState beat, ColorScheme cs) => switch (beat) {
      // Accoglienza: ambra caldo dal centro-alto
      BeatState.accoglienza => _BeatVisualConfig(
          color: cs.primary,
          gradientCenter: Alignment.topCenter,
          gradientRadius: 1.8,
        ),
      // Spiegazione: ambra sottile dal centro
      BeatState.spiegazione => _BeatVisualConfig(
          color: cs.primary,
          gradientCenter: Alignment.center,
          gradientRadius: 2.0,
        ),
      // Transizione: ambra leggero dal basso (da dove arriva l'esercizio)
      BeatState.transizione => _BeatVisualConfig(
          color: cs.primary,
          gradientCenter: Alignment.bottomCenter,
          gradientRadius: 1.2,
        ),
      // Attesa: ambra shimmer
      BeatState.attesa => _BeatVisualConfig(
          color: cs.primary,
          gradientCenter: Alignment.center,
          gradientRadius: 1.5,
        ),
      // Esercizio: ambra focus stretto
      BeatState.esercizio => _BeatVisualConfig(
          color: cs.primary,
          gradientCenter: Alignment.center,
          gradientRadius: 1.0,
        ),
      // Esito corretto: verde successo, burst dal centro
      BeatState.esitoCorretto => _BeatVisualConfig(
          color: cs.tertiary, // Verde successo nel tema
          gradientCenter: Alignment.center,
          gradientRadius: 1.2,
        ),
      // Errore: neutro, quasi nulla
      BeatState.esitoErrato => _BeatVisualConfig(
          color: cs.outline,
          gradientCenter: Alignment.center,
          gradientRadius: 1.5,
        ),
      // Dopo guida: ambra caldo, diffusione ampia
      BeatState.esitoDopoGuida => _BeatVisualConfig(
          color: cs.primary,
          gradientCenter: Alignment.center,
          gradientRadius: 2.0,
        ),
      // Promozione: ambra intenso dal centro
      BeatState.promozione => _BeatVisualConfig(
          color: cs.primary,
          gradientCenter: Alignment.center,
          gradientRadius: 1.0,
        ),
      // Chiusura: ambra che si attenua
      BeatState.chiusura => _BeatVisualConfig(
          color: cs.primary,
          gradientCenter: Alignment.topCenter,
          gradientRadius: 2.0,
        ),
    };
