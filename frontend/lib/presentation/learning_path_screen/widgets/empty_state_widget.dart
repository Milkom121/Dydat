import 'package:flutter/material.dart';
import '../../../core/sizer_extensions.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Empty state widget per quando non esiste ancora un percorso di apprendimento.
class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onStartLearning;

  const EmptyStateWidget({super.key, required this.onStartLearning});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icona nativa al posto dell'immagine esterna
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.map_outlined,
                size: 12.w,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Il tuo percorso ti aspetta',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.5.h),
            Text(
              'Inizia una sessione di studio e costruiremo insieme il tuo percorso personalizzato, passo dopo passo.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            FilledButton.icon(
              onPressed: onStartLearning,
              icon: CustomIconWidget(
                iconName: 'school',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: const Text('Inizia a studiare'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
