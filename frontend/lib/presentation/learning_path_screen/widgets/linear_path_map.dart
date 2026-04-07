import 'package:flutter/material.dart';
import '../../../core/sizer_extensions.dart';
import '../../../models/percorso.dart';
import '../../../theme/surface_decorations.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Mappa lineare verticale del percorso: nodi come cerchi grandi collegati
/// da linee verticali graduate. Layout centrato, nome sotto il cerchio.
class LinearPathMap extends StatelessWidget {
  final List<NodoMappa> nodi;
  final Set<String> nodiDaRipassare;
  final Set<String> highlightedNodeIds;
  final ValueChanged<NodoMappa> onNodeTap;

  const LinearPathMap({
    super.key,
    required this.nodi,
    this.nodiDaRipassare = const {},
    this.highlightedNodeIds = const {},
    required this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (nodi.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
      itemCount: nodi.length,
      itemBuilder: (context, index) {
        final nodo = nodi[index];
        final isLast = index == nodi.length - 1;
        final isHighlighted = highlightedNodeIds.isEmpty ||
            highlightedNodeIds.contains(nodo.id);
        final needsReview = nodiDaRipassare.contains(nodo.id);

        return _CenteredNodeTile(
          nodo: nodo,
          isLast: isLast,
          isHighlighted: isHighlighted,
          needsReview: needsReview,
          onTap: () => onNodeTap(nodo),
        );
      },
    );
  }
}

class _CenteredNodeTile extends StatelessWidget {
  final NodoMappa nodo;
  final bool isLast;
  final bool isHighlighted;
  final bool needsReview;
  final VoidCallback onTap;

  const _CenteredNodeTile({
    required this.nodo,
    required this.isLast,
    required this.isHighlighted,
    required this.needsReview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nodeState = _getNodeState(nodo.livello);
    final opacity = isHighlighted ? 1.0 : 0.3;

    return Semantics(
      label: '${nodo.nome}, ${_getNodeState(nodo.livello).name}${needsReview ? ', da ripassare' : ''}',
      button: true,
      child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: opacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cerchio grande centrato
            _buildCircle(context, theme, nodeState),
            SizedBox(height: 0.8.h),
            // Nome sotto il cerchio
            _buildLabel(theme, nodeState),
            // Badge ripasso
            if (needsReview) ...[
              SizedBox(height: 0.5.h),
              _buildReviewBadge(theme),
            ],
            // Esercizi completati
            if (nodo.eserciziCompletati > 0) ...[
              SizedBox(height: 0.3.h),
              Text(
                '${nodo.eserciziCompletati} esercizi',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
            // Linea di connessione verso il nodo successivo
            if (!isLast) _buildConnector(theme, nodeState),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildCircle(BuildContext context, ThemeData theme, _NodeState state) {
    const double size = 56.0;
    final color = _circleColor(theme, state);
    final borderColor = _circleBorderColor(theme, state);
    final hasGlow = state == _NodeState.inCorso ||
        state == _NodeState.operativo ||
        state == _NodeState.comprensivo;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: hasGlow
              ? DydatSurface.glowCircle(
                  context,
                  nodeColor: borderColor,
                  glowIntensity: state == _NodeState.inCorso ? 0.4 : 0.2,
                )
              : BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 2.5),
                ),
          child: Center(
            child: CustomIconWidget(
              iconName: _nodeIcon(state),
              color: _nodeIconColor(theme, state),
              size: 24,
            ),
          ),
        ),
        // Badge presunto
        if (nodo.presunto)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'P',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.tertiary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLabel(ThemeData theme, _NodeState state) {
    final isActive = state != _NodeState.nonIniziato;
    return SizedBox(
      width: 140,
      child: Text(
        nodo.nome,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isActive
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: state == _NodeState.inCorso
              ? FontWeight.w600
              : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildReviewBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'replay',
            color: theme.colorScheme.onTertiary,
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            'Ripasso',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onTertiary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(ThemeData theme, _NodeState state) {
    final completed = state == _NodeState.operativo ||
        state == _NodeState.comprensivo;
    return Container(
      width: 3,
      height: 32,
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1.5),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: completed
              ? [
                  theme.colorScheme.primary.withValues(alpha: 0.6),
                  theme.colorScheme.primary.withValues(alpha: 0.2),
                ]
              : [
                  theme.colorScheme.outline.withValues(alpha: 0.25),
                  theme.colorScheme.outline.withValues(alpha: 0.1),
                ],
        ),
      ),
    );
  }

  Color _circleColor(ThemeData theme, _NodeState state) {
    switch (state) {
      case _NodeState.nonIniziato:
        return theme.colorScheme.surfaceContainerHighest;
      case _NodeState.inCorso:
        return theme.colorScheme.primary.withValues(alpha: 0.15);
      case _NodeState.operativo:
        return theme.colorScheme.secondary.withValues(alpha: 0.2);
      case _NodeState.comprensivo:
        return theme.colorScheme.tertiary.withValues(alpha: 0.2);
    }
  }

  Color _circleBorderColor(ThemeData theme, _NodeState state) {
    switch (state) {
      case _NodeState.nonIniziato:
        return theme.colorScheme.outline.withValues(alpha: 0.3);
      case _NodeState.inCorso:
        return theme.colorScheme.primary;
      case _NodeState.operativo:
        return theme.colorScheme.secondary;
      case _NodeState.comprensivo:
        return theme.colorScheme.tertiary;
    }
  }

  Color _nodeIconColor(ThemeData theme, _NodeState state) {
    switch (state) {
      case _NodeState.nonIniziato:
        return theme.colorScheme.outline;
      case _NodeState.inCorso:
        return theme.colorScheme.primary;
      case _NodeState.operativo:
        return theme.colorScheme.secondary;
      case _NodeState.comprensivo:
        return theme.colorScheme.tertiary;
    }
  }

  String _nodeIcon(_NodeState state) {
    switch (state) {
      case _NodeState.nonIniziato:
        return 'circle_outlined';
      case _NodeState.inCorso:
        return 'play_arrow_rounded';
      case _NodeState.operativo:
        return 'check_circle';
      case _NodeState.comprensivo:
        return 'verified';
    }
  }

  _NodeState _getNodeState(String livello) {
    switch (livello) {
      case 'in_corso':
        return _NodeState.inCorso;
      case 'operativo':
        return _NodeState.operativo;
      case 'comprensivo':
      case 'connesso':
        return _NodeState.comprensivo;
      default:
        return _NodeState.nonIniziato;
    }
  }
}

enum _NodeState { nonIniziato, inCorso, operativo, comprensivo }
