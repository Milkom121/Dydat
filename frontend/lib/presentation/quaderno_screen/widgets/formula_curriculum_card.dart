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
          // Formula LaTeX centrata, rimpicciolita per stare nella card
          // Nota: niente SingleChildScrollView attorno a FittedBox — uno
          // scroll view orizzontale ha larghezza infinita, quindi FittedBox
          // non saprebbe quanto rimpicciolire. FittedBox deve ricevere
          // direttamente i constraint del Container (width double.infinity).
          //
          // Font 18.sp scelto per uniformita visiva: la maggior parte
          // delle formule del curriculum ci sta comoda a 18.sp, quindi
          // FittedBox NON le rimpicciolisce e tutte appaiono allo stesso
          // font. Solo le formule davvero lunghe vengono scalate giu.
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Math.tex(
                formula.latex,
                textStyle: TextStyle(
                  fontSize: 18.sp,
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
