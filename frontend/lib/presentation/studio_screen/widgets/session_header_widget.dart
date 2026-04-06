import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/sizer_extensions.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Header della schermata studio: mostra nodo corrente e bottone inizia/riprendi.
class SessionHeaderWidget extends StatelessWidget {
  final bool isActive;
  final bool showingHome;
  final String currentNode;
  final bool isLoading;
  final VoidCallback onStart;
  final VoidCallback? onResume;

  const SessionHeaderWidget({
    super.key,
    required this.isActive,
    required this.showingHome,
    required this.currentNode,
    required this.isLoading,
    required this.onStart,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 1.5.h,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'school',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                isActive ? currentNode : 'Pronto per studiare',
                style: isActive
                    ? theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )
                    : theme.textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showingHome && isActive && onResume != null)
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onResume!();
                },
                child: Text(
                  'Riprendi',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            if (!isActive)
              TextButton(
                onPressed: isLoading ? null : onStart,
                child: isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      )
                    : Text(
                        'Inizia',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
