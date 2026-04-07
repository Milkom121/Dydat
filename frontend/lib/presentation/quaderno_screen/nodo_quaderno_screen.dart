import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/sizer_extensions.dart';
import '../../models/quaderno.dart';
import '../../providers/quaderno_provider.dart';
import '../../widgets/custom_icon_widget.dart';
import 'widgets/collapsible_text.dart';
import 'widgets/errore_comune_card.dart';
import 'widgets/esercizi_section.dart';
import 'widgets/formula_curriculum_card.dart';
import 'widgets/formule_section.dart';
import 'widgets/nota_utente_editor.dart';
import 'widgets/spiegazioni_section.dart';
import 'widgets/stato_header.dart';

/// Schermata quaderno per un nodo — raccoglie scheda curricolare, appunti,
/// esercizi, formule e spiegazioni. Il quaderno e uno per nodo (non per percorso).
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
          // 1. Header con stato nodo
          StatoHeader(quaderno: quaderno),
          SizedBox(height: 2.h),

          // 2. Breadcrumb: tema > nodo
          if (quaderno.temaNome != null) ...[
            _buildBreadcrumb(theme, quaderno),
            SizedBox(height: 2.h),
          ],

          // 3. Chip parole chiave
          if (_hasParoleChiave(quaderno)) ...[
            _buildParoleChiave(theme, quaderno.scheda!.paroleChiave),
            SizedBox(height: 2.5.h),
          ],

          // 4. Cosa imparerai (definizione collassabile)
          if (_hasDefinizione(quaderno)) ...[
            _buildSectionTitle(
              theme,
              icon: 'lightbulb',
              title: 'Cosa imparerai',
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: 1.h),
            CollapsibleText(
              text: quaderno.scheda!.definizioneTesto!,
              maxChars: 200,
            ),
            SizedBox(height: 3.h),
          ],

          // 5. Formule chiave (curricolari, da KB)
          if (_hasFormuleCurriculum(quaderno)) ...[
            _buildSectionTitle(
              theme,
              icon: 'functions',
              title: 'Formule chiave',
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: 1.h),
            ...quaderno.scheda!.formule
                .map((f) => FormulaCurriculumCard(formula: f)),
            SizedBox(height: 3.h),
          ],

          // 6. Esempi
          if (_hasEsempi(quaderno)) ...[
            _buildSectionTitle(
              theme,
              icon: 'format_list_numbered',
              title: 'Esempi',
              color: theme.colorScheme.secondary,
            ),
            SizedBox(height: 1.h),
            ...quaderno.scheda!.esempi.map((e) => _buildEsempio(theme, e)),
            SizedBox(height: 3.h),
          ],

          // 7. Attenzione a... (errori comuni)
          if (_hasErroriComuni(quaderno)) ...[
            _buildSectionTitle(
              theme,
              icon: 'warning_amber',
              title: 'Attenzione a...',
              color: theme.colorScheme.error,
            ),
            SizedBox(height: 1.h),
            ...quaderno.scheda!.erroriComuni
                .map((e) => ErroreComuneCard(errore: e)),
            SizedBox(height: 3.h),
          ],

          // 8. Le mie note (editor autosave)
          NotaUtenteEditor(
            initialText: quaderno.notaUtente?.testo,
            isSaving: state.isSaving,
            onSave: (testo) {
              ref
                  .read(quadernoProvider.notifier)
                  .saveNota(widget.nodoId, testo);
            },
          ),
          SizedBox(height: 3.h),

          // 9. Separator tra scheda curricolare e log personale
          if (_hasLogPersonale(quaderno)) ...[
            _buildSeparator(theme),
            SizedBox(height: 3.h),
          ],

          // 10. Log personale: formule tutor + esercizi + spiegazioni
          if (quaderno.formule.isNotEmpty) ...[
            FormuleSection(formule: quaderno.formule),
            SizedBox(height: 3.h),
          ],

          if (quaderno.esercizi.isNotEmpty) ...[
            EserciziSection(
              esercizi: quaderno.esercizi,
              totaleCorretti: quaderno.eserciziCorretti,
              totaleErrati: quaderno.eserciziErrati,
            ),
            SizedBox(height: 3.h),
          ],

          if (quaderno.spiegazioni.isNotEmpty) ...[
            SpiegazioniSection(spiegazioni: quaderno.spiegazioni),
            SizedBox(height: 3.h),
          ],

          // Stato vuoto se non c'e nulla
          if (_isCompletelyEmpty(quaderno)) _buildEmptyState(theme),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper: verifica contenuto
  // ---------------------------------------------------------------------------

  bool _hasParoleChiave(QuadernoNodo q) =>
      q.scheda != null && q.scheda!.paroleChiave.isNotEmpty;

  bool _hasDefinizione(QuadernoNodo q) =>
      q.scheda != null &&
      q.scheda!.definizioneTesto != null &&
      q.scheda!.definizioneTesto!.isNotEmpty;

  bool _hasFormuleCurriculum(QuadernoNodo q) =>
      q.scheda != null && q.scheda!.formule.isNotEmpty;

  bool _hasEsempi(QuadernoNodo q) =>
      q.scheda != null && q.scheda!.esempi.isNotEmpty;

  bool _hasErroriComuni(QuadernoNodo q) =>
      q.scheda != null && q.scheda!.erroriComuni.isNotEmpty;

  bool _hasLogPersonale(QuadernoNodo q) =>
      q.formule.isNotEmpty ||
      q.esercizi.isNotEmpty ||
      q.spiegazioni.isNotEmpty;

  bool _isCompletelyEmpty(QuadernoNodo q) =>
      !_hasDefinizione(q) &&
      !_hasFormuleCurriculum(q) &&
      !_hasEsempi(q) &&
      !_hasErroriComuni(q) &&
      !_hasLogPersonale(q);

  // ---------------------------------------------------------------------------
  // Sub-widget: breadcrumb
  // ---------------------------------------------------------------------------

  Widget _buildBreadcrumb(ThemeData theme, QuadernoNodo quaderno) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'folder_open',
          color: theme.colorScheme.onSurfaceVariant,
          size: 4.w,
        ),
        SizedBox(width: 1.5.w),
        Text(
          quaderno.temaNome!,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.5.w),
          child: CustomIconWidget(
            iconName: 'chevron_right',
            color: theme.colorScheme.outline,
            size: 4.w,
          ),
        ),
        Flexible(
          child: Text(
            quaderno.nodoNome,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-widget: chip parole chiave
  // ---------------------------------------------------------------------------

  Widget _buildParoleChiave(ThemeData theme, List<String> parole) {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: parole.map((p) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  theme.colorScheme.secondary.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            p,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-widget: titolo sezione generico
  // ---------------------------------------------------------------------------

  Widget _buildSectionTitle(
    ThemeData theme, {
    required String icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        CustomIconWidget(iconName: icon, color: color, size: 5.w),
        SizedBox(width: 2.w),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-widget: esempio singolo
  // ---------------------------------------------------------------------------

  Widget _buildEsempio(ThemeData theme, String esempio) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomIconWidget(
            iconName: 'arrow_right',
            color: theme.colorScheme.secondary,
            size: 4.5.w,
          ),
          SizedBox(width: 1.5.w),
          Expanded(
            child: Text(
              esempio,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-widget: separator
  // ---------------------------------------------------------------------------

  Widget _buildSeparator(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: Text(
            'Il tuo percorso',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-widget: stato vuoto
  // ---------------------------------------------------------------------------

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
