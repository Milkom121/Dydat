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
            child: _buildContent(theme),
          ),
        ],
      ),
    );
  }

  /// Costruisce il contenuto dell'esempio.
  /// Lo schema tipico degli esempi e: "<formula> (<commento italiano>)".
  /// Quando presente, separiamo formula e commento per renderizzarli
  /// in modi diversi: la formula con Math.tex (o Text plain) a font
  /// leggibile, il commento come Text plain piccolo sotto.
  Widget _buildContent(ThemeData theme) {
    final parts = _splitFormulaAndComment(esempio);
    final corpoFormula = parts.formula;
    final commento = parts.commento;

    final corpo = _looksLikeLaTeX(corpoFormula)
        ? FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Math.tex(
              corpoFormula,
              textStyle: TextStyle(
                fontSize: 18.sp,
                color: theme.colorScheme.onSurface,
              ),
              onErrorFallback: (err) => Text(
                corpoFormula,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          )
        : Text(
            corpoFormula,
            style: theme.textTheme.bodyMedium,
          );

    if (commento == null) {
      return corpo;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        corpo,
        SizedBox(height: 0.5.h),
        Text(
          commento,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// Splitta la stringa in formula + commento finale tra parentesi.
  /// Esempio input: "(-2)^{-3} = \\frac{1}{8} (esponente negativo con base negativa)"
  /// Output: formula="(-2)^{-3} = \\frac{1}{8}", commento="esponente negativo con base negativa"
  ///
  /// La regola: trova l'ULTIMA `(` della stringa, se da li in poi c'e una frase
  /// che si chiude con `)` e contiene almeno una lettera italiana lunga (>= 3 char),
  /// allora e un commento. Altrimenti la stringa intera e la formula.
  static _EsempioParts _splitFormulaAndComment(String s) {
    final lastOpen = s.lastIndexOf('(');
    if (lastOpen == -1) return _EsempioParts(formula: s, commento: null);
    if (!s.endsWith(')')) return _EsempioParts(formula: s, commento: null);
    final inside = s.substring(lastOpen + 1, s.length - 1).trim();
    // Heuristica: il commento e una frase italiana, contiene almeno uno spazio
    // e nessun marcatore LaTeX. Se invece e una formula LaTeX (es. "(-3)^4"
    // termina con `)`), non e un commento.
    if (!inside.contains(' ')) return _EsempioParts(formula: s, commento: null);
    if (_looksLikeLaTeX(inside)) {
      return _EsempioParts(formula: s, commento: null);
    }
    final formula = s.substring(0, lastOpen).trim();
    return _EsempioParts(formula: formula, commento: inside);
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

class _EsempioParts {
  final String formula;
  final String? commento;
  const _EsempioParts({required this.formula, required this.commento});
}
