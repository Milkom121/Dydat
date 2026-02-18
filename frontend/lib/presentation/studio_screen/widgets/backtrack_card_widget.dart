import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/sizer_extensions.dart';
import '../../../models/sse_events.dart';
import '../../../widgets/custom_icon_widget.dart';

class BacktrackCardWidget extends StatelessWidget {
  final SuggerisciBacktrackAction suggestion;
  final ThemeData theme;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  const BacktrackCardWidget({
    super.key,
    required this.suggestion,
    required this.theme,
    required this.onAccept,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = theme.colorScheme.tertiary;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: accentColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Suggerimento di ripasso',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onDismiss();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info_outline',
                  color: accentColor,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    suggestion.motivo,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onDismiss();
                  },
                  child: Text(
                    'Continua qui',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onAccept();
                  },
                  child: Text(
                    'Ok, rivediamolo',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
