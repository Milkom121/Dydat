import 'package:flutter/material.dart';
import '../../../core/sizer_extensions.dart';

import '../../../core/app_export.dart';
import '../../../models/tema.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Individual tema card with visual state indicators.
/// Accepts a [Tema] model from the API instead of raw Map data.
class TemaCardWidget extends StatelessWidget {
  final Tema tema;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const TemaCardWidget({
    super.key,
    required this.tema,
    required this.isCurrent,
    required this.onTap,
    this.onLongPress,
  });

  /// Derive visual status from Tema model fields.
  String _deriveStatus() {
    if (tema.completato) return 'completed';
    if (tema.nodiCompletati > 0) return 'current';
    return 'future';
  }

  /// Derive progress (0.0 - 1.0) from Tema model fields.
  double _deriveProgress() {
    if (tema.nodiTotali == 0) return 0.0;
    return tema.nodiCompletati / tema.nodiTotali;
  }

  Color _getStatusColor(BuildContext context, String status) {
    final theme = Theme.of(context);
    switch (status) {
      case 'completed':
        return const Color(0xFF7EBF8E);
      case 'current':
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.surface;
    }
  }

  Widget _buildFogOverlay(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.scaffoldBackgroundColor.withValues(alpha: 0.3),
            theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _deriveStatus();
    final progress = _deriveProgress();
    final title = tema.nome;
    final isFuture = status == 'future';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 18.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: isCurrent
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: theme.colorScheme.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            context,
                            status,
                          ).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: status == 'completed'
                                ? 'check_circle'
                                : status == 'current'
                                    ? 'play_circle_filled'
                                    : 'lock',
                            color: _getStatusColor(context, status),
                            size: 5.w,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isFuture
                                ? theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  )
                                : theme.colorScheme.onSurface,
                            fontWeight: isCurrent
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${tema.nodiCompletati}/${tema.nodiTotali} nodi',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: _getStatusColor(context, status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 1.h,
                          backgroundColor: theme.colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getStatusColor(context, status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isFuture) _buildFogOverlay(context),
          ],
        ),
      ),
    );
  }
}
