import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/sizer_extensions.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TutorPanelWidget extends StatefulWidget {
  final ThemeData theme;
  final VoidCallback onClose;

  const TutorPanelWidget({super.key, required this.theme, required this.onClose});

  @override
  State<TutorPanelWidget> createState() => _TutorPanelWidgetState();
}

class _TutorPanelWidgetState extends State<TutorPanelWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.fastOutSlowIn,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tutorModes = [
      {
        'id': 'explain',
        'icon': 'lightbulb',
        'title': 'Spiegazione',
        'description': 'Ricevi una spiegazione dettagliata del concetto',
      },
      {
        'id': 'example',
        'icon': 'description',
        'title': 'Esempio',
        'description': 'Vedi un esempio pratico risolto passo dopo passo',
      },
      {
        'id': 'practice',
        'icon': 'fitness_center',
        'title': 'Esercizio',
        'description': 'Prova a risolvere un esercizio guidato',
      },
      {
        'id': 'review',
        'icon': 'replay',
        'title': 'Ripasso',
        'description': 'Rivedi i concetti fondamentali',
      },
    ];

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: 85.w,
        height: double.infinity,
        decoration: BoxDecoration(
          color: widget.theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: widget.theme.colorScheme.shadow,
              blurRadius: 16,
              offset: const Offset(-4, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    IconButton(
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: widget.theme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onClose();
                      },
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Modalità tutor',
                      style: widget.theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                color: widget.theme.colorScheme.outline.withValues(alpha: 0.2),
                height: 1,
              ),

              // Tutor modes list
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(4.w),
                  itemCount: tutorModes.length,
                  separatorBuilder: (context, index) => SizedBox(height: 2.h),
                  itemBuilder: (context, index) {
                    final mode = tutorModes[index];
                    return _buildModeCard(
                      id: mode['id']!,
                      icon: mode['icon']!,
                      title: mode['title']!,
                      description: mode['description']!,
                    );
                  },
                ),
              ),

              // Footer info
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: widget.theme.colorScheme.primary.withValues(
                    alpha: 0.05,
                  ),
                  border: Border(
                    top: BorderSide(
                      color: widget.theme.colorScheme.outline.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info_outline',
                      color: widget.theme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Scegli la modalità più adatta al tuo stile di apprendimento',
                        style: widget.theme.textTheme.bodySmall?.copyWith(
                          color: widget.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String id,
    required String icon,
    required String title,
    required String description,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Modalità $title attivata'),
            duration: const Duration(seconds: 2),
          ),
        );
        widget.onClose();
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: widget.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: widget.theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: widget.theme.colorScheme.primary,
                size: 6.w,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: widget.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: widget.theme.textTheme.bodySmall?.copyWith(
                      color: widget.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: widget.theme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
