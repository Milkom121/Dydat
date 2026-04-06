import 'package:flutter/material.dart';

import '../../../core/sizer_extensions.dart';
import '../../../models/sse_events.dart';
import './backtrack_card_widget.dart';
import './exercise_card_widget.dart';
import './formula_card_widget.dart';

/// Overlay fullscreen per azioni tutor (esercizi, formule, backtrack).
/// Copre il feed chat e mostra l'azione a tutto schermo con animazione slide-up.
class FullscreenActionOverlay extends StatefulWidget {
  /// Tipo azione: 'exercise', 'formula', 'backtrack'.
  final String actionType;

  /// Evento azione SSE con i dati tipizzati.
  final AzioneEvent action;

  /// Callback invocato quando lo studente risponde all'esercizio.
  final void Function(String risposta) onExerciseVerify;

  /// Callback invocato quando lo studente chiude/accetta/rifiuta.
  final void Function(String resultLabel) onDismiss;

  const FullscreenActionOverlay({
    super.key,
    required this.actionType,
    required this.action,
    required this.onExerciseVerify,
    required this.onDismiss,
  });

  @override
  State<FullscreenActionOverlay> createState() =>
      _FullscreenActionOverlayState();
}

class _FullscreenActionOverlayState extends State<FullscreenActionOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Chiude con animazione inversa, poi chiama il callback.
  Future<void> _closeWithAnimation(String resultLabel) async {
    await _controller.reverse();
    widget.onDismiss(resultLabel);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
        child: SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: _buildActionContent(theme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionContent(ThemeData theme) {
    switch (widget.actionType) {
      case 'exercise':
        final exercise = widget.action.asProponiEsercizio;
        if (exercise == null) return const SizedBox.shrink();
        return ExerciseCardWidget(
          exercise: exercise,
          theme: theme,
          onVerify: (risposta) {
            widget.onExerciseVerify(risposta);
            _closeWithAnimation('completato');
          },
          onDismiss: () => _closeWithAnimation('saltato'),
        );

      case 'formula':
        final formula = widget.action.asMostraFormula;
        if (formula == null) return const SizedBox.shrink();
        return FormulaCardWidget(
          formula: formula,
          theme: theme,
          onDismiss: () => _closeWithAnimation('visto'),
        );

      case 'backtrack':
        final backtrack = widget.action.asSuggerisciBacktrack;
        if (backtrack == null) return const SizedBox.shrink();
        return BacktrackCardWidget(
          suggestion: backtrack,
          theme: theme,
          onAccept: () => _closeWithAnimation('accettato'),
          onDismiss: () => _closeWithAnimation('rifiutato'),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
