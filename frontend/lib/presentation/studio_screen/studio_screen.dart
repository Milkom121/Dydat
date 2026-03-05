import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/sizer_extensions.dart';
import '../../models/sse_events.dart';
import '../../providers/session_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/markdown_text.dart';
import './widgets/achievement_toast_widget.dart';
import './widgets/backtrack_card_widget.dart';
import './widgets/celebration_overlay.dart';
import './widgets/chiudi_sessione_card_widget.dart';
import './widgets/exercise_card_widget.dart';
import './widgets/formula_card_widget.dart';
import './widgets/mascotte_widget.dart';
import './widgets/session_history_widget.dart';
import './widgets/tools_tray_widget.dart';
import './widgets/tutor_message_widget.dart';
import './widgets/tutor_panel_widget.dart';

class StudioScreen extends ConsumerStatefulWidget {
  const StudioScreen({super.key});

  /// Notifier that increments when the Studio tab is re-tapped.
  /// Listened by _StudioScreenState to navigate back to home view.
  static final tabReTapNotifier = ValueNotifier<int>(0);

  @override
  ConsumerState<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends ConsumerState<StudioScreen>
    with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  bool _isToolsTrayVisible = false;
  bool _isTutorPanelVisible = false;

  /// Guard: prevents infinite loadSessionHistory calls from build().
  /// Set true after first attempt; reset when navigating away or starting session.
  bool _historyLoadAttempted = false;

  /// When true, show the home view (history + "Inizia") even if session is active.
  /// Used when user navigates "back" from an active session.
  bool _showingHome = false;

  // Local chat items (user messages + finalized tutor messages + action cards).
  final List<Map<String, dynamic>> _messages = [];

  // Timer state
  Timer? _timer;
  int _sessionSeconds = 0;
  String _sessionTime = '00:00';

  // Track synced state for detecting new finalized messages and actions.
  int _prevTutorMessagesCount = 0;
  int _prevActionsCount = 0;
  int _prevAchievementsCount = 0;

  // True if we auto-suspended the session when going to background.
  bool _suspendedInBackground = false;

  // Track whether we've already triggered a celebration for the current esito.
  EsitoEsercizioEvent? _lastTriggeredEsito;

  // Track whether we've already triggered a celebration for the current promotion.
  PromozioneEvent? _lastTriggeredPromotion;

  // Track the last error we showed in a snackbar to avoid duplicate snackbars.
  String? _lastShownError;

