import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/sizer_extensions.dart';
import '../../providers/beat_provider.dart';
import '../../providers/session_provider.dart';
import '../../models/sse_events.dart';
import '../../routes/app_router.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/chat_view_widget.dart';
import './widgets/beat_overlay_widget.dart';
import './widgets/fullscreen_action_overlay.dart';
import './widgets/mascotte_widget.dart';
import './widgets/session_header_widget.dart';
import './widgets/session_input_bar_widget.dart';
import './widgets/session_sync_helper.dart';
import './widgets/session_goal_picker.dart';
import './widgets/studio_dialogs.dart';
import './widgets/tools_tray_widget.dart';
import './widgets/tutor_panel_widget.dart';

/// Schermata Studio — route fullscreen per la sessione di studio attiva.
/// Si apre come route modale sopra la shell (niente bottom bar).
/// Riceve [tipo] dalla route (query param), default 'media'.
/// Riceve [durataPrevistaMin] dalla route (query param), opzionale.
class StudioScreen extends ConsumerStatefulWidget {
  /// Tipo di sessione: 'media' o 'ripasso'.
  final String tipo;

  /// Durata obiettivo in minuti (da SessionGoalPicker). Null = nessun obiettivo.
  final int? durataPrevistaMin;

  const StudioScreen({super.key, this.tipo = 'media', this.durataPrevistaMin});

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

  // Guard: evita avvio sessione multiplo.
  bool _sessionStartAttempted = false;

  final List<Map<String, dynamic>> _messages = [];
  final SessionSyncState _sync = SessionSyncState();

  Timer? _timer;
  int _sessionSeconds = 0;
  String _sessionTime = '00:00';

  bool _suspendedInBackground = false;
  String? _lastShownError;

  // Suggerimento pausa: mostrato una sola volta quando si supera l'obiettivo
  bool _goalExceededNotified = false;

  // Durata obiettivo scelta dallo studente (null = nessun obiettivo)
  int? _durataPrevistaMin;

