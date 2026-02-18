import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/sizer_extensions.dart';
import '../../../models/sse_events.dart';
import '../../../widgets/custom_icon_widget.dart';

class ExerciseCardWidget extends StatefulWidget {
  final ProponiEsercizioAction exercise;
  final ThemeData theme;
  final void Function(String risposta) onVerify;
  final VoidCallback onDismiss;

  const ExerciseCardWidget({
    super.key,
    required this.exercise,
    required this.theme,
    required this.onVerify,
    required this.onDismiss,
  });

  @override
  State<ExerciseCardWidget> createState() => _ExerciseCardWidgetState();
}

class _ExerciseCardWidgetState extends State<ExerciseCardWidget> {
  final TextEditingController _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  String get _difficultyLabel {
    final d = widget.exercise.difficolta;
    if (d == null) return 'medio';
    if (d <= 3) return 'facile';
    if (d <= 6) return 'medio';
    return 'difficile';
  }

  Color get _difficultyColor {
    final label = _difficultyLabel;
    return label == 'facile'
        ? const Color(0xFF7EBF8E)
        : label == 'medio'
            ? widget.theme.colorScheme.primary
            : const Color(0xFFC97070);
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _difficultyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'assignment',
                      color: _difficultyColor,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      _difficultyLabel.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _difficultyColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onDismiss();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Esercizio',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.exercise.testo ?? 'Esercizio proposto dal tutor',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _answerController,
            decoration: InputDecoration(
              hintText: 'Scrivi la tua risposta...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 1.5.h,
              ),
            ),
            maxLines: null,
            textInputAction: TextInputAction.done,
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final answer = _answerController.text.trim();
                if (answer.isEmpty) return;
                HapticFeedback.lightImpact();
                widget.onVerify(answer);
              },
              child: Text(
                'Verifica',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
