import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../../core/sizer_extensions.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Card per un singolo esempio del quaderno.
/// Se l'esempio contiene marcatori LaTeX, tenta il rendering con Math.tex;
/// altrimenti mostra testo plain.
class EsempioInlineCard extends StatelessWidget {
  final String esempio;

  const EsempioInlineCard({super.key, required this.esempio});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomIconWidget(
            iconName: 'arrow_right',
            color: theme.colorScheme.secondary,
            size: 4.5.w,
          ),
          SizedBox(width: 1.5.w),
          Expanded(
            child: _looksLikeLaTeX(esempio)
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Math.tex(
                      esempio,
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        color: theme.colorScheme.onSurface,
                      ),
                      onErrorFallback: (err) => Text(
                        esempio,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                : Text(
                    esempio,
                    style: theme.textTheme.bodyMedium,
                  ),
          ),
        ],
      ),
    );
  }

  /// Riconosce marcatori LaTeX comuni nelle stringhe di esempio.
  static bool _looksLikeLaTeX(String s) {
    return s.contains(r'\\') ||
        s.contains(r'\frac') ||
        s.contains(r'\begin') ||
        s.contains(r'\sqrt') ||
        s.contains(r'\sum') ||
        s.contains(r'\int') ||
        s.contains(r'\cdot') ||
        s.contains('^{') ||
        s.contains('_{');
  }
}