  // Timestamp of the most recent celebration (promotion or correct esito).
  // Used to keep mascotte in celebrating state for a short window.
  DateTime? _lastCelebrationTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    StudioScreen.tabReTapNotifier.addListener(_onTabReTap);
    Future.microtask(() {
      ref.read(sessionProvider.notifier).loadSessionHistory();
    });
  }

  void _onTabReTap() {
    if (mounted && !_showingHome) {
      final session = ref.read(sessionProvider).activeSession;
      if (session != null && session.stato == 'attiva') {
        setState(() {
          _showingHome = true;
          _historyLoadAttempted = false;
        });
        ref.read(sessionProvider.notifier).loadSessionHistory();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    StudioScreen.tabReTapNotifier.removeListener(_onTabReTap);
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        // App went to background — suspend active session
        if (_isSessionActive && !_suspendedInBackground) {
          _suspendedInBackground = true;
          _stopTimer();
          ref.read(sessionProvider.notifier).suspend();
        }
      case AppLifecycleState.resumed:
        if (_suspendedInBackground) {
          _suspendedInBackground = false;
          _showResumeDialog();
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _showResumeDialog() {
    if (!mounted) return;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'Sessione sospesa',
            style: theme.textTheme.titleLarge,
          ),
          content: Text(
            'Vuoi riprendere la sessione di studio?',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                // User chose not to resume — clear session state
                ref.read(sessionProvider.notifier).clear();
                ref.read(sessionProvider.notifier).loadSessionHistory();
                setState(() {
                  _historyLoadAttempted = false;
                  _sessionSeconds = 0;
                  _sessionTime = '00:00';
                  _messages.clear();
                  _prevTutorMessagesCount = 0;
                  _prevActionsCount = 0;
                  _prevAchievementsCount = 0;
                });
              },
              child: Text(
                'No, termina',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                // Resume by starting a new session stream —
                // the backend auto-resumes suspended sessions.
                _startTimer();
                await ref
                    .read(sessionProvider.notifier)
                    .startSessionStream();
              },
              child: Text(
                'Riprendi',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool get _isSessionActive {
    final session = ref.read(sessionProvider).activeSession;
    return session != null && session.stato == 'attiva';
  }

  String get _currentNode {
    final session = ref.read(sessionProvider).activeSession;
    final nome = session?.nodoFocaleNome;
    if (nome != null && !nome.contains('_')) {
      return nome;
    }
    return _formatNodeId(nome ?? session?.nodoFocaleId) ?? 'Nessun nodo';
  }

  /// Makes a raw node ID more readable:
  /// "mat_MatematicaC3_Algebra1_numeri_naturali" -> "Numeri naturali"
  String? _formatNodeId(String? id) {
    if (id == null) return null;
    final parts = id.split('_');
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
    final name = parts.sublist(start).join(' ');
    return name.isNotEmpty ? name[0].toUpperCase() + name.substring(1) : id;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _sessionSeconds++;
          final minutes = _sessionSeconds ~/ 60;
          final seconds = _sessionSeconds % 60;
          _sessionTime =
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> _startSession() async {
    HapticFeedback.lightImpact();

    // Reset local state before starting
    setState(() {
      _showingHome = false;
      _historyLoadAttempted = false;
      _sessionSeconds = 0;
      _sessionTime = '00:00';
      _messages.clear();
      _prevTutorMessagesCount = 0;
      _prevActionsCount = 0;
      _prevAchievementsCount = 0;
    });

    // Start SSE streaming (returns immediately, events arrive async)
    await ref.read(sessionProvider.notifier).startSessionStream();

    // Start the timer — the session will be set active when sessione_creata
    // arrives via SSE. We start the timer now since the session is being created.
    _startTimer();

    final sessionState = ref.read(sessionProvider);
    if (sessionState.error != null) {
      _stopTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sessionState.error!),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _toggleSession() async {
    if (_isSessionActive) {
      HapticFeedback.lightImpact();
      _stopTimer();
      await ref.read(sessionProvider.notifier).suspend();
    } else {
      await _startSession();
    }
  }

  Future<void> _sendMessage([String? overrideText]) async {
    final text = overrideText ?? _messageController.text.trim();
    if (text.isEmpty || !_isSessionActive) return;

    final sessionState = ref.read(sessionProvider);
    if (sessionState.isStreaming) return;

    HapticFeedback.lightImpact();

    setState(() {
      _messages.add({
        'type': 'user',
        'sender': 'user',
        'content': text,
        'timestamp': DateTime.now(),
        'isStreaming': false,
      });
      if (overrideText == null) _messageController.clear();
    });

    _scrollToBottom();

    // Send via SSE streaming
    await ref.read(sessionProvider.notifier).sendTurnStream(text);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleToolsTray() {
    HapticFeedback.lightImpact();
    setState(() {
      _isToolsTrayVisible = !_isToolsTrayVisible;
    });
  }

  void _toggleTutorPanel() {
    HapticFeedback.lightImpact();
    setState(() {
      _isTutorPanelVisible = !_isTutorPanelVisible;
    });
  }

  void _handleToolAction(String tool) {
    HapticFeedback.lightImpact();
    setState(() {
      _isToolsTrayVisible = false;
    });

    switch (tool) {
      case 'calculator':
        _showToolMessage('Calcolatrice aperta');
        break;
      case 'formulas':
        _showToolMessage('Formulario aperto');
        break;
      case 'notes':
        _showToolMessage('Note aperte');
        break;
      case 'save':
        _showToolMessage('Sessione salvata');
        break;
      case 'visualizations':
        _showToolMessage('Visualizzazioni aperte');
        break;
      case 'voice':
        _showToolMessage('Input vocale attivato');
        break;
      case 'talk':
        _toggleTutorPanel();
        break;
      case 'end':
        _endSession();
        break;
    }
  }

  void _showToolMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _endSessionAndNavigateToRecap() async {
    final sessionId = ref.read(sessionProvider).activeSession?.id;
    if (sessionId == null) return;

    _stopTimer();
    await ref.read(sessionProvider.notifier).endSession();

    if (mounted) {
      context.go(AppPaths.recapSession(sessionId));
    }
  }

  void _endSession() {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Text('Termina sessione', style: theme.textTheme.titleLarge),
          content: Text(
            'Sei sicuro di voler terminare questa sessione di studio?',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Annulla',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _endSessionAndNavigateToRecap();
              },
              child: Text(
                'Termina',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Syncs finalized tutor messages, actions, and achievements from provider
  /// state into the local _messages list.
  void _syncTutorMessages(SessionScreenState sessionState) {
    // Sync finalized tutor messages
    final tutorMessages = sessionState.tutorMessages;
    if (tutorMessages.length > _prevTutorMessagesCount) {
      for (int i = _prevTutorMessagesCount; i < tutorMessages.length; i++) {
        _messages.add({
          'type': 'tutor',
          'sender': 'tutor',
          'content': tutorMessages[i],
          'timestamp': DateTime.now(),
          'isStreaming': false,
        });
      }
      _prevTutorMessagesCount = tutorMessages.length;
      _scrollToBottom();
    }

    // Sync action cards (appear inline after tutor message)
    final actions = sessionState.currentTurnActions;
    if (actions.length > _prevActionsCount) {
      for (int i = _prevActionsCount; i < actions.length; i++) {
        final action = actions[i];
        final itemType = switch (action.tipo) {
          'proponi_esercizio' => 'exercise',
          'mostra_formula' => 'formula',
          'suggerisci_backtrack' => 'backtrack',
          'chiudi_sessione' => 'chiudi',
          _ => null,
        };

        // Skip proponi_esercizio with nessunoDisponibile
        if (action.tipo == 'proponi_esercizio') {
          final ex = action.asProponiEsercizio;
          if (ex != null && ex.nessunoDisponibile) continue;
        }

        if (itemType != null) {
          _messages.add({
            'type': itemType,
            'data': action,
            'timestamp': DateTime.now(),
          });
        }
      }
      _prevActionsCount = actions.length;
      _scrollToBottom();
    }

    // Trigger achievement toasts
    final achievements = sessionState.currentTurnAchievements;
    if (achievements.length > _prevAchievementsCount) {
      for (int i = _prevAchievementsCount; i < achievements.length; i++) {
        // Schedule toast after build
        final achievement = achievements[i];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) showAchievementToast(context, achievement);
        });
      }
      _prevAchievementsCount = achievements.length;
    }

    // Trigger celebration overlay on exercise outcome
    final esito = sessionState.latestEsito;
    if (esito != null && esito != _lastTriggeredEsito) {
      _lastTriggeredEsito = esito;
      if (esito.corretto) _lastCelebrationTime = DateTime.now();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showCelebrationOverlay(context, esito);
          ref.read(sessionProvider.notifier).clearEsito();
        }
      });
    }

    // Trigger promotion celebration overlay
    final promotion = sessionState.latestPromotion;
    if (promotion != null && promotion != _lastTriggeredPromotion) {
      _lastTriggeredPromotion = promotion;
      _lastCelebrationTime = DateTime.now();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showPromotionCelebration(context, promotion);
          ref.read(sessionProvider.notifier).clearPromotion();
        }
      });
    }
  }

  /// Computes the mascotte visual state from the current session state.
  MascotteState _computeMascotteState(SessionScreenState sessionState) {
    final session = sessionState.activeSession;
    final isActive = session != null && session.stato == 'attiva';

    if (!isActive) return MascotteState.sleeping;

    // Recent celebration keeps mascotte in celebrating for 3 seconds
    if (_lastCelebrationTime != null &&
        DateTime.now().difference(_lastCelebrationTime!) <
            const Duration(seconds: 3)) {
      return MascotteState.celebrating;
    }

    if (sessionState.isStreaming) return MascotteState.thinking;

    return MascotteState.idle;
  }

  /// Builds a chat item widget based on its type.
  Widget _buildChatItem(Map<String, dynamic> item, ThemeData theme) {
    final type = item['type'] as String?;

    switch (type) {
      case 'user':
      case 'tutor':
        return TutorMessageWidget(message: item, theme: theme);

      case 'exercise':
        final action = item['data'] as AzioneEvent;
        final exercise = action.asProponiEsercizio;
        if (exercise == null) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: ExerciseCardWidget(
            exercise: exercise,
            theme: theme,
            onVerify: (risposta) {
              _sendMessage(risposta);
            },
            onDismiss: () {
              setState(() => _messages.remove(item));
            },
          ),
        );

      case 'formula':
        final action = item['data'] as AzioneEvent;
        final formula = action.asMostraFormula;
        if (formula == null) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: FormulaCardWidget(
            formula: formula,
            theme: theme,
            onDismiss: () {
              setState(() => _messages.remove(item));
            },
          ),
        );

      case 'backtrack':
        final action = item['data'] as AzioneEvent;
        final backtrack = action.asSuggerisciBacktrack;
        if (backtrack == null) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: BacktrackCardWidget(
            suggestion: backtrack,
            theme: theme,
            onAccept: () {
              _sendMessage('Ok, rivediamolo');
            },
            onDismiss: () {
              _sendMessage('Continua qui');
            },
          ),
        );

      case 'chiudi':
        final action = item['data'] as AzioneEvent;
        final chiudi = action.asChiudiSessione;
        if (chiudi == null) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: ChiudiSessioneCardWidget(
            data: chiudi,
            theme: theme,
            onEnd: _endSessionAndNavigateToRecap,
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionState = ref.watch(sessionProvider);
    final session = sessionState.activeSession;
    final isActive = session != null && session.stato == 'attiva';
    final isStreaming = sessionState.isStreaming;
    final currentTutorText = sessionState.currentTutorText;

    // Reset _showingHome when session is no longer active
    if (!isActive && _showingHome) {
      _showingHome = false;
    }

    // Reload session history when returning to home with no active session.
    // Guard: only attempt once per "home view" to prevent infinite loop
    // when the backend is unreachable (loadSessionHistory fails, sets
    // isLoadingHistory=false, condition met again → infinite rebuild).
    if (!isActive && !isStreaming && _messages.isEmpty &&
        sessionState.sessionHistory.isEmpty &&
        !sessionState.isLoadingHistory &&
        !_historyLoadAttempted) {
      _historyLoadAttempted = true;
      Future.microtask(() {
        ref.read(sessionProvider.notifier).loadSessionHistory();
      });
    }

    // Sync finalized tutor messages, actions, achievements into local list
    _syncTutorMessages(sessionState);

    // Show fatal error snackbar when reconnection fails
    final error = sessionState.error;
    if (error != null && error != _lastShownError) {
      _lastShownError = error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      });
    } else if (error == null) {
      _lastShownError = null;
    }

    // Auto-scroll when streaming text grows
    if (isStreaming && currentTutorText.isNotEmpty) {
      _scrollToBottom();
    }

    // Calculate total items: _messages + streaming bubble (if any)
    final showStreamingBubble = isStreaming && currentTutorText.isNotEmpty;
    final showTypingIndicator = isStreaming && currentTutorText.isEmpty;
    final extraItems =
        showStreamingBubble ? 1 : (showTypingIndicator ? 1 : 0);
    final totalItems = _messages.length + extraItems;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomStudioAppBar(
        sessionTime: _sessionTime,
        isSessionActive: isActive && !_showingHome,
        onBack: isActive && !_showingHome
            ? () {
                setState(() {
                  _showingHome = true;
                });
                ref.read(sessionProvider.notifier).loadSessionHistory();
              }
            : null,
        onPause: _toggleSession,
        onSettings: () {
          HapticFeedback.lightImpact();
          _showToolMessage('Impostazioni');
        },
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Session header
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'school',
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            isActive && !_showingHome
                                ? _currentNode
                                : isActive && _showingHome
                                    ? _currentNode
                                    : 'Pronto per studiare',
                            style: isActive
                                ? theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  )
                                : theme.textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_showingHome && isActive)
                          TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _showingHome = false;
                              });
                            },
                            child: Text(
                              'Riprendi',
                              style:
                                  theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        if (!isActive)
                          TextButton(
                            onPressed: sessionState.isLoading
                                ? null
                                : _startSession,
                            child: sessionState.isLoading
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        theme.colorScheme.primary,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Inizia',
                                    style:
                                        theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Reconnection banner
                if (sessionState.isReconnecting)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.15),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.tertiary,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Riconnessione in corso...',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Chat area
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: (_messages.isEmpty && !isActive && !isStreaming) || _showingHome
                        ? SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(height: 4.h),
                                CustomIconWidget(
                                  iconName: 'chat_bubble_outline',
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 48,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  _showingHome && isActive
                                      ? 'Hai una sessione attiva'
                                      : 'Inizia una sessione per chattare con il tutor',
                                  style:
                                      theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 4.h),
                                SessionHistoryWidget(
                                  sessions: sessionState.sessionHistory,
                                  isLoading: sessionState.isLoadingHistory,
                                  onSessionTap: (sessioneId) {
                                    context.go(
                                      AppPaths.recapSession(sessioneId),
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.only(bottom: 2.h),
                            itemCount: totalItems,
                            itemBuilder: (context, index) {
                              // Streaming bubble or typing indicator at the end
                              if (index == _messages.length) {
                                if (showStreamingBubble) {
                                  return _buildStreamingBubble(
                                    theme,
                                    currentTutorText,
                                  );
                                }
                                if (showTypingIndicator) {
                                  return _buildTypingIndicator(theme);
                                }
                              }
                              if (index < _messages.length) {
                                return _buildChatItem(
                                    _messages[index], theme);
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                  ),
                ),

                // Input bar (hidden when showing home view)
                if (!_showingHome)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color:
                            theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _messageFocusNode,
                          enabled: isActive && !isStreaming,
                          decoration: InputDecoration(
                            hintText: isStreaming
                                ? 'Il tutor sta rispondendo...'
                                : isActive
                                    ? 'Scrivi un messaggio...'
                                    : 'Inizia la sessione per chattare',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.5.h,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        decoration: BoxDecoration(
                          color: isActive &&
                                  !isStreaming &&
                                  _messageController.text.isNotEmpty
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: CustomIconWidget(
                            iconName: 'send',
                            color: isActive &&
                                    !isStreaming &&
                                    _messageController.text.isNotEmpty
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed:
                              isActive && !isStreaming ? _sendMessage : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Mascotte widget
            if (isActive && !_showingHome)
              Positioned(
                right: 4.w,
                bottom: 12.h,
                child: MascotteWidget(
                  theme: theme,
                  onTap: _toggleToolsTray,
                  mascotteState: _computeMascotteState(sessionState),
                ),
              ),

            // Tools tray overlay
            if (_isToolsTrayVisible)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isToolsTrayVisible = false;
                    });
                  },
                  child:
                      Container(color: Colors.black.withValues(alpha: 0.5)),
                ),
              ),

            if (_isToolsTrayVisible)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ToolsTrayWidget(
                  theme: theme,
                  onToolSelected: _handleToolAction,
                  onClose: () {
                    setState(() {
                      _isToolsTrayVisible = false;
                    });
                  },
                ),
              ),

            // Tutor panel overlay
            if (_isTutorPanelVisible)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isTutorPanelVisible = false;
                    });
                  },
                  child:
                      Container(color: Colors.black.withValues(alpha: 0.5)),
                ),
              ),

            if (_isTutorPanelVisible)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: TutorPanelWidget(
                  theme: theme,
                  onClose: () {
                    setState(() {
                      _isTutorPanelVisible = false;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the streaming tutor message bubble with amber pulsating cursor.
  Widget _buildStreamingBubble(ThemeData theme, String text) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school,
              size: 4.w,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 2.w),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 1.5.h,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: MarkdownText(
                      data: text,
                      textColor: theme.colorScheme.onSurface,
                    ),
                  ),
                  const _AmberCursor(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 1.5.h,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 4.w,
                  height: 4.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  'Il tutor sta scrivendo...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Amber pulsating cursor shown at the end of streaming text.
class _AmberCursor extends StatefulWidget {
  const _AmberCursor();

  @override
  State<_AmberCursor> createState() => _AmberCursorState();
}

class _AmberCursorState extends State<_AmberCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 2,
        height: 16,
        margin: const EdgeInsets.only(left: 2, bottom: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
