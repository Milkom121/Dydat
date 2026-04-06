import 'package:flutter/material.dart';

import '../../../core/sizer_extensions.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Record compatto mostrato nel feed dopo che un'azione fullscreen è stata completata.
/// Mostra icona, etichetta e risultato in una riga discreta.
class CompactActionRecord extends StatelessWidget {
  final String actionType;
  final String label;
  final String result;

  const CompactActionRecord({
    super.key,
    required this.actionType,
    required this.label,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (iconName, color) = _iconAndColor(theme);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: color,
              size: 16,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              result,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  (String, Color) _iconAndColor(ThemeData theme) {
    return switch (actionType) {
      'exercise_record' => ('assignment', theme.colorScheme.primary),
      'formula_record' => ('functions', theme.colorScheme.primary),
      'backtrack_record' => ('arrow_back', theme.colorScheme.tertiary),
      _ => ('info', theme.colorScheme.onSurfaceVariant),
    };
  }
}
