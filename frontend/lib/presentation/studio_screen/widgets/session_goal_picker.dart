import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/sizer_extensions.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Opzioni di durata obiettivo per la sessione.
enum SessionGoal {
  veloce(label: 'Veloce', descrizione: '15 minuti — ideale per un ripasso rapido', iconName: 'flash_on', durataMsMin: 15),
  normale(label: 'Normale', descrizione: '30 minuti — una sessione standard', iconName: 'school', durataMsMin: 30),
  approfondita(label: 'Approfondita', descrizione: '60 minuti — per studiare con calma', iconName: 'auto_stories', durataMsMin: 60);

  const SessionGoal({
    required this.label,
    required this.descrizione,
    required this.iconName,
    required this.durataMsMin,
  });

  final String label;
  final String descrizione;
  final String iconName;
  // Nome abbreviato per evitare conflitti con flutter Duration
  final int durataMsMin;
}

/// Dialog per la scelta dell'obiettivo di sessione (durata).
/// Restituisce [SessionGoal] o null se annullato.
class SessionGoalPicker extends StatefulWidget {
  const SessionGoalPicker({super.key});

  @override
  State<SessionGoalPicker> createState() => _SessionGoalPickerState();
}

class _SessionGoalPickerState extends State<SessionGoalPicker> {
  SessionGoal _selected = SessionGoal.normale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Come vuoi studiare oggi?',
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Scegli il tempo che hai a disposizione',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          ...SessionGoal.values.map((goal) => _buildGoalTile(theme, goal)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(
            'Salta',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        FilledButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop(_selected);
          },
          child: const Text('Inizia'),
        ),
      ],
    );
  }

  Widget _buildGoalTile(ThemeData theme, SessionGoal goal) {
    final isSelected = _selected == goal;
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selected = goal);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: goal.iconName,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 22,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      goal.descrizione,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mostra il [SessionGoalPicker] come dialog e restituisce la [SessionGoal] scelta.
/// Restituisce null se l'utente annulla o esce senza scegliere.
Future<SessionGoal?> showSessionGoalPicker(BuildContext context) {
  return showDialog<SessionGoal>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const SessionGoalPicker(),
  );
}
