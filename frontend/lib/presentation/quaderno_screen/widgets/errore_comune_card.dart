import 'package:flutter/material.dart';

import '../../../core/sizer_extensions.dart';
import '../../../models/quaderno.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Card per errore comune con accent rosso (error color dal tema).
/// Mostra tipo, descrizione, esempio sbagliato, correzione e suggerimento.
class ErroreComuneCard extends StatelessWidget {
  final ErroreComune errore;

  const ErroreComuneCard({super.key, required this.errore});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icona + tipo
          Row(
            children: [
              CustomIconWidget(
                iconName: 'warning_amber',
                color: theme.colorScheme.error,
                size: 4.5.w,
              ),
              SizedBox(width: 1.5.w),
              Expanded(
                child: Text(
                  errore.tipo,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),

          // Descrizione
          Text(
            errore.descrizione,
            style: theme.textTheme.bodyMedium,
          ),

          // Esempio sbagliato
          if (errore.esempioSbagliato != null &&
              errore.esempioSbagliato!.isNotEmpty) ...[
            SizedBox(height: 1.h),
            _LabeledText(
              label: 'Errore tipico',
              text: errore.esempioSbagliato!,
              labelColor: theme.colorScheme.error,
              theme: theme,
            ),
          ],

          // Correzione
          if (errore.correzione != null &&
              errore.correzione!.isNotEmpty) ...[
            SizedBox(height: 0.8.h),
            _LabeledText(
              label: 'Corretto',
              text: errore.correzione!,
              labelColor: theme.colorScheme.secondary,
              theme: theme,
            ),
          ],

          // Suggerimento
          if (errore.suggerimento != null &&
              errore.suggerimento!.isNotEmpty) ...[
            SizedBox(height: 0.8.h),
            _LabeledText(
              label: 'Suggerimento',
              text: errore.suggerimento!,
              labelColor: theme.colorScheme.primary,
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }
}

/// Testo con etichetta colorata inline.
class _LabeledText extends StatelessWidget {
  final String label;
  final String text;
  final Color labelColor;
  final ThemeData theme;

  const _LabeledText({
    required this.label,
    required this.text,
    required this.labelColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
          TextSpan(
            text: text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
