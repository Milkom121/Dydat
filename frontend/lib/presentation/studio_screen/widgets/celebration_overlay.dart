import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/sse_events.dart';

/// Shows a celebration overlay based on exercise outcome.
///
/// - `primo_tentativo`: particle burst (confetti-like particles explode outward)
/// - `con_guida`: radial glow pulse from center
///
/// Both include haptic feedback. Auto-dismisses after animation completes.
void showCelebrationOverlay(BuildContext context, EsitoEsercizioEvent esito) {
  if (!esito.corretto) return;

  if (esito.primoTentativo) {
    HapticFeedback.heavyImpact();
    _showBurstOverlay(context);
  } else if (esito.conGuida) {
    HapticFeedback.mediumImpact();
    _showGlowOverlay(context);
  }
}

void _showBurstOverlay(BuildContext context) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (ctx) => _BurstAnimation(
      onDone: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

void _showGlowOverlay(BuildContext context) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (ctx) => _GlowAnimation(
      onDone: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

/// Particle burst animation for primo_tentativo.
class _BurstAnimation extends StatefulWidget {
  final VoidCallback onDone;

  const _BurstAnimation({required this.onDone});

  @override
  State<_BurstAnimation> createState() => _BurstAnimationState();
}

class _BurstAnimationState extends State<_BurstAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _particles = List.generate(24, (_) => _Particle(_random));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDone();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return IgnorePointer(
          child: CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _BurstPainter(
              particles: _particles,
              progress: _controller.value,
            ),
          ),
        );
      },
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;

  static const _colors = [
    Color(0xFFFFD700), // gold
    Color(0xFFFFA500), // orange
    Color(0xFF7EBF8E), // green
    Color(0xFF64B5F6), // blue
    Color(0xFFE57373), // red
    Color(0xFFBA68C8), // purple
  ];

  _Particle(Random random)
      : angle = random.nextDouble() * 2 * pi,
        speed = 100 + random.nextDouble() * 300,
        size = 3 + random.nextDouble() * 5,
        color = _colors[random.nextInt(_colors.length)];
}

class _BurstPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _BurstPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final distance = p.speed * progress;
      final x = center.dx + cos(p.angle) * distance;
      final y = center.dy + sin(p.angle) * distance - (50 * progress);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), p.size * (1.0 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

/// Shows a promotion celebration overlay — the biggest reward.
///
/// Full-screen: pulsating trophy icon, node name, 40+ particles,
/// 2500ms duration, double heavyImpact. Auto-dismisses.
void showPromotionCelebration(BuildContext context, PromozioneEvent promo) {
  HapticFeedback.heavyImpact();
  // Double haptic with slight delay
  Future.delayed(const Duration(milliseconds: 200), () {
    HapticFeedback.heavyImpact();
  });

  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (ctx) => _PromotionAnimation(
      nodoNome: promo.nodoNome,
      nodiSbloccati: promo.nodiSbloccati.length,
      onDone: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

/// Full-screen promotion celebration animation.
class _PromotionAnimation extends StatefulWidget {
  final String nodoNome;
  final int nodiSbloccati;
  final VoidCallback onDone;

  const _PromotionAnimation({
    required this.nodoNome,
    required this.nodiSbloccati,
    required this.onDone,
  });

  @override
  State<_PromotionAnimation> createState() => _PromotionAnimationState();
}

class _PromotionAnimationState extends State<_PromotionAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // 48 particles — more intense than exercise burst (24)
    _particles = List.generate(48, (_) => _Particle(_random));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDone();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;
        // Fade in quickly, hold, then fade out
        final overlayOpacity = progress < 0.1
            ? progress / 0.1
            : progress > 0.7
                ? (1.0 - progress) / 0.3
                : 1.0;
        // Trophy scale: pulse in then settle
        final trophyScale = progress < 0.15
            ? 0.5 + (progress / 0.15) * 0.7
            : 1.2 - sin(progress * 3.14 * 2) * 0.08;

        return IgnorePointer(
          child: Stack(
            children: [
              // Dark overlay background
              Positioned.fill(
                child: Container(
                  color: Colors.black
                      .withValues(alpha: 0.4 * overlayOpacity),
                ),
              ),
              // Particle burst
              CustomPaint(
                size: screenSize,
                painter: _BurstPainter(
                  particles: _particles,
                  progress: progress,
                ),
              ),
              // Central trophy + text
              Center(
                child: Opacity(
                  opacity: overlayOpacity.clamp(0.0, 1.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale: trophyScale.clamp(0.0, 2.0),
                        child: Icon(
                          Icons.emoji_events,
                          size: 72,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Concetto completato!',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.nodoNome,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.nodiSbloccati > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${widget.nodiSbloccati} ${widget.nodiSbloccati == 1 ? 'nuovo concetto sbloccato' : 'nuovi concetti sbloccati'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Radial glow animation for con_guida.
class _GlowAnimation extends StatefulWidget {
  final VoidCallback onDone;

  const _GlowAnimation({required this.onDone});

  @override
  State<_GlowAnimation> createState() => _GlowAnimationState();
}

class _GlowAnimationState extends State<_GlowAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDone();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = _glowOpacity(_controller.value);

        return IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8 + _controller.value * 0.4,
                colors: [
                  theme.colorScheme.secondary.withValues(alpha: opacity * 0.3),
                  theme.colorScheme.secondary.withValues(alpha: opacity * 0.1),
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

  /// Glow peaks at 40% then fades out.
  double _glowOpacity(double t) {
    if (t < 0.4) return t / 0.4;
    return 1.0 - ((t - 0.4) / 0.6);
  }
}
