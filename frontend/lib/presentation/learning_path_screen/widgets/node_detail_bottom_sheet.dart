import 'package:flutter/material.dart';
import '../../../core/sizer_extensions.dart';
import '../../../models/percorso.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Bottom sheet dettaglio nodo — placeholder per il Quaderno (B35).
/// Mostra info nodo (nome, livello, esercizi) e un messaggio "Quaderno in arrivo".
class NodeDetailBottomSheet extends StatelessWidget {
  final NodoMappa nodo;

  const NodeDetailBottomSheet({super.key, required this.nodo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateColor = _stateColor(theme, nodo.livello);
    final stateIcon = _stateIcon(nodo.livello);
    final stateLabel = _stateLabel(nodo.livello);

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
              // Handle
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

              // Nome nodo
              Text(
                nodo.nome,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.5.h),

              // Stato e badge
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: stateColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: stateIcon,
                          color: stateColor,
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          stateLabel,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: stateColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (nodo.presunto) ...[
                    SizedBox(width: 2.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Presunto',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 2.h),

              // Info esercizi
              if (nodo.eserciziCompletati > 0)
                Padding(
                  padding: EdgeInsets.only(bottom: 1.5.h),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'assignment_turned_in',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '${nodo.eserciziCompletati} esercizi completati',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

              if (nodo.spiegazioneData)
                Padding(
                  padding: EdgeInsets.only(bottom: 1.5.h),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'menu_book',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Spiegazione completata',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 2.h),

              // Placeholder quaderno (B35)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'auto_stories',
                      color: theme.colorScheme.primary,
                      size: 6.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quaderno',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Appunti, esercizi e formule per questo nodo — in arrivo!',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }

  Color _stateColor(ThemeData theme, String livello) {
    switch (livello) {
      case 'in_corso':
        return theme.colorScheme.primary;
      case 'operativo':
        return theme.colorScheme.secondary;
      case 'comprensivo':
      case 'connesso':
        return theme.colorScheme.tertiary;
      default:
        return theme.colorScheme.outline;
    }
  }

  String _stateIcon(String livello) {
    switch (livello) {
      case 'in_corso':
        return 'timelapse';
      case 'operativo':
        return 'check_circle';
      case 'comprensivo':
      case 'connesso':
        return 'verified';
      default:
        return 'radio_button_unchecked';
    }
  }

  String _stateLabel(String livello) {
    switch (livello) {
      case 'in_corso':
        return 'In corso';
      case 'operativo':
        return 'Operativo';
      case 'comprensivo':
      case 'connesso':
        return 'Comprensivo';
      default:
        return 'Da iniziare';
    }
  }
}
