import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/widgets/latex_text.dart';

void main() {
  group('LatexText.parse', () {
    test('plain text without LaTeX returns single text segment', () {
      final segments = LatexText.parse('Hello world');
      expect(segments.length, 1);
      expect(segments[0].content, 'Hello world');
      expect(segments[0].isLatex, false);
      expect(segments[0].isBlock, false);
    });

    test('empty string returns empty list', () {
      final segments = LatexText.parse('');
      expect(segments, isEmpty);
    });

    test('inline LaTeX with single dollars', () {
      final segments = LatexText.parse(r'La formula $x^2$ è quadrata');
      expect(segments.length, 3);
      expect(segments[0].content, 'La formula ');
      expect(segments[0].isLatex, false);
      expect(segments[1].content, 'x^2');
      expect(segments[1].isLatex, true);
      expect(segments[1].isBlock, false);
      expect(segments[2].content, ' è quadrata');
      expect(segments[2].isLatex, false);
    });

    test('block LaTeX with double dollars', () {
      final segments = LatexText.parse(r'Ecco: $$\frac{a}{b}$$ fine');
      expect(segments.length, 3);
      expect(segments[0].content, 'Ecco: ');
      expect(segments[0].isLatex, false);
      expect(segments[1].content, r'\frac{a}{b}');
      expect(segments[1].isLatex, true);
      expect(segments[1].isBlock, true);
      expect(segments[2].content, ' fine');
      expect(segments[2].isLatex, false);
    });

    test('multiple inline LaTeX segments', () {
      final segments = LatexText.parse(r'$a$ più $b$ uguale $c$');
      expect(segments.length, 5);
      expect(segments[0].content, 'a');
      expect(segments[0].isLatex, true);
      expect(segments[1].content, ' più ');
      expect(segments[1].isLatex, false);
      expect(segments[2].content, 'b');
      expect(segments[2].isLatex, true);
      expect(segments[3].content, ' uguale ');
      expect(segments[3].isLatex, false);
      expect(segments[4].content, 'c');
      expect(segments[4].isLatex, true);
    });

    test('mixed inline and block LaTeX', () {
      final segments =
          LatexText.parse(r'Inline $x$ e block $$y^2$$ dopo');
      expect(segments.length, 5);
      expect(segments[0].content, 'Inline ');
      expect(segments[1].content, 'x');
      expect(segments[1].isLatex, true);
      expect(segments[1].isBlock, false);
      expect(segments[2].content, ' e block ');
      expect(segments[2].isLatex, false);
      expect(segments[3].content, r'y^2');
      expect(segments[3].isLatex, true);
      expect(segments[3].isBlock, true);
      expect(segments[4].content, ' dopo');
    });

    test('unclosed inline dollar treated as plain text', () {
      final segments = LatexText.parse(r'Il prezzo è $5');
      // '$' flushes buffer before it, then '$5' becomes a new text segment
      expect(segments.length, 2);
      expect(segments[0].content, r'Il prezzo è ');
      expect(segments[0].isLatex, false);
      expect(segments[1].content, r'$5');
      expect(segments[1].isLatex, false);
    });

    test('unclosed block dollars treated as plain text', () {
      final segments = LatexText.parse(r'Apro $$formula senza chiudere');
      // $$ without closing → 'Apro ' flushed, then '$$formula senza chiudere'
      expect(segments.length, 2);
      expect(segments[0].content, 'Apro ');
      expect(segments[1].content, r'$$formula senza chiudere');
      expect(segments[1].isLatex, false);
    });

    test('empty inline LaTeX is treated as plain text', () {
      final segments = LatexText.parse(r'A $$ B');
      // $$ is block open, then ' B' has no closing $$
      expect(segments.every((s) => !s.isLatex || s.content.isNotEmpty), true);
    });

    test('inline LaTeX with newline breaks out', () {
      final segments = LatexText.parse('prima \$a\nb\$ fine');
      // Newline inside inline $ → no match, $ treated as plain text
      // 'prima ' flushed, then '$a\nb' ($ + chars until newline breaks,
      // then b$ also fails), then ' fine'
      expect(segments.every((s) => s.isLatex == false), true);
    });

    test('block LaTeX can contain newlines', () {
      final segments = LatexText.parse('prima \$\$a\nb\$\$ dopo');
      expect(segments.length, 3);
      expect(segments[1].content, 'a\nb');
      expect(segments[1].isLatex, true);
      expect(segments[1].isBlock, true);
    });

    test('LaTeX with spaces is trimmed', () {
      final segments = LatexText.parse(r'$ x^2 $');
      expect(segments.length, 1);
      expect(segments[0].content, 'x^2');
      expect(segments[0].isLatex, true);
    });

    test('real math expression: fraction', () {
      final segments = LatexText.parse(r'Calcola $\frac{1}{2}$ del totale');
      expect(segments.length, 3);
      expect(segments[1].content, r'\frac{1}{2}');
      expect(segments[1].isLatex, true);
      expect(segments[1].isBlock, false);
    });

    test('real math expression: quadratic formula block', () {
      final segments = LatexText.parse(
        r'La soluzione è: $$x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$$',
      );
      expect(segments.length, 2);
      expect(segments[0].content, 'La soluzione è: ');
      expect(segments[1].content, r'x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}');
      expect(segments[1].isLatex, true);
      expect(segments[1].isBlock, true);
    });

    test('consecutive block formulas', () {
      final segments = LatexText.parse(r'$$a$$$$b$$');
      expect(segments.length, 2);
      expect(segments[0].content, 'a');
      expect(segments[0].isBlock, true);
      expect(segments[1].content, 'b');
      expect(segments[1].isBlock, true);
    });

    test('only LaTeX, no surrounding text', () {
      final segments = LatexText.parse(r'$x + y = z$');
      expect(segments.length, 1);
      expect(segments[0].content, 'x + y = z');
      expect(segments[0].isLatex, true);
      expect(segments[0].isBlock, false);
    });

    test('dollar sign at end of string without match', () {
      final segments = LatexText.parse(r'Costo: 5$');
      // 'Costo: 5' flushed before '$', then '$' alone has no match
      expect(segments.length, 2);
      expect(segments[0].content, 'Costo: 5');
      expect(segments[0].isLatex, false);
      expect(segments[1].content, r'$');
      expect(segments[1].isLatex, false);
    });

    test('block LaTeX with whitespace-only content is skipped', () {
      final segments = LatexText.parse(r'prima $$   $$ dopo');
      // Whitespace-only LaTeX is skipped, 'prima ' and ' dopo' are
      // separate text segments because the $$ flushes the buffer
      expect(segments.length, 2);
      expect(segments[0].content, 'prima ');
      expect(segments[1].content, ' dopo');
      expect(segments.every((s) => s.isLatex == false), true);
    });
  });
}
