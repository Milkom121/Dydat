import 'package:flutter/material.dart';
import '../../../core/sizer_extensions.dart';

import '../../../core/app_export.dart';

/// Empty state widget for when no learning path exists
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
            CustomImageWidget(
              imageUrl:
                  'https://images.unsplash.com/photo-1516534775068-ba3e7458af70?w=400&h=400&fit=crop',
              width: 50.w,
              height: 50.w,
              fit: BoxFit.contain,
              semanticLabel:
                  'Illustration of an open book with colorful pages floating upward, representing the beginning of a learning journey',
            ),
            SizedBox(height: 4.h),
            Text(
              'Inizia il Tuo Percorso',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Non hai ancora iniziato nessun percorso di apprendimento. Inizia una sessione di studio per creare il tuo percorso personalizzato.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton(
              onPressed: onStartLearning,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'school',
                    color: theme.colorScheme.onPrimary,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Inizia a Studiare',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
