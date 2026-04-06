import 'package:flutter/material.dart';

import '../../../core/sizer_extensions.dart';
import '../../../models/ripasso.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Sezione ripasso FSRS migliorata graficamente.
/// Mostra il conteggio dei nodi da ripassare con lista nomi nodi
/// e un bottone per avviare la sessione di ripasso.
class RipassoSection extends StatelessWidget {
  final List<NodoRipasso> nodi;
  final VoidCallback onRipassoTap;

  const RipassoSection({
    super.key,
    required this.nodi,
    required this.onRipassoTap,
  });

  @override
  Widget build(BuildContext context) {
    if (nodi.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final totale = nodi.length;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'replay',
                color: theme.colorScheme.onTertiaryContainer,
                size: 22,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totale ${totale == 1 ? 'nodo' : 'nodi'} da ripassare',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Rinforza la tua memoria con una sessione breve',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer
                            .withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Lista nomi nodi (massimo 3, poi "e altri N")
          if (nodi.isNotEmpty) ...[
            SizedBox(height: 1.5.h),
            _buildNodeList(theme),
          ],
          SizedBox(height: 1.5.h),
          // Bottone ripasso
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: onRipassoTap,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.tertiary,
                foregroundColor: theme.colorScheme.onTertiary,
                padding: EdgeInsets.symmetric(vertical: 1.2.h),
              ),
              child: const Text('Inizia ripasso'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeList(ThemeData theme) {
    final maxShow = 3;
    final visible = nodi.take(maxShow).toList();
    final remaining = nodi.length - maxShow;

    return Wrap(
      spacing: 2.w,
      runSpacing: 0.5.h,
      children: [
        for (final nodo in visible)
          _buildChip(theme, nodo.nodoNome),
        if (remaining > 0)
          _buildChip(theme, 'e ${remaining == 1 ? 'un altro' : 'altri $remaining'}'),
      ],
    );
  }

  Widget _buildChip(ThemeData theme, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.onTertiaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}
