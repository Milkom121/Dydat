import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/sizer_extensions.dart';
import '../../providers/quaderno_provider.dart';
import '../../widgets/custom_icon_widget.dart';
import 'widgets/esercizi_section.dart';
import 'widgets/formule_section.dart';
import 'widgets/spiegazioni_section.dart';
import 'widgets/stato_header.dart';

/// Schermata quaderno per un nodo — raccoglie appunti, esercizi, formule.
/// Il quaderno e uno per nodo (non per percorso).
class NodoQuadernoScreen extends ConsumerStatefulWidget {
  final String nodoId;
  final String nodoNome;

  const NodoQuadernoScreen({
    super.key,
    required this.nodoId,
    required this.nodoNome,
  });

  @override
  ConsumerState<NodoQuadernoScreen> createState() => _NodoQuadernoScreenState();
}

class _NodoQuadernoScreenState extends ConsumerState<NodoQuadernoScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    await ref.read(quadernoProvider.notifier).carica(widget.nodoId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(quadernoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.nodoNome,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(theme, state),
    );
  }

  Widget _buildBody(ThemeData theme, QuadernoState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'error_outline',
                color: theme.colorScheme.error,
                size: 12.w,
              ),
              SizedBox(height: 2.h),
              Text(
                state.error!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              FilledButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Riprova'),
              ),
            ],
          ),
        ),
      );
    }

    final quaderno = state.quaderno;
    if (quaderno == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        children: [
          // Header con stato nodo
          StatoHeader(quaderno: quaderno),
          SizedBox(height: 3.h),

          // Sezione Formule
          if (quaderno.formule.isNotEmpty) ...[
            FormuleSection(formule: quaderno.formule),
            SizedBox(height: 3.h),
          ],

          // Sezione Esercizi
          if (quaderno.esercizi.isNotEmpty) ...[
            EserciziSection(
              esercizi: quaderno.esercizi,
              totaleCorretti: quaderno.eserciziCorretti,
              totaleErrati: quaderno.eserciziErrati,
            ),
            SizedBox(height: 3.h),
          ],

          // Sezione Spiegazioni
          if (quaderno.spiegazioni.isNotEmpty) ...[
            SpiegazioniSection(spiegazioni: quaderno.spiegazioni),
            SizedBox(height: 3.h),
          ],

          // Messaggio vuoto se nessun dato
          if (quaderno.formule.isEmpty &&
              quaderno.esercizi.isEmpty &&
              quaderno.spiegazioni.isEmpty)
            _buildEmptyState(theme),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'auto_stories',
            color: theme.colorScheme.onSurfaceVariant,
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'Il quaderno si riempirà man mano che studi questo argomento.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Qui troverai formule, esercizi svolti e spiegazioni del tutor.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
