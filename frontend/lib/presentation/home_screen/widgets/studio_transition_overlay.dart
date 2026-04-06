import 'package:flutter/material.dart';

import '../../../core/sizer_extensions.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Overlay animato per la transizione Home -> Studio.
/// La mascotte si espande al centro, poi l'overlay svanisce prima della navigazione.
/// Durata totale: ~1.2s (ben sotto il limite di 2s).
///
/// Usa un singolo AnimationController con Interval per la sequenza:
/// - 0.00-0.52: scale-in + fade-in mascotte (600ms)
/// - 0.52-0.65: pausa (150ms)
/// - 0.65-1.00: fade-out tutto (400ms)
class StudioTransitionOverlay extends StatefulWidget {
  /// Callback invocato quando l'animazione è completa (naviga a /studio).
  final VoidCallback onComplete;

  const StudioTransitionOverlay({super.key, required this.onComplete});

  @override
  State<StudioTransitionOverlay> createState() =>
      _StudioTransitionOverlayState();
}

class _StudioTransitionOverlayState extends State<StudioTransitionOverlay>
    with SingleTickerProviderStateMixin {
  // Durata totale: 600 + 150 + 400 = 1150ms
  static const _totalDuration = Duration(milliseconds: 1150);

  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeInAnim;
  late Animation<double> _textFadeAnim;
  late Animation<double> _fadeOutAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration);

    // Intervalli normalizzati su 1150ms totali
    const scaleEnd = 600 / 1150; // ~0.52
    const pauseEnd = 750 / 1150; // ~0.65
    // fadeOut: 0.65 -> 1.0

    _scaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, scaleEnd, curve: Curves.easeOutBack),
      ),
    );

    _fadeInAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, scaleEnd * 0.5, curve: Curves.easeIn),
      ),
    );

    _textFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(scaleEnd * 0.5, scaleEnd, curve: Curves.easeIn),
      ),
    );

    _fadeOutAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(pauseEnd, 1.0, curve: Curves.easeIn),
      ),
    );

    // Quando l'animazione finisce, chiama onComplete.
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        widget.onComplete();
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
        // Opacità complessiva: fade-in all'inizio, fade-out alla fine.
        final overlayOpacity = _fadeInAnim.value * _fadeOutAnim.value;
        return Opacity(
          opacity: overlayOpacity,
          child: Container(
            color: theme.colorScheme.primary.withValues(alpha: 0.92),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mascotte animata
                  Transform.scale(
                    scale: _scaleAnim.value,
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.onPrimary
                            .withValues(alpha: 0.2),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'school',
                          color: theme.colorScheme.onPrimary,
                          size: 14.w,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  // Testo di invito
                  Opacity(
                    opacity: _textFadeAnim.value,
                    child: Text(
                      'Pronti a studiare!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