  // Coda azioni fullscreen: esercizi, formule, backtrack escono dal feed
  final List<({String type, AzioneEvent action})> _fullscreenQueue = [];
  ({String type, AzioneEvent action})? _currentFullscreen;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Avvia sessione all'apertura dello schermo (differito per Riverpod safety)
    Future.microtask(_avviaSessioneAllApertura);
  }

  /// Controlla se c'è una sessione attiva, altrimenti avvia nuova.
  /// Per sessioni nuove di tipo 'media', mostra prima il GoalPicker.
  Future<void> _avviaSessioneAllApertura() async {
    if (!mounted || _sessionStartAttempted) return;
    _sessionStartAttempted = true;

    // Carica la history per vedere se c'è una sessione attiva
    await ref.read(sessionProvider.notifier).loadSessionHistory();
    if (!mounted) return;

    final session = ref.read(sessionProvider).activeSession;
    final isAlreadyActive = session != null && session.stato == 'attiva';

    if (!isAlreadyActive) {
      // Solo per sessioni normali (non ripasso): mostra il GoalPicker
      if (widget.tipo == 'media') {
        final goal = await showSessionGoalPicker(context);
        if (!mounted) return;
        _durataPrevistaMin = goal?.durataMsMin;
      }
      await _startSession(tipo: widget.tipo, durataPrevistaMin: _durataPrevistaMin);
    } else {
      // Sessione già attiva: ricarica history per mostrare messaggi
      await ref.read(sessionProvider.notifier).loadSessionHistory();
      _startTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
        if (_isSessionActive && !_suspendedInBackground) {
          _suspendedInBackground = true;
          _stopTimer();
          ref.read(sessionProvider.notifier).suspend();
        }
      case AppLifecycleState.resumed:
        if (_suspendedInBackground) {
          _suspendedInBackground = false;
          if (mounted) _showResumeDialog();
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _showResumeDialog() {
    showResumeSessionDialog(
      context: context,
      onResume: () async {
        _startTimer();
        await ref.read(sessionProvider.notifier).startSessionStream();
      },
      onTerminate: () {
        ref.read(sessionProvider.notifier).clear();
        ref.read(sessionProvider.notifier).loadSessionHistory();
        setState(() {
          _sessionStartAttempted = false;
          _sessionSeconds = 0;
          _sessionTime = '00:00';
          _messages.clear();
          _sync.tutorCount = 0;
          _sync.actionsCount = 0;
          _sync.achievementsCount = 0;
          _fullscreenQueue.clear();
          _currentFullscreen = null;
        });
        // Torna alla home dopo terminazione
        if (mounted) context.go(AppPaths.home);
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
    if (nome != null && !nome.contains('_')) return nome;
    return _formatNodeId(nome ?? session?.nodoFocaleId) ?? 'Nessun nodo';
  }

  /// Rende leggibile un node ID: "mat_C3_Algebra1_numeri_naturali" -> "Numeri naturali".
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
          final m = _sessionSeconds ~/ 60;
          final s = _sessionSeconds % 60;
          _sessionTime =
              '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
        });
        // Notifica pausa una sola volta quando si supera l'obiettivo.
        _checkGoalExceeded();
      }
    });
  }

  /// Mostra un suggerimento leggero se lo studente supera il tempo obiettivo.
  void _checkGoalExceeded() {
    if (_goalExceededNotified) return;
    final durata = _durataPrevistaMin;
    if (durata == null) return;
    if (_sessionSeconds >= durata * 60) {
      _goalExceededNotified = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hai raggiunto l\'obiettivo di $durata minuti — ottimo lavoro! Puoi continuare o fare una pausa.',
          ),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _stopTimer() => _timer?.cancel();

  Future<void> _startSession({String tipo = 'media', int? durataPrevistaMin}) async {
    HapticFeedback.lightImpact();
    setState(() {
      _sessionSeconds = 0;
      _sessionTime = '00:00';
      _messages.clear();
      _sync.tutorCount = 0;
      _sync.actionsCount = 0;
      _sync.achievementsCount = 0;
      _fullscreenQueue.clear();
      _currentFullscreen = null;
      _goalExceededNotified = false;
    });
    await ref.read(sessionProvider.notifier).startSessionStream(
      tipo: tipo,
      durataPrevistaMin: durataPrevistaMin ?? _durataPrevistaMin,
    );
    _startTimer();
    final err = ref.read(sessionProvider).error;
    if (err != null) {
      _stopTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _toggleSession() async {
    if (_isSessionActive) {
      HapticFeedback.lightImpact();
      _stopTimer();
      await ref.read(sessionProvider.notifier).suspend();
    } else {
      await _startSession(tipo: widget.tipo);
    }
  }

  Future<void> _sendMessage([String? overrideText]) async {
    final text = overrideText ?? _messageController.text.trim();
    if (text.isEmpty || !_isSessionActive) return;
    if (ref.read(sessionProvider).isStreaming) return;
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
    await ref.read(sessionProvider.notifier).sendTurnStream(text);
  }

  /// Aggiunge un'azione alla coda fullscreen. Se nessuna è attiva, la mostra subito.
  void _enqueueFullscreenAction(String actionType, AzioneEvent action) {
    final entry = (type: actionType, action: action);
    if (_currentFullscreen == null) {
      setState(() => _currentFullscreen = entry);
    } else {
      _fullscreenQueue.add(entry);
    }
    // Segnala al beat provider che c'e un'azione fullscreen attiva
    ref.read(beatProvider.notifier).setFullscreenActive(true);
  }

  /// Chiude l'azione fullscreen corrente, aggiunge record compatto al feed,
  /// e mostra la prossima dalla coda se presente.
  void _handleFullscreenDismiss(String resultLabel) {
    final current = _currentFullscreen;
    if (current != null) {
      // Genera etichetta per il record compatto
      final label = _compactLabel(current.type, current.action);
      setState(() {
        _messages.add({
          'type': '${current.type}_record',
          'label': label,
          'result': resultLabel,
          'timestamp': DateTime.now(),
        });
        // Mostra prossima azione dalla coda o chiudi
        if (_fullscreenQueue.isNotEmpty) {
          _currentFullscreen = _fullscreenQueue.removeAt(0);
        } else {
          _currentFullscreen = null;
          // Nessuna azione fullscreen rimasta
          ref.read(beatProvider.notifier).setFullscreenActive(false);
        }
      });
      _scrollToBottom();
    }
  }

  /// Invocato quando lo studente verifica un esercizio dal fullscreen.
  void _handleFullscreenExerciseVerify(String risposta) {
    // Invia la risposta come messaggio al tutor
    _sendMessage(risposta);
  }

  /// Genera l'etichetta per il record compatto in base al tipo di azione.
  String _compactLabel(String type, AzioneEvent action) {
    return switch (type) {
      'exercise' => 'Esercizio: ${_truncate(action.asProponiEsercizio?.testo ?? 'Proposto dal tutor', 40)}',
      'formula' => 'Formula: ${action.asMostraFormula?.etichetta ?? 'Mostrata dal tutor'}',
      'backtrack' => 'Ripasso: ${_truncate(action.asSuggerisciBacktrack?.motivo ?? '', 40)}',
      _ => '',
    };
  }

  String _truncate(String s, int maxLen) =>
      s.length <= maxLen ? s : '${s.substring(0, maxLen)}…';

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
    setState(() => _isToolsTrayVisible = !_isToolsTrayVisible);
  }

  void _toggleTutorPanel() {
    HapticFeedback.lightImpact();
    setState(() => _isTutorPanelVisible = !_isTutorPanelVisible);
  }

  void _handleToolAction(String tool) {
    HapticFeedback.lightImpact();
    setState(() => _isToolsTrayVisible = false);
    if (tool == 'talk') { _toggleTutorPanel(); return; }
    if (tool == 'end') { _showEndSessionDialog(); return; }
    const labels = {
      'calculator': 'Calcolatrice aperta',
      'formulas': 'Formulario aperto',
      'notes': 'Note aperte',
      'save': 'Sessione salvata',
      'visualizations': 'Visualizzazioni aperte',
      'voice': 'Input vocale attivato',
    };
    _showToolMessage(labels[tool] ?? tool);
  }

  void _showToolMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _endSessionAndNavigateToRecap() async {
    final sessionId = ref.read(sessionProvider).activeSession?.id;
    if (sessionId == null) return;
    _stopTimer();
    await ref.read(sessionProvider.notifier).endSession();
    if (mounted) context.go(AppPaths.recapSession(sessionId));
  }

  void _showEndSessionDialog() {
    showEndSessionDialog(context: context, onEnd: _endSessionAndNavigateToRecap);
  }

  /// Gestisce il back button: se sessione attiva chiede conferma, altrimenti torna alla home.
  Future<bool> _handleBackPress() async {
    if (_isSessionActive) {
      // Sospende la sessione e torna alla home
      _stopTimer();
      await ref.read(sessionProvider.notifier).suspend();
      if (mounted) context.go(AppPaths.home);
      return false; // Gestito manualmente
    }
    context.go(AppPaths.home);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionState = ref.watch(sessionProvider);
    final session = sessionState.activeSession;
    final isActive = session != null && session.stato == 'attiva';
    final isStreaming = sessionState.isStreaming;
    final currentBeat = ref.watch(beatProvider).beat;

    syncTutorMessages(
      sessionState: sessionState,
      messages: _messages,
      syncState: _sync,
      mounted: mounted,
      context: context,
      onScrollToBottom: _scrollToBottom,
      onClearEsito: () => ref.read(sessionProvider.notifier).clearEsito(),
      onClearPromotion: () => ref.read(sessionProvider.notifier).clearPromotion(),
      onShowFullscreen: _enqueueFullscreenAction,
    );

    final error = sessionState.error;
    if (error != null && error != _lastShownError) {
      _lastShownError = error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ));
        }
      });
    } else if (error == null) {
      _lastShownError = null;
    }

    if (isStreaming && sessionState.currentTutorText.isNotEmpty) _scrollToBottom();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomStudioAppBar(
          sessionTime: _sessionTime,
          isSessionActive: isActive,
          onBack: () => _handleBackPress(),
          onPause: _toggleSession,
          onSettings: () {
            HapticFeedback.lightImpact();
            _showToolMessage('Impostazioni');
          },
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // Overlay atmosferico beat emotivo (sotto tutto il contenuto)
              if (isActive)
                Positioned.fill(
                  child: BeatOverlayWidget(beat: currentBeat),
                ),
              Column(
                children: [
                  SessionHeaderWidget(
                    isActive: isActive,
                    showingHome: false,
                    currentNode: _currentNode,
                    isLoading: sessionState.isLoading,
                    onStart: _startSession,
                    onResume: null,
                  ),
                  if (sessionState.isReconnecting)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      color: theme.colorScheme.tertiary.withValues(alpha: 0.15),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 14, height: 14,
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
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: ChatViewWidget(
                        messages: _messages,
                        isStreaming: isStreaming,
                        currentTutorText: sessionState.currentTutorText,
                        scrollController: _scrollController,
                        onEndSession: _endSessionAndNavigateToRecap,
                      ),
                    ),
                  ),
                  SessionInputBarWidget(
                    isActive: isActive,
                    isStreaming: isStreaming,
                    messageController: _messageController,
                    messageFocusNode: _messageFocusNode,
                    onSend: _sendMessage,
                  ),
                ],
              ),
              if (isActive)
                Positioned(
                  right: 4.w,
                  bottom: 12.h,
                  child: MascotteWidget(
                    theme: theme,
                    onTap: _toggleToolsTray,
                    mascotteState: mascotteStateFromBeat(currentBeat),
                  ),
                ),
              if (_isToolsTrayVisible) ...[
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _isToolsTrayVisible = false),
                    child: Container(color: Colors.black.withValues(alpha: 0.5)),
                  ),
                ),
                Positioned(
                  left: 0, right: 0, bottom: 0,
                  child: ToolsTrayWidget(
                    theme: theme,
                    onToolSelected: _handleToolAction,
                    onClose: () => setState(() => _isToolsTrayVisible = false),
                  ),
                ),
              ],
              if (_isTutorPanelVisible) ...[
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _isTutorPanelVisible = false),
                    child: Container(color: Colors.black.withValues(alpha: 0.5)),
                  ),
                ),
                Positioned(
                  right: 0, top: 0, bottom: 0,
                  child: TutorPanelWidget(
                    theme: theme,
                    onClose: () => setState(() => _isTutorPanelVisible = false),
                  ),
                ),
              ],
              // Overlay fullscreen per azioni (esercizi, formule, backtrack)
              if (_currentFullscreen != null)
                Positioned.fill(
                  child: FullscreenActionOverlay(
                    key: ValueKey(_currentFullscreen.hashCode),
                    actionType: _currentFullscreen!.type,
                    action: _currentFullscreen!.action,
                    onExerciseVerify: _handleFullscreenExerciseVerify,
                    onDismiss: _handleFullscreenDismiss,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
