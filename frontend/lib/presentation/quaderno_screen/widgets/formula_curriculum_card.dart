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
          // Formula LaTeX centrata
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Math.tex(
                  formula.latex,
                  textStyle: TextStyle(
                    fontSize: 20.sp,
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
