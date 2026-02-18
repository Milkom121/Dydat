import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/sizer_extensions.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class MascotteWidget extends StatefulWidget {
  final ThemeData theme;
  final VoidCallback onTap;

  const MascotteWidget({super.key, required this.theme, required this.onTap});

  @override
  State<MascotteWidget> createState() => _MascotteWidgetState();
}

class _MascotteWidgetState extends State<MascotteWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                width: 12.w * _scaleAnimation.value,
                height: 12.w * _scaleAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.theme.colorScheme.primary.withValues(
                    alpha: 0.2 * (1 - _pulseAnimation.value),
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
                    color: const Color(0xFF7EBF8E),
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
    );
  }
}
