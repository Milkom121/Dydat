import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/sizer_extensions.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ToolsTrayWidget extends StatelessWidget {
  final ThemeData theme;
  final Function(String) onToolSelected;
  final VoidCallback onClose;

  const ToolsTrayWidget({
    super.key,
    required this.theme,
    required this.onToolSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final tools = [
      {'id': 'calculator', 'icon': 'calculate', 'label': 'Calcolatrice'},
      {'id': 'formulas', 'icon': 'functions', 'label': 'Formule'},
      {'id': 'notes', 'icon': 'note', 'label': 'Note'},
      {'id': 'save', 'icon': 'bookmark', 'label': 'Salva'},
      {'id': 'visualizations', 'icon': 'show_chart', 'label': 'Grafici'},
      {'id': 'voice', 'icon': 'mic', 'label': 'Voce'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 1.h),
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  Text(
                    'Strumenti',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onClose();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),

            // Tools grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 2.h,
                  childAspectRatio: 1.0,
                ),
                itemCount: tools.length,
                itemBuilder: (context, index) {
                  final tool = tools[index];
                  return _buildToolButton(
                    id: tool['id']!,
                    icon: tool['icon']!,
                    label: tool['label']!,
                  );
                },
              ),
            ),
            SizedBox(height: 3.h),

            // Talk to tutor button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onToolSelected('talk');
                  },
                  icon: CustomIconWidget(
                    iconName: 'chat',
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  label: Text(
                    'Parla con il tutor',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                ),
              ),
            ),
            SizedBox(height: 1.h),

            // End session button
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onToolSelected('end');
              },
              child: Text(
                'Termina sessione',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: const Color(0xFFC97070),
                ),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required String id,
    required String icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onToolSelected(id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: theme.colorScheme.primary,
                size: 6.w,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
