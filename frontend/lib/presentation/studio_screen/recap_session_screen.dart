import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/sizer_extensions.dart';
import '../../models/sessione.dart';
import '../../models/statistiche.dart';
import '../../models/tema.dart';
import '../../providers/path_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/stats_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/skeleton_loader.dart';

class RecapSessionScreen extends ConsumerStatefulWidget {
  final String sessioneId;

  const RecapSessionScreen({super.key, required this.sessioneId});

  @override
  ConsumerState<RecapSessionScreen> createState() => _RecapSessionScreenState();
}

class _RecapSessionScreenState extends ConsumerState<RecapSessionScreen> {
  Sessione? _session;
  StatisticheUtente? _stats;
  List<Tema> _completedTemi = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Defer provider modification to avoid "modify during build" error.
    Future.microtask(_loadData);
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load session data, stats, and topics in parallel
      await Future.wait([
        ref.read(sessionProvider.notifier).loadSession(widget.sessioneId),
        ref.read(statsProvider.notifier).load(),
        ref.read(pathProvider.notifier).loadTopics(),
      ]);

      if (mounted) {
        final session = ref.read(sessionProvider).activeSession;
        final topics = ref.read(pathProvider).topics;

        // Find completed temi that overlap with this session's worked nodes
        final nodiLavorati = session?.nodiLavorati ?? [];
        final completed = <Tema>[];
        if (nodiLavorati.isNotEmpty) {
          for (final tema in topics) {
            if (tema.completato) {
              completed.add(tema);
            }
          }
        }

        setState(() {
          _session = session;
          _stats = ref.read(statsProvider).stats;
          _completedTemi = completed;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Errore caricamento dati: $e';
        });
      }
    }
  }

  String _formatDuration(int? minutes) {
    if (minutes == null || minutes == 0) return '--';
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}min' : '${h}h';
  }

  String _formatNodeName(String? name) => recapFormatNodeName(name);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Riepilogo sessione', style: theme.textTheme.titleLarge),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const RecapSkeleton()
            : _error != null
                ? _buildErrorState(theme)
                : _buildContent(theme),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: theme.colorScheme.error,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'Si e verificato un errore nel caricamento dei dati.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () => context.go(AppPaths.home),
              child: Text(
                'Torna alla home',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildNarrativa(Sessione session) => recapBuildNarrativa(session);

  Widget _buildContent(ThemeData theme) {
    final session = _session;
    final nodiLavorati = session?.nodiLavorati ?? [];
    final durata = session?.durataEffettivaMin;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Completion icon
          Center(
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 12.w,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Sessione completata!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),

          // Narrativa del tutor — prima di tutto
          if (session != null) ...[
            _buildNarrativaCard(theme, session),
            SizedBox(height: 2.h),
          ],

          // Stats cards row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: 'timer',
                  value: _formatDuration(durata),
                  label: 'Durata',
                  theme: theme,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _StatCard(
                  icon: 'route',
                  value: '${nodiLavorati.length}',
                  label: 'Nodi lavorati',
                  theme: theme,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Focus node card
          if (session?.nodoFocaleNome != null ||
              session?.nodoFocaleId != null) ...[
            _InfoCard(
              icon: 'school',
              title: 'Nodo focale',
              content: _formatNodeName(
                session?.nodoFocaleNome ?? session?.nodoFocaleId,
              ),
              theme: theme,
            ),
            SizedBox(height: 2.h),
          ],

          // Nodes worked list
          if (nodiLavorati.isNotEmpty) ...[
            _InfoCard(
              icon: 'checklist',
              title: 'Nodi lavorati',
              content: nodiLavorati.map(_formatNodeName).join('\n'),
              theme: theme,
            ),
            SizedBox(height: 2.h),
          ],

          // Completed temi celebration
          if (_completedTemi.isNotEmpty) ...[
            ..._completedTemi.map(
              (tema) => _buildCompletedTemaCard(theme, tema),
            ),
            SizedBox(height: 2.h),
          ],

          // Updated statistics section
          if (_stats != null) ...[
            _buildStatsSection(theme),
            SizedBox(height: 3.h),
          ],

          // Back button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                // Clear session state before going back
                ref.read(sessionProvider.notifier).clear();
                context.go(AppPaths.home);
              },
              icon: CustomIconWidget(
                iconName: 'home',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text(
                'Torna alla home',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  /// Card narrativa del tutor — mostra un commento caldo sui progressi della sessione.
  Widget _buildNarrativaCard(ThemeData theme, Sessione session) {
    final narrativa = _buildNarrativa(session);
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary,
            ),
            child: Icon(
              Icons.school,
              size: 5.w,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dal tuo tutor',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.8.h),
                Text(
                  narrativa,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTemaCard(ThemeData theme, Tema tema) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.secondary.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events,
                size: 6.w,
                color: theme.colorScheme.secondary,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tema completato!',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    tema.nome,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${tema.nodiTotali} nodi completati',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    final stats = _stats!;
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Le tue statistiche',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  value: '${stats.streak}',
                  label: 'Serie',
                  icon: 'local_fire_department',
                  theme: theme,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  value: '${stats.nodiCompletati}',
                  label: 'Nodi totali',
                  icon: 'check_circle',
                  theme: theme,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  value: '${stats.sessioniCompletate}',
                  label: 'Sessioni',
                  icon: 'auto_stories',
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final ThemeData theme;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.5.h, horizontal: 3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String icon;
  final String title;
  final String content;
  final ThemeData theme;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: icon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Funzioni pure top-level — esposte per test
// ---------------------------------------------------------------------------

/// Formatta un node ID/nome in stringa leggibile per il recap.
/// Null → 'Non specificato', nomi senza underscore passano invariati.
String recapFormatNodeName(String? name) {
  if (name == null) return 'Non specificato';
  if (!name.contains('_')) return name;
  final parts = name.split('_');
  int start = 0;
  for (int i = 0; i < parts.length; i++) {
    if (parts[i].isNotEmpty &&
        parts[i] == parts[i].toLowerCase() &&
        !parts[i].startsWith('mat')) {
      start = i;
      break;
    }
  }
  if (start == 0 && parts.length > 1) start = parts.length > 3 ? 3 : 1;
  final formatted = parts.sublist(start).join(' ');
  return formatted.isNotEmpty
      ? formatted[0].toUpperCase() + formatted.substring(1)
      : name;
}

/// Genera il commento narrativo del tutor per il recap di sessione.
/// Tono caldo e motivazionale — prima il commento, poi i numeri.
String recapBuildNarrativa(Sessione session) {
  final nome = recapFormatNodeName(
    session.nodoFocaleNome ?? session.nodoFocaleId,
  );
  final nodiCount = session.nodiLavorati?.length ?? 0;
  final durata = session.durataEffettivaMin;

  final buffer = StringBuffer();

  // Prima parte: cosa si è lavorato
  if (nome != 'Non specificato') {
    buffer.write('Oggi hai lavorato su "$nome"');
  } else {
    buffer.write('Ottimo lavoro oggi');
  }

  if (nodiCount > 1) {
    buffer.write(
      ' e altri ${nodiCount - 1} '
      '${nodiCount - 1 == 1 ? 'argomento' : 'argomenti'}',
    );
  }
  buffer.write('.');

  // Seconda parte: incoraggiamento in base alla durata
  if (durata != null && durata > 0) {
    if (durata < 10) {
      buffer.write(
        ' Anche una sessione breve fa la differenza — la costanza è tutto.',
      );
    } else if (durata < 30) {
      buffer.write(' Stai costruendo un\'abitudine solida.');
    } else {
      buffer.write(' Una sessione intensa — il cervello ha lavorato bene!');
    }
  } else {
    buffer.write(' Ogni sessione ti avvicina al tuo obiettivo.');
  }

  // Terza parte: invito al prossimo incontro
  if (nome != 'Non specificato') {
    buffer.write(
      ' La prossima volta approfondiremo ancora "$nome" e vedremo cosa viene dopo.',
    );
  }

  return buffer.toString();
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final String icon;
  final ThemeData theme;

  const _MiniStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: theme.colorScheme.tertiary,
          size: 20,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
