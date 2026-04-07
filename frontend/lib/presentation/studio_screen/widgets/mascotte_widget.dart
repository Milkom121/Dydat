import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/sizer_extensions.dart';
import './mascotte_painter.dart';

/// The mascotte's current behavioral state, driven by session context.
enum MascotteState {
  /// Default: gentle pulse, ready for interaction.
  idle,

  /// User is typing or input field is focused.
  listening,

  /// Tutor is streaming a response (SSE active).
  thinking,

  /// A promotion or correct exercise just happened.
  celebrating,

  /// No active session.
  sleeping,
}

class MascotteWidget extends StatefulWidget {
  final ThemeData theme;
  final VoidCallback onTap;
  final MascotteState mascotteState;

  /// Se true, mostra l'animazione "la mascotte apre la porta" (ingresso sessione).
  final bool showEntrance;

  /// Callback quando l'animazione di ingresso e completata.
  final VoidCallback? onEntranceComplete;

  /// Se true, mostra la celebrazione speciale promozione (raggi di luce).
  final bool showPromotionBurst;

  const MascotteWidget({
    super.key,
    required this.theme,
    required this.onTap,
    this.mascotteState = MascotteState.idle,
    this.showEntrance = false,
    this.onEntranceComplete,
    this.showPromotionBurst = false,
  });

  @override
  State<MascotteWidget> createState() => _MascotteWidgetState();
}

class _MascotteWidgetState extends State<MascotteWidget>
    with TickerProviderStateMixin {
  // Animazione principale: pulsazione e wobble continui
  late AnimationController _pulseController;
  late AnimationController _wobbleController;

  // Animazione transizione tra stati (interpolazione visuals)
  late AnimationController _transitionController;
  late MascotteVisuals _currentVisuals;
  late MascotteVisuals _targetVisuals;

  // Animazione ingresso sessione ("la mascotte apre la porta")
  AnimationController? _entranceController;

  // Animazione celebrazione promozione
  AnimationController? _promotionController;

  @override
  void initState() {
    super.initState();

    _currentVisuals = visualsForState(widget.mascotteState);
    _targetVisuals = _currentVisuals;

    // Pulsazione: ciclo lento continuo
    _pulseController = AnimationController(
      vsync: this,
      duration: _pulseDuration(widget.mascotteState),
    )..repeat();

    // Wobble: ciclo separato per deformazione blob
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    // Transizione tra stati visivi (500ms come da spec)
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _transitionController.addListener(_onTransitionTick);

    // Avvia animazione ingresso se richiesta
    if (widget.showEntrance) {
      _startEntrance();
    }

    if (widget.showPromotionBurst) {
      _startPromotionBurst();
    }
  }

  @override
  void didUpdateWidget(covariant MascotteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.mascotteState != widget.mascotteState) {
      _animateToState(widget.mascotteState);
    }

    if (!oldWidget.showEntrance && widget.showEntrance) {
      _startEntrance();
    }

    if (!oldWidget.showPromotionBurst && widget.showPromotionBurst) {
      _startPromotionBurst();
    }
  }

  void _animateToState(MascotteState newState) {
    _currentVisuals = _interpolatedVisuals;
    _targetVisuals = visualsForState(newState);

    _pulseController.duration = _pulseDuration(newState);

    _transitionController.forward(from: 0.0);
  }

  /// Visuals interpolati al momento corrente della transizione.
  MascotteVisuals get _interpolatedVisuals {
    if (!_transitionController.isAnimating && _transitionController.value == 0.0) {
      return _targetVisuals;
    }
    final t = Curves.easeInOut.transform(_transitionController.value);
    return MascotteVisuals.lerp(_currentVisuals, _targetVisuals, t);
  }

  void _onTransitionTick() {
    // Il widget si ricostruisce automaticamente grazie all'AnimatedBuilder
  }

  Duration _pulseDuration(MascotteState state) => switch (state) {
    MascotteState.idle => const Duration(milliseconds: 2000),
    MascotteState.listening => const Duration(milliseconds: 1500),
    MascotteState.thinking => const Duration(milliseconds: 800),
    MascotteState.celebrating => const Duration(milliseconds: 600),
    MascotteState.sleeping => const Duration(milliseconds: 3500),
  };

  void _startEntrance() {
    _entranceController?.dispose();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _entranceController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onEntranceComplete?.call();
      }
    });
    _entranceController!.forward();
  }

  void _startPromotionBurst() {
    _promotionController?.dispose();
    _promotionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _promotionController!.forward();
  }

  /// Opacita globale (sleeping e dimmed).
  double get _widgetOpacity => switch (widget.mascotteState) {
    MascotteState.sleeping => 0.5,
    _ => 1.0,
  };

  @override
  void dispose() {
    _pulseController.dispose();
    _wobbleController.dispose();
    _transitionController.removeListener(_onTransitionTick);
    _transitionController.dispose();
    _entranceController?.dispose();
    _promotionController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mascotteSize = 12.w;
    final primary = widget.theme.colorScheme.primary;
    final onPrimary = widget.theme.colorScheme.onPrimary;

    return Opacity(
      opacity: _widgetOpacity,
      child: Semantics(
        label: 'Mascotte tutor, tocca per aprire gli strumenti',
        button: true,
        child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: SizedBox(
          width: mascotteSize * 2.2, // Spazio per glow
          height: mascotteSize * 2.2,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _pulseController,
              _wobbleController,
              _transitionController,
              if (_entranceController != null) _entranceController!,
              if (_promotionController != null) _promotionController!,
            ]),
            builder: (context, _) {
              final visuals = _interpolatedVisuals;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Animazione ingresso: portale che si apre
                  if (_entranceController != null && _entranceController!.value > 0.0)
                    CustomPaint(
                      size: Size(mascotteSize * 2.2, mascotteSize * 2.2),
                      painter: EntrancePortalPainter(
                        color: primary,
                        progress: _entranceController!.value,
                      ),
                    ),
                  // Celebrazione promozione: raggi di luce
                  if (_promotionController != null && _promotionController!.value > 0.0)
                    CustomPaint(
                      size: Size(mascotteSize * 2.2, mascotteSize * 2.2),
                      painter: PromotionBurstPainter(
                        color: primary,
                        progress: _promotionController!.value,
                      ),
                    ),
                  // Mascotte blob con occhi
                  _buildEntranceTransform(
                    child: CustomPaint(
                      size: Size(mascotteSize, mascotteSize),
                      painter: MascottePainter(
                        visuals: visuals,
                        primaryColor: visuals.baseColor ?? primary,
                        onPrimaryColor: onPrimary,
                        pulseValue: _pulseController.value,
                        wobbleValue: _wobbleController.value,
                      ),
                    ),
                  ),
                  // Badge notifica (angolo alto-destra del blob)
                  Positioned(
                    top: mascotteSize * 0.35,
                    right: mascotteSize * 0.35,
                    child: Container(
                      width: 3.w,
                      height: 3.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.theme.colorScheme.secondary,
                        border: Border.all(
                          color: widget.theme.scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      ),
    );
  }

  /// Se l'animazione ingresso e attiva, scala da 0 a 1 con un leggero bounce.
  Widget _buildEntranceTransform({required Widget child}) {
    if (_entranceController == null || _entranceController!.isCompleted) {
      return child;
    }

    final scaleAnim = CurvedAnimation(
      parent: _entranceController!,
      curve: Curves.elasticOut,
    );

    return Transform.scale(
      scale: scaleAnim.value.clamp(0.0, 1.3),
      child: child,
    );
  }
}
