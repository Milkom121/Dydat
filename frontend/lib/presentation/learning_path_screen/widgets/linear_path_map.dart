import 'package:flutter/material.dart';
import '../../../core/sizer_extensions.dart';
import '../../../models/percorso.dart';
import '../../../theme/surface_decorations.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Mappa lineare verticale del percorso: nodi come cerchi collegati da linee.
/// Ogni nodo mostra nome, stato (colore/icona) e badge ripasso se applicabile.
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

        return _NodeRow(
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

class _NodeRow extends StatelessWidget {
  final NodoMappa nodo;
  final bool isLast;
  final bool isHighlighted;
  final bool needsReview;
  final VoidCallback onTap;

  const _NodeRow({
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

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: opacity,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colonna sinistra: cerchio + linea di connessione
              SizedBox(
                width: 12.w,
                child: Column(
                  children: [
                    _buildNodeCircle(context, theme, nodeState),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: _connectionColor(theme, nodeState),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 3.w),
              // Colonna destra: nome + info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 2.h),
                  child: _buildNodeContent(context, theme, nodeState),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNodeCircle(BuildContext context, ThemeData theme, _NodeState state) {
    final size = 10.w;
    final color = _circleColor(theme, state);
    final borderColor = _circleBorderColor(theme, state);
    final hasGlow = state == _NodeState.inCorso ||
        state == _NodeState.operativo ||
        state == _NodeState.comprensivo;

    return Container(
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
          size: 5.w,
        ),
      ),
    );
  }

  Widget _buildNodeContent(BuildContext context, ThemeData theme, _NodeState state) {
    final isActive = state != _NodeState.nonIniziato;

    return Container(
      constraints: BoxConstraints(minHeight: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      decoration: state == _NodeState.inCorso
          ? DydatSurface.glowCard(context, borderRadius: 12.0, glowIntensity: 0.2)
          : DydatSurface.card(context, borderRadius: 12.0, depthLevel: isActive ? 1 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nodo.nome,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isActive
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight:
                        state == _NodeState.inCorso ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (needsReview) _buildReviewBadge(theme),
              if (nodo.presunto) ...[
                SizedBox(width: 1.w),
                _buildPresuntoBadge(theme),
              ],
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            _stateLabel(state),
            style: theme.textTheme.bodySmall?.copyWith(
              color: _stateLabelColor(theme, state),
            ),
          ),
          if (nodo.eserciziCompletati > 0) ...[
            SizedBox(height: 0.3.h),
            Text(
              '${nodo.eserciziCompletati} esercizi completati',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
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

  Widget _buildPresuntoBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'presunto',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.tertiary,
          fontSize: 10,
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

  Color _connectionColor(ThemeData theme, _NodeState state) {
    switch (state) {
      case _NodeState.nonIniziato:
        return theme.colorScheme.outline.withValues(alpha: 0.15);
      case _NodeState.inCorso:
        return theme.colorScheme.primary.withValues(alpha: 0.4);
      case _NodeState.operativo:
        return theme.colorScheme.secondary.withValues(alpha: 0.4);
      case _NodeState.comprensivo:
        return theme.colorScheme.tertiary.withValues(alpha: 0.4);
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
        return 'radio_button_unchecked';
      case _NodeState.inCorso:
        return 'timelapse';
      case _NodeState.operativo:
        return 'check_circle';
      case _NodeState.comprensivo:
        return 'verified';
    }
  }

  String _stateLabel(_NodeState state) {
    switch (state) {
      case _NodeState.nonIniziato:
        return 'Da iniziare';
      case _NodeState.inCorso:
        return 'In corso';
      case _NodeState.operativo:
        return 'Operativo';
      case _NodeState.comprensivo:
        return 'Comprensivo';
    }
  }

  Color _stateLabelColor(ThemeData theme, _NodeState state) {
    switch (state) {
      case _NodeState.nonIniziato:
        return theme.colorScheme.onSurfaceVariant;
      case _NodeState.inCorso:
        return theme.colorScheme.primary;
      case _NodeState.operativo:
        return theme.colorScheme.secondary;
      case _NodeState.comprensivo:
        return theme.colorScheme.tertiary;
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
