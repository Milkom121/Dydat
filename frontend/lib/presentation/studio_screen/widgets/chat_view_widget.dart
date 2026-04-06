import 'package:flutter/material.dart';

import '../../../core/sizer_extensions.dart';
import '../../../models/sse_events.dart';
import '../../../widgets/markdown_text.dart';
import './chiudi_sessione_card_widget.dart';
import './compact_action_record.dart';
import './tutor_message_widget.dart';

/// Lista messaggi della sessione: messaggi utente/tutor, record compatti, streaming bubble.
class ChatViewWidget extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final bool isStreaming;
  final String currentTutorText;
  final ScrollController scrollController;
  final Future<void> Function() onEndSession;

  const ChatViewWidget({
    super.key,
    required this.messages,
    required this.isStreaming,
    required this.currentTutorText,
    required this.scrollController,
    required this.onEndSession,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showStreamingBubble = isStreaming && currentTutorText.isNotEmpty;
    final showTypingIndicator = isStreaming && currentTutorText.isEmpty;
    final extraItems = showStreamingBubble || showTypingIndicator ? 1 : 0;
    final totalItems = messages.length + extraItems;

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.only(bottom: 2.h),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        // Streaming bubble o typing indicator alla fine
        if (index == messages.length) {
          if (showStreamingBubble) {
            return _StreamingBubble(theme: theme, text: currentTutorText);
          }
          if (showTypingIndicator) {
            return _TypingIndicator(theme: theme);
          }
        }
        if (index < messages.length) {
          return _buildChatItem(messages[index], theme, context);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildChatItem(
    Map<String, dynamic> item,
    ThemeData theme,
    BuildContext context,
  ) {
    final type = item['type'] as String?;

    switch (type) {
      case 'user':
      case 'tutor':
        return TutorMessageWidget(message: item, theme: theme);

      // Record compatti: mostrati dopo che un'azione fullscreen è stata completata
      case 'exercise_record':
      case 'formula_record':
      case 'backtrack_record':
        return Padding(
          padding: EdgeInsets.only(top: 1.h),
          child: CompactActionRecord(
            actionType: type!,
            label: item['label'] as String? ?? '',
            result: item['result'] as String? ?? '',
          ),
        );

      case 'chiudi':
        final action = item['data'] as AzioneEvent;
        final chiudi = action.asChiudiSessione;
        if (chiudi == null) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: ChiudiSessioneCardWidget(
            data: chiudi,
            theme: theme,
            onEnd: onEndSession,
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

/// Bubble animata con testo streaming del tutor e cursore ambra pulsante.
class _StreamingBubble extends StatelessWidget {
  final ThemeData theme;
  final String text;

  const _StreamingBubble({required this.theme, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school,
              size: 4.w,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 2.w),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 1.5.h,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: MarkdownText(
                      data: text,
                      textColor: theme.colorScheme.onSurface,
                    ),
                  ),
                  const _AmberCursor(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Indicatore "il tutor sta scrivendo..." mostrato mentre arriva il primo token.
class _TypingIndicator extends StatelessWidget {
  final ThemeData theme;

  const _TypingIndicator({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 1.5.h,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 4.w,
                  height: 4.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  'Il tutor sta scrivendo...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cursore ambra pulsante mostrato alla fine del testo in streaming.
class _AmberCursor extends StatefulWidget {
  const _AmberCursor();

  @override
  State<_AmberCursor> createState() => _AmberCursorState();
}

class _AmberCursorState extends State<_AmberCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 2,
        height: 16,
        margin: const EdgeInsets.only(left: 2, bottom: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
