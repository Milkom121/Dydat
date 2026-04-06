import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../../core/sizer_extensions.dart';
import '../../../models/quaderno.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Sezione formule del quaderno — mostra le formule mostrate dal tutor.
class FormuleSection extends StatelessWidget {
  final List<FormulaQuaderno> formule;

  const FormuleSection({super.key, required this.formule});

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
              iconName: 'functions',
              color: theme.colorScheme.primary,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Formule',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              '(${formule.length})',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),

        // Lista formule
        ...formule.map((f) => _FormulaCard(formula: f)),
      ],
    );
  }
}

class _FormulaCard extends StatelessWidget {
  final FormulaQuaderno formula;

  const _FormulaCard({required this.formula});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titolo
          Text(
            formula.titolo,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 1.h),

          // Formula LaTeX
          if (formula.formula.isNotEmpty)
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  formula.formula,
                  textStyle: TextStyle(
                    fontSize: 16.sp,
                    color: theme.colorScheme.onSurface,
                  ),
                  onErrorFallback: (err) => Text(
                    formula.formula,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),

          // Spiegazione
          if (formula.spiegazione.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Text(
              formula.spiegazione,
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
