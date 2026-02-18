import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sizer_extensions.dart';

import '../../../core/app_export.dart';
import '../../../models/tema.dart';
import '../../../models/percorso.dart';
import '../../../providers/path_provider.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Bottom sheet showing detailed tema information with nodes from API.
class TemaDetailBottomSheet extends ConsumerStatefulWidget {
  final Tema tema;
  final VoidCallback onStudyPressed;

  const TemaDetailBottomSheet({
    super.key,
    required this.tema,
    required this.onStudyPressed,
  });

  @override
  ConsumerState<TemaDetailBottomSheet> createState() =>
      _TemaDetailBottomSheetState();
}

class _TemaDetailBottomSheetState
    extends ConsumerState<TemaDetailBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Load detail for this tema (nodes list)
    Future.microtask(() {
      ref.read(pathProvider.notifier).loadTopicDetail(widget.tema.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pathState = ref.watch(pathProvider);
    final detail = pathState.currentTopicDetail;
    final progress = widget.tema.nodiTotali > 0
        ? widget.tema.nodiCompletati / widget.tema.nodiTotali
        : 0.0;
    final isCompleted = widget.tema.completato;
    final hasProgress = widget.tema.nodiCompletati > 0;

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
                widget.tema.nome,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.tema.nodiCompletati}/${widget.tema.nodiTotali} nodi',
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
              // Show nodes from detail if loaded, otherwise loading indicator
              if (detail != null && detail.id == widget.tema.id)
                _buildNodesList(theme, detail.nodi)
              else if (pathState.isLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: SizedBox(
                      width: 6.w,
                      height: 6.w,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (pathState.error != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Text(
                    pathState.error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (!hasProgress && !isCompleted) ? null : widget.onStudyPressed,
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
                        iconName: isCompleted ? 'replay' : 'play_arrow',
                        color: (!hasProgress && !isCompleted)
                            ? theme.colorScheme.onSurface.withValues(
                                alpha: 0.38,
                              )
                            : theme.colorScheme.onPrimary,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        isCompleted ? 'Rivedi Tema' : 'Studia Questo',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: (!hasProgress && !isCompleted)
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

  Widget _buildNodesList(ThemeData theme, List<NodoMappa> nodi) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: nodi.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
      itemBuilder: (context, index) {
        final node = nodi[index];
        // A node is "completed" if its level is operativo or higher
        final isCompleted = node.livello == 'operativo' ||
            node.livello == 'comprensivo' ||
            node.livello == 'connesso';

        return Row(
          children: [
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF7EBF8E).withValues(alpha: 0.2)
                    : theme.colorScheme.outline.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: isCompleted ? 'check' : 'radio_button_unchecked',
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
                node.nome,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isCompleted
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                  decoration:
                      isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
