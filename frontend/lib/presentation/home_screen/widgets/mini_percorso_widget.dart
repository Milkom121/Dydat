import 'package:flutter/material.dart';

import '../../../core/sizer_extensions.dart';
import '../../../models/percorso.dart';
import '../../../theme/surface_decorations.dart';

/// Mini-percorso visivo: mostra la posizione attuale nel percorso
/// con fino a 5 nodi intorno alla posizione corrente.
/// I nodi sono cerchi collegati da una linea, con stati visivi diversi.
class MiniPercorsoWidget extends StatelessWidget {
  final MappaPercorso mappa;

  const MiniPercorsoWidget({super.key, required this.mappa});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nodi = mappa.nodi;

    if (nodi.isEmpty) return const SizedBox.shrink();

    // Trova il nodo corrente: primo nodo non completato (livello != 'operativo'
    // e livello != 'comprensivo', oppure eserciziCompletati == 0 e non spiegazioneData)
    final currentIndex = _findCurrentNodeIndex(nodi);
    final window = _getWindowAround(nodi, currentIndex, maxVisible: 5);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      decoration: DydatSurface.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route, size: 18, color: theme.colorScheme.primary),
              SizedBox(width: 2.w),
              Text(
                'Il tuo percorso — ${mappa.materia}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Riga di nodi con connessioni
          SizedBox(
            height: 80,
            child: LayoutBuilder(
              builder: (layoutContext, constraints) {
                return _buildNodeRow(
                  context,
                  theme,
                  window.nodi,
                  window.currentIndexInWindow,
                  constraints.maxWidth,
                );
              },
            ),
          ),
          // Indicatore nodo corrente
          if (currentIndex < nodi.length) ...[
            SizedBox(height: 1.5.h),
            Text(
              'Prossimo: ${nodi[currentIndex].nome}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNodeRow(
    BuildContext context,
    ThemeData theme,
    List<NodoMappa> nodi,
    int currentInWindow,
    double availableWidth,
  ) {
    if (nodi.isEmpty) return const SizedBox.shrink();

    final nodeSize = 36.0;
    final spacing = nodi.length > 1
        ? (availableWidth - nodeSize * nodi.length) / (nodi.length - 1)
        : 0.0;
    // Limita spacing
    final effectiveSpacing = spacing.clamp(8.0, 40.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < nodi.length; i++) ...[
          if (i > 0)
            _buildConnector(theme, effectiveSpacing, _isCompleted(nodi[i - 1])),
          _buildNode(context, theme, nodi[i], i == currentInWindow),
        ],
      ],
    );
  }

  Widget _buildNode(BuildContext context, ThemeData theme, NodoMappa nodo, bool isCurrent) {
    final completed = _isCompleted(nodo);

    Color bgColor;
    Color borderColor;
    IconData? icon;

    if (isCurrent) {
      bgColor = theme.colorScheme.primary;
      borderColor = theme.colorScheme.primary;
      icon = Icons.play_arrow_rounded;
    } else if (completed) {
      bgColor = theme.colorScheme.primary.withValues(alpha: 0.2);
      borderColor = theme.colorScheme.primary.withValues(alpha: 0.5);
      icon = Icons.check_rounded;
    } else {
      bgColor = theme.colorScheme.surfaceContainerHighest;
      borderColor = theme.colorScheme.outlineVariant;
      icon = null;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: isCurrent
              ? DydatSurface.glowCircle(
                  context,
                  nodeColor: theme.colorScheme.primary,
                )
              : BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1.5),
                ),
          child: icon != null
              ? Icon(
                  icon,
                  size: 18,
                  color: isCurrent
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
                )
              : null,
        ),
        SizedBox(height: 0.5.h),
        SizedBox(
          width: 50,
          child: Text(
            _abbreviate(nodo.nome),
            style: theme.textTheme.labelSmall?.copyWith(
              color: isCurrent
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(ThemeData theme, double width, bool completed) {
    return Container(
      width: width.clamp(8.0, 40.0),
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: completed
          ? theme.colorScheme.primary.withValues(alpha: 0.4)
          : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
    );
  }

  /// Un nodo e considerato completato se ha livello operativo o comprensivo
  /// e non e presunto.
  bool _isCompleted(NodoMappa nodo) {
    return !nodo.presunto &&
        (nodo.livello == 'operativo' || nodo.livello == 'comprensivo');
  }

  /// Trova l'indice del primo nodo non completato.
  int _findCurrentNodeIndex(List<NodoMappa> nodi) {
    for (int i = 0; i < nodi.length; i++) {
      if (!_isCompleted(nodi[i])) return i;
    }
    // Tutti completati: ritorna l'ultimo
    return nodi.length - 1;
  }

  /// Estrae una finestra di nodi intorno alla posizione corrente.
  _NodeWindow _getWindowAround(
    List<NodoMappa> nodi,
    int currentIndex, {
    int maxVisible = 5,
  }) {
    if (nodi.length <= maxVisible) {
      return _NodeWindow(nodi: nodi, currentIndexInWindow: currentIndex);
    }

    // Centra la finestra sul nodo corrente
    int start = currentIndex - maxVisible ~/ 2;
    start = start.clamp(0, nodi.length - maxVisible);
    final end = (start + maxVisible).clamp(0, nodi.length);

    return _NodeWindow(
      nodi: nodi.sublist(start, end),
      currentIndexInWindow: currentIndex - start,
    );
  }

  String _abbreviate(String nome) {
    if (nome.length <= 12) return nome;
    return nome;
  }
}

class _NodeWindow {
  final List<NodoMappa> nodi;
  final int currentIndexInWindow;

  const _NodeWindow({required this.nodi, required this.currentIndexInWindow});
}
