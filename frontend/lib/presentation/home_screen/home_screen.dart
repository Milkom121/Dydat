import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/sizer_extensions.dart';
import '../../models/sessione.dart';
import '../../providers/path_provider.dart';
import '../../providers/ripasso_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_router.dart';
import '../../theme/surface_decorations.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/onboarding_pending_banner.dart';
import '../studio_screen/widgets/session_history_widget.dart';
import 'widgets/mini_percorso_widget.dart';
import 'widgets/ripasso_section.dart';
import 'widgets/streak_card.dart';
import 'widgets/studio_transition_overlay.dart';
import 'widgets/welcome_header.dart';

/// Schermata Home — Tab 0 della navigazione principale.
/// Mostra benvenuto contestuale, mini-percorso, streak, ripasso FSRS,
/// storico sessioni e CTA per studiare.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Controlla la visibilità dell'overlay di transizione verso Studio.
  bool _showTransitionOverlay = false;
  // Destinazione a cui navigare dopo la transizione (es. con query param tipo=ripasso).
  String _transitionDestination = AppPaths.studio;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(sessionProvider.notifier).loadSessionHistory();
      ref.read(ripassoProvider.notifier).carica();
      ref.read(statsProvider.notifier).load();
      ref.read(userProvider.notifier).loadProfile();
      _loadPercorso();
    });
  }

  /// Ricarica tutti i dati della Home (per pull-to-refresh).
  Future<void> _handleRefresh() async {
    await Future.wait([
      ref.read(sessionProvider.notifier).loadSessionHistory(),
      ref.read(ripassoProvider.notifier).carica(),
      ref.read(statsProvider.notifier).load(),
      ref.read(userProvider.notifier).loadProfile(),
      _loadPercorso(),
    ]);
  }

  /// Carica i percorsi e la mappa del primo percorso attivo.
  Future<void> _loadPercorso() async {
    final pathNotifier = ref.read(pathProvider.notifier);
    await pathNotifier.loadPaths();
    final paths = ref.read(pathProvider).paths;
    if (paths.isNotEmpty) {
      final attivo = paths.firstWhere(
        (p) => p.stato == 'attivo',
        orElse: () => paths.first,
      );
      await pathNotifier.loadMap(attivo.id);
    }
  }

  void _avviaStudio() {
    HapticFeedback.lightImpact();
    setState(() {
      _transitionDestination = AppPaths.studio;
      _showTransitionOverlay = true;
    });
  }

  void _avviaRipasso() {
    HapticFeedback.lightImpact();
    setState(() {
      _transitionDestination = '${AppPaths.studio}?tipo=ripasso';
      _showTransitionOverlay = true;
    });
  }

  void _onTransitionComplete() {
    if (!mounted) return;
    setState(() => _showTransitionOverlay = false);
    context.push(_transitionDestination);
  }

  void _navigaOnboarding({bool resume = false}) {
    HapticFeedback.lightImpact();
    final path = resume
        ? '${AppPaths.onboarding}?resume=true'
        : AppPaths.onboarding;
    context.push(path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionState = ref.watch(sessionProvider);
    final ripassoState = ref.watch(ripassoProvider);
    final statsState = ref.watch(statsProvider);
    final pathState = ref.watch(pathProvider);
    final userState = ref.watch(userProvider);

    final hasActiveSession = sessionState.activeSession?.stato == 'attiva';
    final lastNodeName = _ultimoNodoFormattato(sessionState.sessionHistory);

    // Determina se mostrare il banner onboarding
    final onboardingStato = userState.profile?.onboardingStato;
    final mostraBannerOnboarding = onboardingStato != null &&
        onboardingStato != 'completed';

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home, size: 24, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Dydat', style: theme.textTheme.titleLarge),
              ],
            ),
            automaticallyImplyLeading: false,
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            elevation: 1.0,
            shadowColor: theme.colorScheme.shadow,
          ),
          body: Container(
            decoration: DydatSurface.backgroundGradient(context),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: theme.colorScheme.primary,
                child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 3.h),

                    // 1. Saluto contestuale con ritorno intelligente
                    WelcomeHeader(
                      sessionHistory: sessionState.sessionHistory,
                      hasActiveSession: hasActiveSession,
                      lastNodeName: lastNodeName,
                    ),

                    // Banner onboarding (se non completato)
                    if (mostraBannerOnboarding) ...[
                      SizedBox(height: 2.h),
                      OnboardingPendingBanner(
                        stato: onboardingStato == 'in_progress'
                            ? OnboardingBannerStato.inCorso
                            : OnboardingBannerStato.nonIniziato,
                        onTap: () => _navigaOnboarding(
                          resume: onboardingStato == 'in_progress',
                        ),
                      ),
                    ],

                    SizedBox(height: 3.h),

                    // 2. Bottone CTA principale
                    _buildBottoneStudio(theme, hasActiveSession),

                    // 3. Streak e statistiche (da backend)
                    if (statsState.stats != null) ...[
                      SizedBox(height: 2.5.h),
                      StreakCard(stats: statsState.stats!),
                    ],

                    // 4. Mini-percorso visivo (mappa nodi con posizione corrente)
                    if (pathState.currentMap != null &&
                        pathState.currentMap!.nodi.isNotEmpty) ...[
                      SizedBox(height: 2.5.h),
                      MiniPercorsoWidget(mappa: pathState.currentMap!),
                    ],

                    // 5. Sezione ripasso FSRS (migliorata con lista nodi)
                    if (ripassoState.nodi.isNotEmpty) ...[
                      SizedBox(height: 2.5.h),
                      RipassoSection(
                        nodi: ripassoState.nodi,
                        onRipassoTap: _avviaRipasso,
                      ),
                    ],

                    // 6. Storico sessioni
                    SizedBox(height: 3.h),
                    SessionHistoryWidget(
                      sessions: sessionState.sessionHistory,
                      isLoading: sessionState.isLoadingHistory,
                      onSessionTap: (sessioneId) {
                        context.go(AppPaths.recapSession(sessioneId));
                      },
                    ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
              ),
            ),
          ),
        ),

        // Overlay di transizione: mostra mascotte animata prima di navigare a Studio.
        if (_showTransitionOverlay)
          Positioned.fill(
            child: StudioTransitionOverlay(
              onComplete: _onTransitionComplete,
            ),
          ),
      ],
    );
  }

  Widget _buildBottoneStudio(ThemeData theme, bool hasActiveSession) {
    final hasHistory = ref.read(sessionProvider).sessionHistory.isNotEmpty;
    final String label;
    if (hasActiveSession) {
      label = 'Riprendi la sessione';
    } else if (hasHistory) {
      label = 'Riprendi a studiare';
    } else {
      label = 'Inizia a studiare';
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _avviaStudio,
        icon: CustomIconWidget(
          iconName: 'school',
          color: theme.colorScheme.onPrimary,
          size: 20,
        ),
        label: Text(label),
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
        ),
      ),
    );
  }

  String? _ultimoNodoFormattato(List<SessioneListItem> history) {
    if (history.isEmpty) return null;
    final last = history.first;
    return homeFormatNodeName(last.nodoFocaleNome ?? last.nodoFocaleId);
  }
}

