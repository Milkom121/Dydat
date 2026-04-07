import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../../core/sizer_extensions.dart';
import '../../../models/quaderno.dart';

/// Card per formula curricolare (da KB del nodo) con rendering LaTeX.
class FormulaCurriculumCard extends StatelessWidget {
  final FormulaCurriculum formula;

  const FormulaCurriculumCard({super.key, required this.formula});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Formula LaTeX centrata con font FISSO per uniformita visiva.
          //
          // Strategia: tutte le formule del quaderno usano lo stesso
          // fontSize (18px logical pixels). Niente FittedBox ne BoxFit:
          // FittedBox ridimensionerebbe in modo diverso ogni formula in
          // base alla sua dimensione intrinseca, rompendo l'uniformita.
          //
          // SingleChildScrollView orizzontale come fallback per le poche
          // formule davvero lunghe che sborderebbero — l'utente puo
          // scorrerle, ma tutte le formule appaiono allo stesso "peso"
          // tipografico.
          //
          // Centrato orizzontalmente quando ci sta, allineato a sinistra
          // quando bisogna scrollare.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Math.tex(
                formula.latex,
                textStyle: TextStyle(
                  fontSize: 18.0,
                  color: theme.colorScheme.onSurface,
                ),
                onErrorFallback: (err) => Text(
                  formula.latex,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),

          // Descrizione sotto la formula
          if (formula.descrizione.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Text(
              formula.descrizione,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
