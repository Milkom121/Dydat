import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/sizer_extensions.dart';
import '../../theme/surface_decorations.dart';

import '../../models/percorso.dart';
import '../../models/tema.dart';
import '../../providers/path_provider.dart';
import '../../providers/ripasso_provider.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/graph_overview.dart';
import './widgets/linear_path_map.dart';
import './widgets/node_detail_bottom_sheet.dart';

/// "I miei studi" — Mappa del percorso con vista lineare e grafo.
/// Riscritta in B34: da lista card a mappa visiva nodi.
class LearningPathScreen extends ConsumerStatefulWidget {
  const LearningPathScreen({super.key});

  @override
  ConsumerState<LearningPathScreen> createState() =>
      _LearningPathScreenState();
}

class _LearningPathScreenState extends ConsumerState<LearningPathScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isGraphView = false;

  @override
  void initState() {
    super.initState();
    // Carica percorsi, mappa e nodi SR
    Future.microtask(() => _loadData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final notifier = ref.read(pathProvider.notifier);
    // Carica percorsi e temi in parallelo
    await Future.wait([
      notifier.loadPaths(),
      notifier.loadTopics(),
      ref.read(ripassoProvider.notifier).carica(),
    ]);
    // Carica la mappa del percorso attivo
    final paths = ref.read(pathProvider).paths;
    if (paths.isNotEmpty) {
      final activePath = paths.firstWhere(
        (p) => p.stato == 'attivo',
        orElse: () => paths.first,
      );
      await notifier.loadMap(activePath.id);
    }
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  void _showNodeDetail(NodoMappa nodo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NodeDetailBottomSheet(nodo: nodo),
    );
  }

  /// IDs dei nodi che matchano la ricerca (vuoto = mostra tutti)
  Set<String> _getHighlightedNodeIds(List<NodoMappa> nodi) {
    if (_searchQuery.isEmpty) return {};
    final query = _searchQuery.toLowerCase();
    return nodi
        .where((n) => n.nome.toLowerCase().contains(query))
        .map((n) => n.id)
        .toSet();
  }

  /// Set di nodo_id da ripassare
  Set<String> _getNodiDaRipassare() {
    final ripassoState = ref.read(ripassoProvider);
    return ripassoState.nodi.map((n) => n.nodoId).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pathState = ref.watch(pathProvider);
    final nodi = pathState.currentMap?.nodi ?? [];
    final topics = pathState.topics;
    final isLoading = pathState.isLoading;
    final error = pathState.error;

    // Osserva ripasso per rebuild quando cambia
    ref.watch(ripassoProvider);
    final nodiDaRipassare = _getNodiDaRipassare();
    final highlightedIds = _getHighlightedNodeIds(nodi);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme, nodi.length),
      body: Container(
        decoration: DydatSurface.backgroundGradient(context),
        child: SafeArea(
          child: Column(
          children: [
            // Barra di ricerca
            _buildSearchBar(theme),
            // Contenuto principale
            Expanded(
              child: _buildBody(
                theme,
                nodi,
                topics,
                isLoading,
                error,
                nodiDaRipassare,
                highlightedIds,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, int nodeCount) {
    return AppBar(
      title: Row(
        children: [
          Icon(Icons.map_outlined, size: 24, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text('I miei studi', style: theme.textTheme.titleLarge),
        ],
      ),
      actions: [
        // Ricarica dati
        IconButton(
          icon: Icon(Icons.refresh, color: theme.colorScheme.onSurface),
          tooltip: 'Aggiorna',
          onPressed: () => _handleRefresh(),
        ),
        // Toggle vista lineare / grafo
        IconButton(
          icon: CustomIconWidget(
            iconName: _isGraphView ? 'view_list' : 'account_tree',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          tooltip: _isGraphView ? 'Vista lineare' : 'Vista grafo',
          onPressed: () {
            setState(() => _isGraphView = !_isGraphView);
          },
        ),
      ],
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cerca argomento...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 3.w,
            vertical: 1.2.h,
          ),
        ),
        style: theme.textTheme.bodyMedium,
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    List<NodoMappa> nodi,
    List<Tema> topics,
    bool isLoading,
    String? error,
    Set<String> nodiDaRipassare,
    Set<String> highlightedIds,
  ) {
    // Caricamento iniziale
    if (isLoading && nodi.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      );
    }

    // Errore senza dati
    if (error != null && nodi.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () => _loadData(),
              child: const Text('Riprova'),
            ),
          ],
        ),
      );
    }

    // Stato vuoto (nessun percorso/nodo)
    if (nodi.isEmpty) {
      return EmptyStateWidget(
        onStartLearning: () => context.push('/studio'),
      );
    }

    // Nessun risultato di ricerca
    if (_searchQuery.isNotEmpty && highlightedIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: theme.colorScheme.onSurfaceVariant,
              size: 12.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'Nessun argomento trovato per "$_searchQuery"',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Vista lineare o grafo
    if (_isGraphView) {
      // Nodi del percorso attivo per evidenziarli nel grafo
      final mapNodi = ref.read(pathProvider).currentMap?.nodi ?? [];
      final activePathIds = mapNodi.map((n) => n.id).toSet();
      // Primo nodo non completato = nodo corrente
      String? currentNodeId;
      for (final n in mapNodi) {
        if (n.livello != 'operativo' && n.livello != 'comprensivo' && n.livello != 'connesso') {
          currentNodeId = n.id;
          break;
        }
      }

      return GraphOverview(
        nodi: nodi,
        temi: topics,
        nodiDaRipassare: nodiDaRipassare,
        highlightedNodeIds: highlightedIds,
        activePathNodeIds: activePathIds,
        currentNodeId: currentNodeId,
        onNodeTap: _showNodeDetail,
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: theme.colorScheme.primary,
      child: LinearPathMap(
        nodi: nodi,
        nodiDaRipassare: nodiDaRipassare,
        highlightedNodeIds: highlightedIds,
        onNodeTap: _showNodeDetail,
      ),
    );
  }
}
