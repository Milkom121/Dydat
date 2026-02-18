import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/sizer_extensions.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/backtrack_card_widget.dart';
import './widgets/exercise_card_widget.dart';
import './widgets/formula_card_widget.dart';
import './widgets/mascotte_widget.dart';
import './widgets/tools_tray_widget.dart';
import './widgets/tutor_message_widget.dart';
import './widgets/tutor_panel_widget.dart';

class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  bool _isSessionActive = false;
  bool _isToolsTrayVisible = false;
  bool _isTutorPanelVisible = false;
  bool _isTyping = false;

  String _sessionTime = "00:00";
  final String _currentNode = "Equazioni di secondo grado";

  int _sessionMinutes = 0;

  // Mock conversation data
  final List<Map<String, dynamic>> _messages = [
    {
      "id": 1,
      "sender": "tutor",
      "content":
          "Ciao! Sono qui per aiutarti con le equazioni di secondo grado. Iniziamo con un concetto fondamentale: la formula risolutiva.",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 5)),
      "isStreaming": false,
    },
    {
      "id": 2,
      "sender": "user",
      "content": "Sì, vorrei capire meglio come si applica la formula.",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 4)),
      "isStreaming": false,
    },
    {
      "id": 3,
      "sender": "tutor",
      "content":
          "Perfetto! La formula risolutiva per un'equazione ax² + bx + c = 0 è x = (-b ± √(b² - 4ac)) / 2a. Proviamo con un esercizio pratico.",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 3)),
      "isStreaming": false,
    },
  ];

  // Mock exercise data
  Map<String, dynamic>? _currentExercise = {
    "id": 1,
    "title": "Risolvi l'equazione",
    "problem": "x² - 5x + 6 = 0",
    "hint":
        "Identifica i coefficienti a, b e c, poi applica la formula risolutiva.",
    "difficulty": "medio",
  };

  // Mock formula data
  Map<String, dynamic>? _currentFormula = {
    "id": 1,
    "name": "Formula risolutiva",
    "formula": "x = (-b ± √(b² - 4ac)) / 2a",
    "description":
        "Utilizzata per risolvere equazioni di secondo grado nella forma ax² + bx + c = 0",
  };

  // Mock backtrack suggestion
  Map<String, dynamic>? _backtrackSuggestion;

  @override
  void initState() {
    super.initState();
    _startSessionTimer();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _startSessionTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isSessionActive) {
        setState(() {
          _sessionMinutes++;
          final minutes = _sessionMinutes ~/ 60;
          final seconds = _sessionMinutes % 60;
          _sessionTime =
              "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
        });
        _startSessionTimer();
      }
    });
  }

  void _toggleSession() {
    HapticFeedback.lightImpact();
    setState(() {
      _isSessionActive = !_isSessionActive;
    });

    if (_isSessionActive) {
      _startSessionTimer();
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    HapticFeedback.lightImpact();

    final userMessage = {
      "id": _messages.length + 1,
      "sender": "user",
      "content": _messageController.text.trim(),
      "timestamp": DateTime.now(),
      "isStreaming": false,
    };

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate tutor response with streaming
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        final tutorMessage = {
          "id": _messages.length + 1,
          "sender": "tutor",
          "content":
              "Ottima domanda! Lascia che ti spieghi passo dopo passo. Prima di tutto, dobbiamo identificare i coefficienti dell'equazione.",
          "timestamp": DateTime.now(),
          "isStreaming": true,
        };

        setState(() {
          _messages.add(tutorMessage);
          _isTyping = false;
        });

        _scrollToBottom();

        // Stop streaming after animation
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _messages.last["isStreaming"] = false;
            });
          }
        });
      }
    });
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

    // Handle different tool actions
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
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Termina sessione', style: theme.textTheme.titleLarge),
          content: Text(
            'Sei sicuro di voler terminare questa sessione di studio?',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annulla',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/percorso');
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

  void _dismissExercise() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentExercise = null;
    });
  }

  void _dismissFormula() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentFormula = null;
    });
  }

  void _dismissBacktrack() {
    HapticFeedback.lightImpact();
    setState(() {
      _backtrackSuggestion = null;
    });
  }

  void _handleBacktrack() {
    HapticFeedback.lightImpact();
    _showToolMessage('Tornando al nodo precedente...');
    setState(() {
      _backtrackSuggestion = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomStudioAppBar(
        sessionTime: _sessionTime,
        isSessionActive: _isSessionActive,
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
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
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
                            _currentNode,
                            style: theme.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!_isSessionActive)
                          TextButton(
                            onPressed: _toggleSession,
                            child: Text(
                              'Inizia',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Canvas area with messages
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(bottom: 2.h),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isTyping && index == _messages.length) {
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                theme.colorScheme.primary,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        'Il tutor sta scrivendo...',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final message = _messages[index];
                        return TutorMessageWidget(
                          message: message,
                          theme: theme,
                        );
                      },
                    ),
                  ),
                ),

                // Exercise card
                if (_currentExercise != null)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    child: ExerciseCardWidget(
                      exercise: _currentExercise!,
                      theme: theme,
                      onDismiss: _dismissExercise,
                    ),
                  ),

                // Formula card
                if (_currentFormula != null)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    child: FormulaCardWidget(
                      formula: _currentFormula!,
                      theme: theme,
                      onDismiss: _dismissFormula,
                    ),
                  ),

                // Backtrack card
                if (_backtrackSuggestion != null)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    child: BacktrackCardWidget(
                      suggestion: _backtrackSuggestion!,
                      theme: theme,
                      onDismiss: _dismissBacktrack,
                      onAccept: _handleBacktrack,
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
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _messageFocusNode,
                          enabled: _isSessionActive,
                          decoration: InputDecoration(
                            hintText: _isSessionActive
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
                          color:
                              _isSessionActive &&
                                  _messageController.text.isNotEmpty
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: CustomIconWidget(
                            iconName: 'send',
                            color:
                                _isSessionActive &&
                                    _messageController.text.isNotEmpty
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: _isSessionActive ? _sendMessage : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Mascotte widget
            if (_isSessionActive)
              Positioned(
                right: 4.w,
                bottom: 12.h,
                child: MascotteWidget(theme: theme, onTap: _toggleToolsTray),
              ),

            // Tools tray bottom sheet
            if (_isToolsTrayVisible)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isToolsTrayVisible = false;
                    });
                  },
                  child: Container(color: Colors.black.withValues(alpha: 0.5)),
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

            // Tutor panel
            if (_isTutorPanelVisible)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isTutorPanelVisible = false;
                    });
                  },
                  child: Container(color: Colors.black.withValues(alpha: 0.5)),
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
}
