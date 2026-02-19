import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Widget riutilizzabile per rendering markdown nei messaggi del tutor.
///
/// Sostituisce `Text(...)` nelle bubble dove il tutor puo usare
/// bold, elenchi puntati, etc. Selectable e senza scroll interno.
class MarkdownText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final Color? textColor;

  const MarkdownText({
    super.key,
    required this.data,
    this.style,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = style ??
        theme.textTheme.bodyLarge?.copyWith(
          color: textColor ?? theme.colorScheme.onSurface,
          height: 1.55,
        );

    return MarkdownBody(
      data: data,
      selectable: true,
      shrinkWrap: true,
      softLineBreak: true,
      styleSheet: MarkdownStyleSheet(
        // Paragrafo: stile base
        p: baseStyle,
        // Bold
        strong: baseStyle?.copyWith(fontWeight: FontWeight.w700),
        // Italic
        em: baseStyle?.copyWith(fontStyle: FontStyle.italic),
        // Liste
        listBullet: baseStyle?.copyWith(
          color: textColor ?? theme.colorScheme.onSurface,
        ),
        // Spaziatura tra paragrafi ridotta (evita padding eccessivo)
        pPadding: EdgeInsets.zero,
        blockSpacing: 8,
        // Headers (rari nel tutor ma per sicurezza)
        h1: baseStyle?.copyWith(
          fontSize: (baseStyle.fontSize ?? 16) * 1.4,
          fontWeight: FontWeight.w700,
        ),
        h2: baseStyle?.copyWith(
          fontSize: (baseStyle.fontSize ?? 16) * 1.2,
          fontWeight: FontWeight.w600,
        ),
        h3: baseStyle?.copyWith(
          fontSize: (baseStyle.fontSize ?? 16) * 1.1,
          fontWeight: FontWeight.w600,
        ),
        // Code inline
        code: baseStyle?.copyWith(
          fontFamily: 'monospace',
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
        ),
        // Blocco codice
        codeblockDecoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
