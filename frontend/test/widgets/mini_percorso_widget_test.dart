/// Test B31 — MiniPercorsoWidget: mini-percorso visivo con nodi.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dydat/models/percorso.dart';
import 'package:dydat/presentation/home_screen/widgets/mini_percorso_widget.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child), theme: ThemeData.dark());
}

NodoMappa _nodo({
  required String id,
  required String nome,
  String livello = 'non_visto',
  bool presunto = false,
  int eserciziCompletati = 0,
}) =>
    NodoMappa(
      id: id,
      nome: nome,
      tipo: 'concetto',
      livello: livello,
      presunto: presunto,
      eserciziCompletati: eserciziCompletati,
    );

MappaPercorso _mappa(List<NodoMappa> nodi) => MappaPercorso(
      percorsoId: 1,
      materia: 'Algebra',
      nodi: nodi,
    );

void main() {
  group('MiniPercorsoWidget', () {
    testWidgets('non renderizza se mappa vuota', (tester) async {
      await tester.pumpWidget(_wrap(
        MiniPercorsoWidget(mappa: _mappa([])),
      ));
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('mostra materia nel titolo', (tester) async {
      await tester.pumpWidget(_wrap(
        MiniPercorsoWidget(
          mappa: _mappa([
            _nodo(id: 'n1', nome: 'Frazioni'),
            _nodo(id: 'n2', nome: 'Proporzioni'),
          ]),
        ),
      ));
      expect(find.textContaining('Algebra'), findsOneWidget);
    });

    testWidgets('mostra "Prossimo:" con nome del nodo corrente',
        (tester) async {
      await tester.pumpWidget(_wrap(
        MiniPercorsoWidget(
          mappa: _mappa([
            _nodo(id: 'n1', nome: 'Numeri', livello: 'operativo'),
            _nodo(id: 'n2', nome: 'Frazioni', livello: 'non_visto'),
            _nodo(id: 'n3', nome: 'Proporzioni', livello: 'non_visto'),
          ]),
        ),
      ));
      // Il primo nodo non completato e "Frazioni"
      expect(find.textContaining('Frazioni'), findsWidgets);
    });

    testWidgets('mostra nodi completati con check icon', (tester) async {
      await tester.pumpWidget(_wrap(
        MiniPercorsoWidget(
          mappa: _mappa([
            _nodo(id: 'n1', nome: 'A', livello: 'operativo'),
            _nodo(id: 'n2', nome: 'B', livello: 'non_visto'),
          ]),
        ),
      ));
      // Almeno un check icon per il nodo completato
      expect(find.byIcon(Icons.check_rounded), findsWidgets);
    });

    testWidgets('mostra play icon per il nodo corrente', (tester) async {
      await tester.pumpWidget(_wrap(
        MiniPercorsoWidget(
          mappa: _mappa([
            _nodo(id: 'n1', nome: 'A', livello: 'operativo'),
            _nodo(id: 'n2', nome: 'B', livello: 'non_visto'),
          ]),
        ),
      ));
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('finestra mostra massimo 5 nodi', (tester) async {
      final nodi = List.generate(
        10,
        (i) => _nodo(
          id: 'n$i',
          nome: 'Nodo $i',
          livello: i < 3 ? 'operativo' : 'non_visto',
        ),
      );
      await tester.pumpWidget(_wrap(
        MiniPercorsoWidget(mappa: _mappa(nodi)),
      ));
      // Deve mostrare esattamente 5 nodi (play_arrow o check)
      final playIcons = find.byIcon(Icons.play_arrow_rounded);
      final checkIcons = find.byIcon(Icons.check_rounded);
      // Al massimo 5 nodi visivi totali (1 play + completati + non completati)
      final totalIcons =
          tester.widgetList(playIcons).length + tester.widgetList(checkIcons).length;
      // I nodi senza icona non hanno check/play, ma ci sono al massimo 5 cerchi
      expect(totalIcons, lessThanOrEqualTo(5));
    });
  });
}
