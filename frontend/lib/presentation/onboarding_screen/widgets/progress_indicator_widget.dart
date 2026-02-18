import 'package:flutter/material.dart';
import '../../../core/sizer_extensions.dart';

/// Widget that displays the onboarding progress bar.
class ProgressIndicatorWidget extends StatelessWidget {
  final double progress;

  const ProgressIndicatorWidget({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 0.5.h,
      color: theme.colorScheme.outline.withValues(alpha: 0.2),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
