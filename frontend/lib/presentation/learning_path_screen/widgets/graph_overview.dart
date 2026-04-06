import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/percorso.dart';
import '../../../models/tema.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Vista grafo completo con InteractiveViewer: nodi raggruppati per tema,
/// con connessioni sequenziali. Pan + zoom per esplorare.
class GraphOverview extends StatelessWidget {
  final List<NodoMappa> nodi;
  final List<Tema> temi;
  final Set<String> nodiDaRipassare;
  final Set<String> highlightedNodeIds;
  final ValueChanged<NodoMappa> onNodeTap;

  const GraphOverview({
    super.key,
    required this.nodi,
    required this.temi,
    this.nodiDaRipassare = const {},
    this.highlightedNodeIds = const {},
    required this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (nodi.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    // Raggruppa nodi per tema
    final temaGroups = <String, List<NodoMappa>>{};
    for (final nodo in nodi) {
      final key = nodo.temaId ?? 'senza_tema';
      temaGroups.putIfAbsent(key, () => []).add(nodo);
    }

    // Mappa tema_id -> nome tema per le label
    final temaNomi = <String, String>{};
    for (final t in temi) {
      temaNomi[t.id] = t.nome;
    }

    // Calcola layout: ogni gruppo occupa una colonna
    final groupKeys = temaGroups.keys.toList();
    const nodeSize = 52.0;
    const nodeSpacingY = 72.0;
    const groupSpacingX = 180.0;
    const groupHeaderHeight = 40.0;
    const padding = 40.0;

    // Posiziona nodi
    final nodePositions = <String, Offset>{};
    double maxHeight = 0;

    for (int gi = 0; gi < groupKeys.length; gi++) {
      final groupNodi = temaGroups[groupKeys[gi]]!;
      final x = padding + gi * groupSpacingX + groupSpacingX / 2;

      for (int ni = 0; ni < groupNodi.length; ni++) {
        final y = padding + groupHeaderHeight + ni * nodeSpacingY + nodeSize / 2;
        nodePositions[groupNodi[ni].id] = Offset(x, y);
        maxHeight = math.max(maxHeight, y + nodeSize);
      }
    }

    final totalWidth = padding * 2 + groupKeys.length * groupSpacingX;
    final totalHeight = maxHeight + padding;

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(60),
      minScale: 0.3,
      maxScale: 2.0,
      child: SizedBox(
        width: totalWidth,
        height: totalHeight,
        child: Stack(
          children: [
            // Linee di connessione tra nodi sequenziali
            CustomPaint(
              size: Size(totalWidth, totalHeight),
              painter: _ConnectionPainter(
                nodi: nodi,
                positions: nodePositions,
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            // Etichette gruppi (temi)
            for (int gi = 0; gi < groupKeys.length; gi++)
              Positioned(
                left: padding + gi * groupSpacingX,
                top: padding / 2,
                width: groupSpacingX,
                child: Text(
                  temaNomi[groupKeys[gi]] ?? 'Altro',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            // Nodi
            for (final nodo in nodi)
              if (nodePositions.containsKey(nodo.id))
                Positioned(
                  left: nodePositions[nodo.id]!.dx - nodeSize / 2,
                  top: nodePositions[nodo.id]!.dy - nodeSize / 2,
                  child: _GraphNode(
                    nodo: nodo,
                    size: nodeSize,
                    needsReview: nodiDaRipassare.contains(nodo.id),
                    isHighlighted: highlightedNodeIds.isEmpty ||
                        highlightedNodeIds.contains(nodo.id),
                    onTap: () => onNodeTap(nodo),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// Disegna le linee di connessione tra nodi consecutivi.
class _ConnectionPainter extends CustomPainter {
  final List<NodoMappa> nodi;
  final Map<String, Offset> positions;
  final Color color;

  _ConnectionPainter({
    required this.nodi,
    required this.positions,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < nodi.length - 1; i++) {
      final from = positions[nodi[i].id];
      final to = positions[nodi[i + 1].id];
      if (from != null && to != null) {
        canvas.drawLine(from, to, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionPainter oldDelegate) {
    return oldDelegate.nodi != nodi || oldDelegate.color != color;
  }
}

/// Singolo nodo nel grafo: cerchio con icona stato.
class _GraphNode extends StatelessWidget {
  final NodoMappa nodo;
  final double size;
  final bool needsReview;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _GraphNode({
    required this.nodo,
    required this.size,
    required this.needsReview,
    required this.isHighlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = _getNodeState(nodo.livello);
    final borderColor = _borderColor(theme, state);

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isHighlighted ? 1.0 : 0.3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 2.5),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: _nodeIcon(state),
                      color: borderColor,
                      size: size * 0.4,
                    ),
                  ),
                ),
                if (needsReview)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'replay',
                          color: theme.colorScheme.onTertiary,
                          size: 9,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: size * 2.2,
              child: Text(
                nodo.nome,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontSize: 10,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _borderColor(ThemeData theme, _GNodeState state) {
    switch (state) {
      case _GNodeState.nonIniziato:
        return theme.colorScheme.outline.withValues(alpha: 0.3);
      case _GNodeState.inCorso:
        return theme.colorScheme.primary;
      case _GNodeState.completato:
        return theme.colorScheme.secondary;
    }
  }

  String _nodeIcon(_GNodeState state) {
    switch (state) {
      case _GNodeState.nonIniziato:
        return 'radio_button_unchecked';
      case _GNodeState.inCorso:
        return 'timelapse';
      case _GNodeState.completato:
        return 'check_circle';
    }
  }

  _GNodeState _getNodeState(String livello) {
    switch (livello) {
      case 'in_corso':
        return _GNodeState.inCorso;
      case 'operativo':
      case 'comprensivo':
      case 'connesso':
        return _GNodeState.completato;
      default:
        return _GNodeState.nonIniziato;
    }
  }
}

enum _GNodeState { nonIniziato, inCorso, completato }
