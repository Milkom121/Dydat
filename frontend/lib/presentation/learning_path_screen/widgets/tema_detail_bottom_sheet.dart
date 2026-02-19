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
        final nodeState = _getNodeState(node.livello);

        return Row(
          children: [
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: _nodeCircleColor(theme, nodeState),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _nodeIcon(nodeState),
                  color: _nodeIconColor(theme, nodeState),
                  size: 4.w,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      node.nome,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: nodeState == _NodeState.nonIniziato
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (node.presunto) ...[
                    SizedBox(width: 2.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 1.5.w,
                        vertical: 0.3.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'presunto',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  _NodeState _getNodeState(String livello) {
    switch (livello) {
      case 'in_corso':
        return _NodeState.inCorso;
      case 'operativo':
      case 'comprensivo':
      case 'connesso':
        return _NodeState.completato;
      default:
        return _NodeState.nonIniziato;
    }
  }

  Color _nodeCircleColor(ThemeData theme, _NodeState state) {
    switch (state) {
      case _NodeState.nonIniziato:
        return theme.colorScheme.outline.withValues(alpha: 0.1);
      case _NodeState.inCorso:
        return theme.colorScheme.primary.withValues(alpha: 0.15);
      case _NodeState.completato:
        return theme.colorScheme.secondary.withValues(alpha: 0.2);
    }
  }

  Color _nodeIconColor(ThemeData theme, _NodeState state) {
    switch (state) {
      case _NodeState.nonIniziato:
        return theme.colorScheme.outline;
      case _NodeState.inCorso:
        return theme.colorScheme.primary;
      case _NodeState.completato:
        return theme.colorScheme.secondary;
    }
  }

  String _nodeIcon(_NodeState state) {
    switch (state) {
      case _NodeState.nonIniziato:
        return 'radio_button_unchecked';
      case _NodeState.inCorso:
        return 'timelapse';
      case _NodeState.completato:
        return 'check_circle';
    }
  }
}

enum _NodeState { nonIniziato, inCorso, completato }
