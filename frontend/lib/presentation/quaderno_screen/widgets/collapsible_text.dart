import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Testo collassabile con expand/collapse. Supporta Markdown.
/// Mostra [maxChars] caratteri e un pulsante "Mostra tutto" / "Mostra meno".
class CollapsibleText extends StatefulWidget {
  final String text;
  final int maxChars;
  final TextStyle? style;

  const CollapsibleText({
    super.key,
    required this.text,
    this.maxChars = 200,
    this.style,
  });

  @override
  State<CollapsibleText> createState() => _CollapsibleTextState();
}

class _CollapsibleTextState extends State<CollapsibleText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLong = widget.text.length > widget.maxChars;
    final displayText = _expanded || !isLong
        ? widget.text
        : '${widget.text.substring(0, widget.maxChars)}...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MarkdownBody(
          data: displayText,
          styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
            p: widget.style ?? theme.textTheme.bodyMedium,
          ),
          shrinkWrap: true,
        ),
        if (isLong)
          Semantics(
            label: _expanded ? 'Mostra meno testo' : 'Mostra tutto il testo',
            button: true,
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _expanded ? 'Mostra meno' : 'Mostra tutto',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
