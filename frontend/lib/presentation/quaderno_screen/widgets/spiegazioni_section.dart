import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../core/sizer_extensions.dart';
import '../../../models/quaderno.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Sezione spiegazioni del quaderno — mostra le spiegazioni chiave del tutor.
class SpiegazioniSection extends StatelessWidget {
  final List<SpiegazioneQuaderno> spiegazioni;

  const SpiegazioniSection({super.key, required this.spiegazioni});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titolo sezione
        Row(
          children: [
            CustomIconWidget(
              iconName: 'menu_book',
              color: theme.colorScheme.tertiary,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Spiegazioni del tutor',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              '(${spiegazioni.length})',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),

        // Lista spiegazioni
        ...spiegazioni.map((s) => _SpiegazioneCard(spiegazione: s)),
      ],
    );
  }
}

class _SpiegazioneCard extends StatefulWidget {
  final SpiegazioneQuaderno spiegazione;

  const _SpiegazioneCard({required this.spiegazione});

  @override
  State<_SpiegazioneCard> createState() => _SpiegazioneCardState();
}

class _SpiegazioneCardState extends State<_SpiegazioneCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contenuto = widget.spiegazione.contenuto;
    // Mostra solo le prime 200 char se non espanso
    final isLong = contenuto.length > 200;
    final displayText =
        _expanded || !isLong ? contenuto : '${contenuto.substring(0, 200)}...';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarkdownBody(
            data: displayText,
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              p: theme.textTheme.bodyMedium,
            ),
            shrinkWrap: true,
          ),
          if (isLong) ...[
            SizedBox(height: 0.5.h),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? 'Mostra meno' : 'Mostra tutto',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
