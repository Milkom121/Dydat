import 'package:flutter/material.dart';
import '../../core/sizer_extensions.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/mascotte_widget.dart';
import './widgets/message_bubble_widget.dart';
import './widgets/progress_indicator_widget.dart';

/// Onboarding screen that introduces new users to AI-powered tutoring
/// through conversational interaction with SSE streaming.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  // Onboarding progress (0.0 to 1.0)
  double _progress = 0.0;

  // Conversation messages
  final List<Map<String, dynamic>> _messages = [];

  // Loading state for AI response
  bool _isAiTyping = false;

  // Network state
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _initializeOnboarding();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  /// Initialize onboarding with welcome message
  Future<void> _initializeOnboarding() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _addMessage(
      text:
          "Ciao! Sono il tuo tutor AI personale. Sono qui per aiutarti a imparare matematica, fisica e chimica in modo divertente e interattivo. Come ti chiami?",
      isUser: false,
    );
    _updateProgress(0.2);
  }

  /// Add a message to the conversation
  void _addMessage({required String text, required bool isUser}) {
    setState(() {
      _messages.add({
        'text': text,
        'isUser': isUser,
        'timestamp': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  /// Scroll to bottom of message list
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

  /// Update onboarding progress
  void _updateProgress(double newProgress) {
    setState(() {
      _progress = newProgress.clamp(0.0, 1.0);
    });
  }

  /// Handle sending a message
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Add user message
    _addMessage(text: message, isUser: true);
    _messageController.clear();

    // Show AI typing indicator
    setState(() {
      _isAiTyping = true;
    });

    // Simulate AI response with SSE streaming placeholder
    await _simulateAiResponse(message);

    setState(() {
      _isAiTyping = false;
    });
  }

  /// Simulate AI response (placeholder for SSE streaming)
  Future<void> _simulateAiResponse(String userMessage) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    // Progress through onboarding stages
    if (_progress < 0.3) {
      _addMessage(
        text:
            "Piacere di conoscerti! Ora dimmi, quali materie vorresti studiare? Matematica, fisica, chimica o tutte e tre?",
        isUser: false,
      );
      _updateProgress(0.4);
    } else if (_progress < 0.5) {
      _addMessage(
        text:
            "Ottima scelta! Qual è il tuo livello attuale? Scuola media, superiore o università?",
        isUser: false,
      );
      _updateProgress(0.6);
    } else if (_progress < 0.7) {
      _addMessage(
        text:
            "Perfetto! Quali sono i tuoi obiettivi di apprendimento? Vuoi migliorare i voti, prepararti per un esame o semplicemente imparare per curiosità?",
        isUser: false,
      );
      _updateProgress(0.8);
    } else {
      _addMessage(
        text:
            "Fantastico! Ora sei pronto per iniziare il tuo percorso di apprendimento personalizzato. Creiamo il tuo account per salvare i tuoi progressi!",
        isUser: false,
      );
      _updateProgress(1.0);

      // Navigate to registration after completion
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed('/registration-screen');
      }
    }
  }

  /// Handle retry on network error
  void _retryConnection() {
    setState(() {
      _isOffline = false;
    });
    _initializeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            ProgressIndicatorWidget(progress: _progress),

            // Offline banner
            if (_isOffline)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
                color: theme.colorScheme.error,
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'wifi_off',
                      color: theme.colorScheme.onError,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Connessione assente. Riprova.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onError,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _retryConnection,
                      child: Text(
                        'Riprova',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onError,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Main content
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  children: [
                    SizedBox(height: 2.h),

                    // Mascotte
                    MascotteWidget(),

                    SizedBox(height: 3.h),

                    // Messages area
                    Expanded(
                      child: _messages.isEmpty
                          ? Center(
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.only(bottom: 2.h),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final message = _messages[index];
                                return MessageBubbleWidget(
                                  text: message['text'] as String,
                                  isUser: message['isUser'] as bool,
                                  timestamp: message['timestamp'] as DateTime,
                                );
                              },
                            ),
                    ),

                    // AI typing indicator
                    if (_isAiTyping)
                      Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
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
                                border: Border.all(
                                  color: theme.colorScheme.outline,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildTypingDot(theme, 0),
                                  SizedBox(width: 1.w),
                                  _buildTypingDot(theme, 1),
                                  SizedBox(width: 1.w),
                                  _buildTypingDot(theme, 2),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Input area
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        border: Border(
                          top: BorderSide(
                            color: theme.colorScheme.outline,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              focusNode: _messageFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Scrivi un messaggio...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 1.5.h,
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                              ),
                              style: theme.textTheme.bodyLarge,
                              maxLines: null,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Material(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: _sendMessage,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: EdgeInsets.all(1.5.h),
                                child: CustomIconWidget(
                                  iconName: 'send',
                                  color: theme.colorScheme.onPrimary,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build animated typing dot
  Widget _buildTypingDot(ThemeData theme, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animValue = (value - delay).clamp(0.0, 1.0);
        final opacity = (animValue * 2).clamp(0.3, 1.0);

        return Opacity(
          opacity: opacity,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }
}
