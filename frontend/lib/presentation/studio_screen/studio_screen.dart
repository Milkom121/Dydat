import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/sizer_extensions.dart';
import '../../providers/session_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/mascotte_widget.dart';
import './widgets/tools_tray_widget.dart';
import './widgets/tutor_message_widget.dart';
import './widgets/tutor_panel_widget.dart';

class StudioScreen extends ConsumerStatefulWidget {
  const StudioScreen({super.key});

  @override
  ConsumerState<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends ConsumerState<StudioScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  bool _isToolsTrayVisible = false;
  bool _isTutorPanelVisible = false;
  bool _isTyping = false;

  // Local chat messages (user + tutor placeholder).
  final List<Map<String, dynamic>> _messages = [];

  // Timer state
  Timer? _timer;
  int _sessionSeconds = 0;
  String _sessionTime = '00:00';

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  bool get _isSessionActive {
    final session = ref.read(sessionProvider).activeSession;
    return session != null && session.stato == 'attiva';
  }

  String get _currentNode {
    final session = ref.read(sessionProvider).activeSession;
    // Prefer nodoFocaleNome, but if it looks like a raw ID, format it.
    final nome = session?.nodoFocaleNome;
    if (nome != null && !nome.contains('_')) {
      return nome;
    }
    // Format whichever raw ID we have (nome that looks like ID, or actual ID).
    return _formatNodeId(nome ?? session?.nodoFocaleId) ?? 'Nessun nodo';
  }

  /// Makes a raw node ID more readable:
  /// "mat_MatematicaC3_Algebra1_numeri_naturali" → "Numeri naturali"
  String? _formatNodeId(String? id) {
    if (id == null) return null;
    // Take the part after the last underscore-group that looks like a topic
    // e.g. "mat_MatematicaC3_Algebra1_numeri_naturali"
    // Split by underscore, drop prefix tokens (mat, MatematicaC3, Algebra1), join rest
    final parts = id.split('_');
    // Find first part that is all lowercase (the actual name starts there)
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
    return name.isNotEmpty
        ? name[0].toUpperCase() + name.substring(1)
        : id;
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
    await ref.read(sessionProvider.notifier).startSession();

    final sessionState = ref.read(sessionProvider);
    if (sessionState.activeSession != null &&
        sessionState.activeSession!.stato == 'attiva') {
      setState(() {
        _sessionSeconds = 0;
        _sessionTime = '00:00';
        _messages.clear();
      });
      _startTimer();
    } else if (sessionState.error != null) {
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
      // Suspend
      HapticFeedback.lightImpact();
      _stopTimer();
      await ref.read(sessionProvider.notifier).suspend();
    } else {
      await _startSession();
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || !_isSessionActive) return;

    HapticFeedback.lightImpact();

    final text = _messageController.text.trim();
    setState(() {
      _messages.add({
        'id': _messages.length + 1,
        'sender': 'user',
        'content': text,
        'timestamp': DateTime.now(),
        'isStreaming': false,
      });
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // Send via REST
    await ref.read(sessionProvider.notifier).sendTurn(text);

    if (mounted) {
      // Add placeholder tutor response (SSE not implemented yet)
      setState(() {
        _messages.add({
          'id': _messages.length + 1,
          'sender': 'tutor',
          'content':
              'Messaggio ricevuto. La risposta in tempo reale arrivera con SSE (prossima versione).',
          'timestamp': DateTime.now(),
          'isStreaming': false,
        });
        _isTyping = false;
      });
      _scrollToBottom();
    }
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
                _stopTimer();
                await ref.read(sessionProvider.notifier).endSession();
                if (mounted) {
                  setState(() {
                    _sessionSeconds = 0;
                    _sessionTime = '00:00';
                  });
                }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionState = ref.watch(sessionProvider);
    final session = sessionState.activeSession;
    final isActive = session != null && session.stato == 'attiva';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomStudioAppBar(
        sessionTime: _sessionTime,
        isSessionActive: isActive,
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
                            isActive
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

                // Chat area
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: _messages.isEmpty && !isActive
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'chat_bubble_outline',
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 48,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Inizia una sessione per chattare con il tutor',
                                  style:
                                      theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.only(bottom: 2.h),
                            itemCount:
                                _messages.length + (_isTyping ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (_isTyping &&
                                  index == _messages.length) {
                                return _buildTypingIndicator(theme);
                              }
                              return TutorMessageWidget(
                                message: _messages[index],
                                theme: theme,
                              );
                            },
                          ),
                  ),
                ),

                // Input bar
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
                          enabled: isActive,
                          decoration: InputDecoration(
                            hintText: isActive
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
                                  _messageController.text.isNotEmpty
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: CustomIconWidget(
                            iconName: 'send',
                            color: isActive &&
                                    _messageController.text.isNotEmpty
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: isActive ? _sendMessage : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Mascotte widget
            if (isActive)
              Positioned(
                right: 4.w,
                bottom: 12.h,
                child:
                    MascotteWidget(theme: theme, onTap: _toggleToolsTray),
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