// ---------------------------------------------------------------------------
// Helper puri — top-level per facilitare i test
// ---------------------------------------------------------------------------

/// Formatta un nodo ID/nome in stringa leggibile.
///
/// "mat_MatematicaC3_Algebra1_numeri_relativi" → "Numeri relativi"
String? homeFormatNodeName(String? raw) {
  if (raw == null) return null;
  if (!raw.contains('_')) return raw;
  final parts = raw.split('_');
  int start = 0;
  for (int i = 0; i < parts.length; i++) {
    if (parts[i].isNotEmpty &&
        parts[i] == parts[i].toLowerCase() &&
        !parts[i].startsWith('mat')) {
      start = i;
      break;
    }
  }
  if (start == 0 && parts.length > 1) {
    start = parts.length > 3 ? 3 : 1;
  }
  final name = parts.sublist(start).join(' ');
  if (name.isEmpty) return raw;
  return name[0].toUpperCase() + name.substring(1);
}

/// Giorni trascorsi dall'ultima sessione. Null se nessuna sessione.
int? homeGiorniDaUltimaSessione(List<SessioneListItem> history) {
  if (history.isEmpty) return null;
  final createdAt = history.first.createdAt;
  if (createdAt == null) return null;
  try {
    final dt = DateTime.parse(createdAt);
    return DateTime.now().difference(dt).inDays;
  } catch (_) {
    return null;
  }
}

/// Calcola il numero di giorni consecutivi di studio (streak).
/// Conta a ritroso da oggi (o ieri se oggi non c'e sessione).
int homeCalcolaStreak(List<SessioneListItem> history) {
  if (history.isEmpty) return 0;

  final oggi = DateTime.now();
  final oggiDate = DateTime(oggi.year, oggi.month, oggi.day);

  // Raccoglie le date normalizzate con almeno una sessione
  final dateConSessioni = <DateTime>{};
  for (final s in history) {
    if (s.createdAt != null) {
      try {
        final dt = DateTime.parse(s.createdAt!);
        dateConSessioni.add(DateTime(dt.year, dt.month, dt.day));
      } catch (_) {}
    }
  }

  if (dateConSessioni.isEmpty) return 0;

  // Parte da oggi, altrimenti da ieri
  DateTime start = oggiDate;
  if (!dateConSessioni.contains(start)) {
    start = start.subtract(const Duration(days: 1));
    if (!dateConSessioni.contains(start)) return 0;
  }

  // Conta a ritroso
  int streak = 0;
  DateTime check = start;
  while (dateConSessioni.contains(check)) {
    streak++;
    check = check.subtract(const Duration(days: 1));
  }

  return streak;
}
