import 'package:flutter/material.dart';

/// Dialog mostrata quando l'app torna in foreground con sessione sospesa.
/// Chiama [onResume] se l'utente sceglie di riprendere, [onTerminate] altrimenti.
void showResumeSessionDialog({
  required BuildContext context,
  required VoidCallback onResume,
  required VoidCallback onTerminate,
}) {
  final theme = Theme.of(context);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        title: Text(
          'Sessione sospesa',
          style: theme.textTheme.titleLarge,
        ),
        content: Text(
          'Vuoi riprendere la sessione di studio?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onTerminate();
            },
            child: Text(
              'No, termina',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onResume();
            },
            child: Text(
              'Riprendi',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// Dialog di conferma terminazione sessione.
/// Chiama [onEnd] se l'utente conferma.
void showEndSessionDialog({
  required BuildContext context,
  required Future<void> Function() onEnd,
}) {
  showDialog(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return AlertDialog(
        title: Text('Termina sessione', style: theme.textTheme.titleLarge),
        content: Text(
          'Sei sicuro di voler terminare questa sessione di studio?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Annulla',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await onEnd();
            },
            child: Text(
              'Termina',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      );
    },
  );
}
