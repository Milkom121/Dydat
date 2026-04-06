import 'package:flutter/material.dart';

import '../../../core/sizer_extensions.dart';
import '../../../models/quaderno.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Sezione esercizi del quaderno — mostra gli esercizi svolti con esito.
class EserciziSection extends StatelessWidget {
  final List<EsercizioQuaderno> esercizi;
  final int totaleCorretti;
  final int totaleErrati;

  const EserciziSection({
    super.key,
    required this.esercizi,
    required this.totaleCorretti,
    required this.totaleErrati,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titolo sezione + conteggio
        Row(
          children: [
            CustomIconWidget(
              iconName: 'assignment',
              color: theme.colorScheme.secondary,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Esercizi svolti',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            // Badge corretti/errati
            _EsitoBadge(
              count: totaleCorretti,
              icon: 'check_circle',
              color: theme.colorScheme.secondary,
              theme: theme,
            ),
            SizedBox(width: 2.w),
            _EsitoBadge(
              count: totaleErrati,
              icon: 'cancel',
              color: theme.colorScheme.error,
              theme: theme,
            ),
          ],
        ),
        SizedBox(height: 1.5.h),

        // Lista esercizi
        ...esercizi.map((e) => _EsercizioTile(esercizio: e)),
      ],
    );
  }
}

class _EsitoBadge extends StatelessWidget {
  final int count;
  final String icon;
  final Color color;
  final ThemeData theme;

  const _EsitoBadge({
    required this.count,
    required this.icon,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(iconName: icon, color: color, size: 4.w),
        SizedBox(width: 0.5.w),
        Text(
          '$count',
          style: theme.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EsercizioTile extends StatelessWidget {
  final EsercizioQuaderno esercizio;

  const _EsercizioTile({required this.esercizio});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCorretto = esercizio.esito == 'corretto';
    final esitoColor =
        isCorretto ? theme.colorScheme.secondary : theme.colorScheme.error;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: esitoColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icona esito
          CustomIconWidget(
            iconName: isCorretto ? 'check_circle' : 'cancel',
            color: esitoColor,
            size: 5.w,
          ),
          SizedBox(width: 2.w),

          // Contenuto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (esercizio.testo != null)
                  Text(
                    esercizio.testo!,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    if (esercizio.tipo != null) ...[
                      Text(
                        esercizio.tipo!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 2.w),
                    ],
                    if (esercizio.difficolta != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          esercizio.difficolta!.clamp(1, 5),
                          (_) => CustomIconWidget(
                            iconName: 'star',
                            color: theme.colorScheme.tertiary,
                            size: 3.w,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
