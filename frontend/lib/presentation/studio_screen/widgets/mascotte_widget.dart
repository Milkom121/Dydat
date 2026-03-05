import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/sizer_extensions.dart';

import '../../../widgets/custom_icon_widget.dart';

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

  const MascotteWidget({
    super.key,
    required this.theme,
    required this.onTap,
    this.mascotteState = MascotteState.idle,
  });

  @override
  State<MascotteWidget> createState() => _MascotteWidgetState();
}

class _MascotteWidgetState extends State<MascotteWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    _applyStateAnimation(widget.mascotteState);
  }

  @override
  void didUpdateWidget(covariant MascotteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mascotteState != widget.mascotteState) {
      _applyStateAnimation(widget.mascotteState);
    }
  }

  void _applyStateAnimation(MascotteState state) {
    _animationController.stop();
    switch (state) {
      case MascotteState.idle:
        _animationController.duration = const Duration(milliseconds: 2000);
        _animationController.repeat(reverse: true);
      case MascotteState.listening:
        _animationController.duration = const Duration(milliseconds: 1500);
        _animationController.repeat(reverse: true);
      case MascotteState.thinking:
        _animationController.duration = const Duration(milliseconds: 800);
        _animationController.repeat(reverse: true);
      case MascotteState.celebrating:
        _animationController.duration = const Duration(milliseconds: 600);
        _animationController.repeat(reverse: true);
      case MascotteState.sleeping:
        _animationController.duration = const Duration(milliseconds: 3500);
        _animationController.repeat(reverse: true);
    }
  }

  /// Scale range depends on state.
  double get _scaleBegin => switch (widget.mascotteState) {
        MascotteState.idle => 1.0,
        MascotteState.listening => 1.0,
        MascotteState.thinking => 0.95,
        MascotteState.celebrating => 1.0,
        MascotteState.sleeping => 1.0,
      };

  double get _scaleEnd => switch (widget.mascotteState) {
        MascotteState.idle => 1.08,
        MascotteState.listening => 1.05,
        MascotteState.thinking => 1.12,
        MascotteState.celebrating => 1.18,
        MascotteState.sleeping => 1.03,
      };

  /// Opacity of the outer pulse ring.
  double get _pulseOpacity => switch (widget.mascotteState) {
        MascotteState.idle => 0.2,
        MascotteState.listening => 0.25,
        MascotteState.thinking => 0.35,
        MascotteState.celebrating => 0.45,
        MascotteState.sleeping => 0.08,
      };

  /// Overall opacity of the widget (sleeping is dimmed).
  double get _widgetOpacity => switch (widget.mascotteState) {
        MascotteState.sleeping => 0.5,
        _ => 1.0,
      };

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaleAnim = Tween<double>(begin: _scaleBegin, end: _scaleEnd).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    final pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    return Opacity(
      opacity: _widgetOpacity,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Pulse effect
                Container(
                  width: 12.w * scaleAnim.value,
                  height: 12.w * scaleAnim.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.theme.colorScheme.primary.withValues(
                      alpha: _pulseOpacity * (1 - pulseAnim.value),
                    ),
                  ),
                ),
                // Main mascotte circle
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.theme.colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: widget.theme.colorScheme.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'school',
                      color: widget.theme.colorScheme.onPrimary,
                      size: 6.w,
                    ),
                  ),
                ),
                // Notification badge
                Positioned(
                  top: 0,
                  right: 0,
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
    );
  }
}
