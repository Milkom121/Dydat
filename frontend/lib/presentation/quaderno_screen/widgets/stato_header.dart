import 'package:flutter/material.dart';

import '../../../core/sizer_extensions.dart';
import '../../../models/quaderno.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Header del quaderno: nome nodo, tema, livello, statistiche sintetiche.
class StatoHeader extends StatelessWidget {
  final QuadernoNodo quaderno;

  const StatoHeader({super.key, required this.quaderno});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stato = quaderno.stato;
    final stateColor = _livelloColor(theme, stato.livello);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tema + livello
          Row(
            children: [
              if (quaderno.temaNome != null) ...[
                Text(
                  quaderno.temaNome!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  width: 1,
                  height: 3.w,
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                SizedBox(width: 2.w),
              ],
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.w,
                  vertical: 0.3.h,
                ),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: _livelloIcon(stato.livello),
                      color: stateColor,
                      size: 3.5.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      _livelloLabel(stato.livello),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: stateColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Statistiche sintetiche
          Row(
            children: [
              _StatChip(
                icon: 'assignment_turned_in',
                label: '${stato.eserciziCompletati} esercizi',
                theme: theme,
              ),
              SizedBox(width: 3.w),
              _StatChip(
                icon: 'history',
                label: '${quaderno.sessioniCount} sessioni',
                theme: theme,
              ),
              if (stato.srRipetizioni > 0) ...[
                SizedBox(width: 3.w),
                _StatChip(
                  icon: 'replay',
                  label: '${stato.srRipetizioni} ripassi',
                  theme: theme,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _livelloColor(ThemeData theme, String livello) {
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

  String _livelloIcon(String livello) {
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

  String _livelloLabel(String livello) {
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

class _StatChip extends StatelessWidget {
  final String icon;
  final String label;
  final ThemeData theme;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: icon,
          color: theme.colorScheme.onSurfaceVariant,
          size: 3.5.w,
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
