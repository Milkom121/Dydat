import 'package:flutter/material.dart';
import '../../../core/sizer_extensions.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Bottom sheet showing detailed tema information
class TemaDetailBottomSheet extends StatelessWidget {
  final Map<String, dynamic> tema;
  final VoidCallback onStudyPressed;

  const TemaDetailBottomSheet({
    super.key,
    required this.tema,
    required this.onStudyPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = tema["title"] as String;
    final progress = tema["progress"] as double;
    final nodes = tema["nodes"] as List;
    final status = tema["status"] as String;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 10.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progresso Complessivo',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
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
                    theme.colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Nodi di Apprendimento',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: nodes.length,
                separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
                itemBuilder: (context, index) {
                  final node = nodes[index] as Map<String, dynamic>;
                  final nodeName = node["name"] as String;
                  final isCompleted = node["completed"] as bool;

                  return Row(
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? const Color(0xFF7EBF8E).withValues(alpha: 0.2)
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.1,
                                ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: isCompleted
                                ? 'check'
                                : 'radio_button_unchecked',
                            color: isCompleted
                                ? const Color(0xFF7EBF8E)
                                : theme.colorScheme.onSurfaceVariant,
                            size: 4.w,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          nodeName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isCompleted
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: status == 'future' ? null : onStudyPressed,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: status == 'completed'
                            ? 'replay'
                            : 'play_arrow',
                        color: status == 'future'
                            ? theme.colorScheme.onSurface.withValues(
                                alpha: 0.38,
                              )
                            : theme.colorScheme.onPrimary,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        status == 'completed' ? 'Rivedi Tema' : 'Studia Questo',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: status == 'future'
                              ? theme.colorScheme.onSurface.withValues(
                                  alpha: 0.38,
                                )
                              : theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
