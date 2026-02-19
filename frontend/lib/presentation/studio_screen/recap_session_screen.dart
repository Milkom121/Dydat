import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/sizer_extensions.dart';
import '../../models/sessione.dart';
import '../../models/statistiche.dart';
import '../../providers/session_provider.dart';
import '../../providers/stats_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/custom_icon_widget.dart';

class RecapSessionScreen extends ConsumerStatefulWidget {
  final String sessioneId;

  const RecapSessionScreen({super.key, required this.sessioneId});

  @override
  ConsumerState<RecapSessionScreen> createState() => _RecapSessionScreenState();
}

class _RecapSessionScreenState extends ConsumerState<RecapSessionScreen> {
  Sessione? _session;
  StatisticheUtente? _stats;
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
      // Load session data and refresh stats in parallel
      await Future.wait([
        ref.read(sessionProvider.notifier).loadSession(widget.sessioneId),
        ref.read(statsProvider.notifier).load(),
      ]);

      if (mounted) {
        setState(() {
          _session = ref.read(sessionProvider).activeSession;
          _stats = ref.read(statsProvider).stats;
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

  String _formatNodeName(String? name) {
    if (name == null) return 'Non specificato';
    if (!name.contains('_')) return name;
    // Format raw node IDs: "mat_Algebra1_numeri_naturali" -> "Numeri naturali"
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
            ? const Center(child: CircularProgressIndicator())
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
              onPressed: () => context.go(AppPaths.studio),
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
          SizedBox(height: 3.h),

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
                context.go(AppPaths.studio);
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
                  label: 'Streak',
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
