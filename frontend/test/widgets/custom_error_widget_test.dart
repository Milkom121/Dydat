import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/widgets/custom_error_widget.dart';

void main() {
  group('CustomErrorWidget', () {
    testWidgets('mostra testo italiano e bottone torna indietro',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CustomErrorWidget(),
        ),
      );

      // Titolo in italiano
      expect(find.text('Qualcosa è andato storto'), findsOneWidget);

      // Sottotitolo in italiano
      expect(
        find.text(
            'Si è verificato un errore imprevisto. Torna indietro e riprova.'),
        findsOneWidget,
      );

      // Bottone in italiano
      expect(find.text('Torna indietro'), findsOneWidget);

      // Icona errore
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('non contiene testo in inglese', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CustomErrorWidget(),
        ),
      );

      expect(find.text('Something went wrong'), findsNothing);
      expect(find.text('Back'), findsNothing);
    });
  });
}
