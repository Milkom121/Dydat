import 'package:flutter/material.dart';
import '../../../core/sizer_extensions.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Header widget for registration screen with app branding
class RegistrationHeaderWidget extends StatelessWidget {
  const RegistrationHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(height: 2.h),

        // App logo/mascotte placeholder
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'school',
              color: theme.colorScheme.primary,
              size: 10.w,
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // App name
        Text(
          'Dydat',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(height: 1.h),

        // Tagline
        Text(
          'Il tuo tutor AI personale',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
