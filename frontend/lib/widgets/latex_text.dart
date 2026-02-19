import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import 'markdown_text.dart';

/// A segment of parsed text — either plain text/markdown or a LaTeX formula.
@visibleForTesting
class LatexSegment {
  final String content;
  final bool isLatex;
  final bool isBlock; // $$...$$ (centered) vs $...$ (inline)

  const LatexSegment(this.content, {this.isLatex = false, this.isBlock = false});
}

/// Widget that renders text with inline ($...$) and block ($$...$$) LaTeX.
///
/// Plain text segments are rendered with [MarkdownText] (bold, lists, etc.).
/// LaTeX segments are rendered with [Math.tex()] from flutter_math_fork.
/// Malformed LaTeX falls back to raw text (no crash).
class LatexText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final Color? textColor;

  const LatexText({
    super.key,
    required this.data,
    this.style,
    this.textColor,
  });

  /// Parses the input string into a list of segments.
  ///
  /// Rules:
  /// - `$$...$$` → block LaTeX (greedy-safe: stops at first `$$`)
  /// - `$...$` → inline LaTeX (no nesting, no newlines inside)
  /// - Everything else → plain text/markdown
  @visibleForTesting
  static List<LatexSegment> parse(String input) {
    final segments = <LatexSegment>[];
    final buffer = StringBuffer();
    int i = 0;

    while (i < input.length) {
      // Check for $$ (block LaTeX)
      if (i < input.length - 1 && input[i] == '\$' && input[i + 1] == '\$') {
        // Flush text buffer
        if (buffer.isNotEmpty) {
          segments.add(LatexSegment(buffer.toString()));
          buffer.clear();
        }
        // Find closing $$
        final start = i + 2;
        final end = input.indexOf('\$\$', start);
        if (end == -1) {
          // No closing $$ — treat as plain text
          buffer.write('\$\$');
          i += 2;
        } else {
          final latex = input.substring(start, end).trim();
          if (latex.isNotEmpty) {
            segments.add(LatexSegment(latex, isLatex: true, isBlock: true));
          }
          i = end + 2;
        }
      }
      // Check for $ (inline LaTeX)
      else if (input[i] == '\$') {
        // Flush text buffer
        if (buffer.isNotEmpty) {
          segments.add(LatexSegment(buffer.toString()));
          buffer.clear();
        }
        // Find closing $
        final start = i + 1;
        int end = -1;
        for (int j = start; j < input.length; j++) {
          if (input[j] == '\$') {
            // Make sure it's not $$
            if (j + 1 < input.length && input[j + 1] == '\$') continue;
            end = j;
            break;
          }
          // No newlines in inline LaTeX
          if (input[j] == '\n') break;
        }
        if (end == -1 || end == start) {
          // No closing $ or empty — treat as plain text
          buffer.write('\$');
          i += 1;
        } else {
          final latex = input.substring(start, end).trim();
          if (latex.isNotEmpty) {
            segments.add(LatexSegment(latex, isLatex: true, isBlock: false));
          }
          i = end + 1;
        }
      } else {
        buffer.write(input[i]);
        i++;
      }
    }

    // Flush remaining text
    if (buffer.isNotEmpty) {
      segments.add(LatexSegment(buffer.toString()));
    }

    return segments;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final segments = parse(data);

    // Fast path: no LaTeX at all — use MarkdownText directly
    if (!segments.any((s) => s.isLatex)) {
      return MarkdownText(data: data, style: style, textColor: textColor);
    }

    final baseStyle = style ??
        theme.textTheme.bodyLarge?.copyWith(
          color: textColor ?? theme.colorScheme.onSurface,
          height: 1.55,
        );

    final mathColor = textColor ?? theme.colorScheme.onSurface;

    final children = <Widget>[];
    for (final segment in segments) {
      if (segment.isLatex) {
        if (segment.isBlock) {
          children.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: _buildMathTex(
                  segment.content,
                  mathColor,
                  baseStyle?.fontSize,
                  isBlock: true,
                ),
              ),
            ),
          );
        } else {
          // Inline LaTeX — wrap in a Wrap-friendly widget
          children.add(
            _buildMathTex(
              segment.content,
              mathColor,
              baseStyle?.fontSize,
              isBlock: false,
            ),
          );
        }
      } else {
        children.add(
          MarkdownText(
            data: segment.content,
            style: style,
            textColor: textColor,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  /// Renders a LaTeX string with Math.tex(), falling back to raw text on error.
  Widget _buildMathTex(
    String tex,
    Color color,
    double? fontSize, {
    required bool isBlock,
  }) {
    return Math.tex(
      tex,
      textStyle: TextStyle(
        color: color,
        fontSize: isBlock ? (fontSize ?? 16) * 1.2 : fontSize,
      ),
      onErrorFallback: (err) {
        // Fallback: show raw LaTeX as styled text (no crash)
        return Text(
          isBlock ? '\$\$$tex\$\$' : '\$$tex\$',
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontFamily: 'monospace',
            fontStyle: FontStyle.italic,
          ),
        );
      },
    );
  }
}
