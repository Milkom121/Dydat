import 'package:flutter/material.dart';

import '../../../core/sizer_extensions.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Barra di input per inviare messaggi al tutor durante la sessione.
class SessionInputBarWidget extends StatefulWidget {
  final bool isActive;
  final bool isStreaming;
  final TextEditingController messageController;
  final FocusNode messageFocusNode;
  final VoidCallback onSend;

  const SessionInputBarWidget({
    super.key,
    required this.isActive,
    required this.isStreaming,
    required this.messageController,
    required this.messageFocusNode,
    required this.onSend,
  });

  @override
  State<SessionInputBarWidget> createState() => _SessionInputBarWidgetState();
}

class _SessionInputBarWidgetState extends State<SessionInputBarWidget> {
  @override
  void initState() {
    super.initState();
    // Ascolta i cambi testo per aggiornare il colore del bottone send
    widget.messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.messageController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = widget.messageController.text.isNotEmpty;
    final canSend = widget.isActive && !widget.isStreaming;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 1.5.h,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.messageController,
              focusNode: widget.messageFocusNode,
              enabled: canSend,
              decoration: InputDecoration(
                hintText: widget.isStreaming
                    ? 'Il tutor sta rispondendo...'
                    : widget.isActive
                        ? 'Scrivi un messaggio...'
                        : 'Inizia la sessione per chattare',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.5.h,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => widget.onSend(),
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            decoration: BoxDecoration(
              color: canSend && hasText
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: CustomIconWidget(
                iconName: 'send',
                color: canSend && hasText
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              onPressed: canSend ? widget.onSend : null,
            ),
          ),
        ],
      ),
    );
  }
}
