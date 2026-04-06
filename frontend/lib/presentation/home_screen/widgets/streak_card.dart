import 'package:flutter/material.dart';

import '../../../core/sizer_extensions.dart';
import '../../../models/statistiche.dart';

/// Card compatta che mostra streak e ultimo risultato settimanale.
/// Tono positivo: enfatizza continuita e progresso, non punizioni.
class StreakCard extends StatelessWidget {
  final StatisticheUtente stats;

  const StreakCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Streak
          _buildStatItem(
            theme,
            icon: Icons.local_fire_department_rounded,
            iconColor: stats.streak > 0
                ? theme.colorScheme.tertiary
                : theme.colorScheme.outlineVariant,
            value: '${stats.streak}',
            label: stats.streak == 1 ? 'giorno' : 'giorni',
          ),
          SizedBox(width: 4.w),
          // Separatore
          Container(
            width: 1,
            height: 36,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          SizedBox(width: 4.w),
          // Esercizi questa settimana
          _buildStatItem(
            theme,
            icon: Icons.edit_note_rounded,
            iconColor: theme.colorScheme.primary,
            value: '${stats.settimana.eserciziSvolti}',
            label: 'esercizi\nquesta settimana',
          ),
          SizedBox(width: 4.w),
          // Separatore
          Container(
            width: 1,
            height: 36,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          SizedBox(width: 4.w),
          // Nodi completati totali
          _buildStatItem(
            theme,
            icon: Icons.school_rounded,
            iconColor: theme.colorScheme.secondary,
            value: '${stats.nodiCompletati}',
            label: 'nodi\ncompletati',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: iconColor),
              SizedBox(width: 1.w),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.3.h),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
