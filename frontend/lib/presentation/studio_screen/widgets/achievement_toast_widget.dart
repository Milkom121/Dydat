import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/sizer_extensions.dart';
import '../../../models/sse_events.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Shows an achievement toast overlay that auto-dismisses after 4 seconds.
///
/// Call [showAchievementToast] to display this from any context.
void showAchievementToast(BuildContext context, AchievementEvent achievement) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (ctx) => _AchievementToastOverlay(
      achievement: achievement,
      onDismiss: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

class _AchievementToastOverlay extends StatefulWidget {
  final AchievementEvent achievement;
  final VoidCallback onDismiss;

  const _AchievementToastOverlay({
    required this.achievement,
    required this.onDismiss,
  });

  @override
  State<_AchievementToastOverlay> createState() =>
      _AchievementToastOverlayState();
}

class _AchievementToastOverlayState extends State<_AchievementToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    _autoDismissTimer = Timer(const Duration(seconds: 4), _dismiss);
  }

  void _dismiss() {
    _autoDismissTimer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String _iconForType(String tipo) {
    return switch (tipo) {
      'sigillo' => 'verified',
      'medaglia' => 'military_tech',
      'costellazione' => 'auto_awesome',
      _ => 'emoji_events',
    };
  }

  Color _colorForType(String tipo, ThemeData theme) {
    return switch (tipo) {
      'sigillo' => theme.colorScheme.primary,
      'medaglia' => theme.colorScheme.tertiary,
      'costellazione' => theme.colorScheme.secondary,
      _ => theme.colorScheme.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForType(widget.achievement.tipo, theme);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 1.h,
      left: 4.w,
      right: 4.w,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: _dismiss,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.5.w),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: _iconForType(widget.achievement.tipo),
                        color: color,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Achievement sbloccato!',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            widget.achievement.nome,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
