import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/sizer_extensions.dart';
import '../../providers/ripasso_provider.dart';
import '../../providers/session_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/chat_view_widget.dart';
import './widgets/home_view_widget.dart';
import './widgets/mascotte_widget.dart';
import './widgets/session_header_widget.dart';
import './widgets/session_input_bar_widget.dart';
import './widgets/session_sync_helper.dart';
import './widgets/studio_dialogs.dart';
import './widgets/tools_tray_widget.dart';
import './widgets/tutor_panel_widget.dart';

class StudioScreen extends ConsumerStatefulWidget {
  const StudioScreen({super.key});

  /// Notifier incrementato quando il tab Studio viene ri-tappato.
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

  // Guard: evita chiamate infinite a loadSessionHistory da build().
  bool _historyLoadAttempted = false;

  // Quando true, mostra la home view anche con sessione attiva.
  bool _showingHome = false;

  final List<Map<String, dynamic>> _messages = [];
  final SessionSyncState _sync = SessionSyncState();

  Timer? _timer;
  int _sessionSeconds = 0;
  String _sessionTime = '00:00';

  bool _suspendedInBackground = false;
  String? _lastShownError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    StudioScreen.tabReTapNotifier.addListener(_onTabReTap);
    Future.microtask(() {
      ref.read(sessionProvider.notifier).loadSessionHistory();
      ref.read(ripassoProvider.notifier).carica();
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
          _historyLoadAttempted = false;
          _sessionSeconds = 0;
          _sessionTime = '00:00';
          _messages.clear();
          _sync.tutorCount = 0;
          _sync.actionsCount = 0;
          _sync.achievementsCount = 0;
        });
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
      }
    });
  }

  void _stopTimer() => _timer?.cancel();

  Future<void> _startSession() async {
    HapticFeedback.lightImpact();
    setState(() {
      _showingHome = false;
      _historyLoadAttempted = false;
      _sessionSeconds = 0;
      _sessionTime = '00:00';
      _messages.clear();
      _sync.tutorCount = 0;
      _sync.actionsCount = 0;
      _sync.achievementsCount = 0;
    });
    await ref.read(sessionProvider.notifier).startSessionStream();
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
      await _startSession();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionState = ref.watch(sessionProvider);
    final ripassoTotale = ref.watch(ripassoProvider).totale;
    final session = sessionState.activeSession;
    final isActive = session != null && session.stato == 'attiva';
    final isStreaming = sessionState.isStreaming;

    if (!isActive && _showingHome) _showingHome = false;

    if (!isActive && !isStreaming && _messages.isEmpty &&
        sessionState.sessionHistory.isEmpty &&
        !sessionState.isLoadingHistory && !_historyLoadAttempted) {
      _historyLoadAttempted = true;
      Future.microtask(() => ref.read(sessionProvider.notifier).loadSessionHistory());
    }

    syncTutorMessages(
      sessionState: sessionState,
      messages: _messages,
      syncState: _sync,
      mounted: mounted,
      context: context,
      onScrollToBottom: _scrollToBottom,
      onClearEsito: () => ref.read(sessionProvider.notifier).clearEsito(),
      onClearPromotion: () => ref.read(sessionProvider.notifier).clearPromotion(),
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

    final showChatView = _messages.isNotEmpty || isActive || isStreaming;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomStudioAppBar(
        sessionTime: _sessionTime,
        isSessionActive: isActive && !_showingHome,
        onBack: isActive && !_showingHome
            ? () {
                setState(() => _showingHome = true);
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
            Column(
              children: [
                SessionHeaderWidget(
                  isActive: isActive,
                  showingHome: _showingHome,
                  currentNode: _currentNode,
                  isLoading: sessionState.isLoading,
                  onStart: _startSession,
                  onResume: () => setState(() => _showingHome = false),
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
                    child: !showChatView || _showingHome
                        ? HomeViewWidget(
                            showingHome: _showingHome,
                            isActive: isActive,
                            sessionHistory: sessionState.sessionHistory,
                            isLoadingHistory: sessionState.isLoadingHistory,
                            ripassoTotale: ripassoTotale,
                          )
                        : ChatViewWidget(
                            messages: _messages,
                            isStreaming: isStreaming,
                            currentTutorText: sessionState.currentTutorText,
                            scrollController: _scrollController,
                            onSendMessage: _sendMessage,
                            onRemoveItem: (item) => setState(() => _messages.remove(item)),
                            onEndSession: _endSessionAndNavigateToRecap,
                          ),
                  ),
                ),
                if (!_showingHome)
                  SessionInputBarWidget(
                    isActive: isActive,
                    isStreaming: isStreaming,
                    messageController: _messageController,
                    messageFocusNode: _messageFocusNode,
                    onSend: _sendMessage,
                  ),
              ],
            ),
            if (isActive && !_showingHome)
              Positioned(
                right: 4.w,
                bottom: 12.h,
                child: MascotteWidget(
                  theme: theme,
                  onTap: _toggleToolsTray,
                  mascotteState: computeMascotteState(
                    sessionState,
                    _sync.lastCelebrationTime,
                  ),
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
          ],
        ),
      ),
    );
  }
}
