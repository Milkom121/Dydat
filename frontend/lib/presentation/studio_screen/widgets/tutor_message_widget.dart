import 'package:flutter/material.dart';
import '../../../core/sizer_extensions.dart';
import 'package:intl/intl.dart';

import '../../../widgets/markdown_text.dart';

class TutorMessageWidget extends StatefulWidget {
  final Map<String, dynamic> message;
  final ThemeData theme;

  const TutorMessageWidget({
    super.key,
    required this.message,
    required this.theme,
  });

  @override
  State<TutorMessageWidget> createState() => _TutorMessageWidgetState();
}

class _TutorMessageWidgetState extends State<TutorMessageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _displayedText = '';
  int _currentCharIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();

    if (widget.message['isStreaming'] == true) {
      _startStreaming();
    } else {
      _displayedText = widget.message['content'];
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startStreaming() {
    final fullText = widget.message['content'] as String;
    const charsPerTick = 2;
    const tickDuration = Duration(milliseconds: 30);

    Future.delayed(tickDuration, () {
      if (mounted && _currentCharIndex < fullText.length) {
        setState(() {
          _currentCharIndex = (_currentCharIndex + charsPerTick).clamp(
            0,
            fullText.length,
          );
          _displayedText = fullText.substring(0, _currentCharIndex);
        });
        _startStreaming();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUserMessage = widget.message['sender'] == 'user';
    final timestamp = widget.message['timestamp'] as DateTime;
    final timeString = DateFormat('HH:mm').format(timestamp);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.only(top: 2.h),
        child: Row(
          mainAxisAlignment: isUserMessage
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUserMessage) ...[
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: widget.theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.school,
                  size: 4.w,
                  color: widget.theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 2.w),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isUserMessage
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: isUserMessage
                          ? widget.theme.colorScheme.primary
                          : widget.theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: isUserMessage
                          ? null
                          : Border.all(
                              color: widget.theme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                            ),
                    ),
                    child: isUserMessage
                        ? Text(
                            _displayedText,
                            style:
                                widget.theme.textTheme.bodyMedium?.copyWith(
                              color: widget.theme.colorScheme.onPrimary,
                              height: 1.55,
                            ),
                          )
                        : MarkdownText(
                            data: _displayedText,
                            textColor: widget.theme.colorScheme.onSurface,
                          ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    timeString,
                    style: widget.theme.textTheme.labelSmall?.copyWith(
                      color: widget.theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isUserMessage) ...[
              SizedBox(width: 2.w),
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: widget.theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 4.w,
                  color: widget.theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
