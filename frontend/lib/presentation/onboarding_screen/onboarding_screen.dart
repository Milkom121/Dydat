import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/sizer_extensions.dart';

import '../../providers/onboarding_provider.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/mascotte_widget.dart';
import './widgets/message_bubble_widget.dart';
import './widgets/progress_indicator_widget.dart';

/// Onboarding screen that introduces new users to AI-powered tutoring
/// through conversational interaction with SSE streaming.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  // Local list of chat items: user messages + finalized tutor messages.
  final List<Map<String, dynamic>> _messages = [];

  // Track how many tutor messages we've already synced from the provider.
  int _prevTutorMessagesCount = 0;

  @override
  void initState() {
    super.initState();
    // Start onboarding SSE stream after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProvider.notifier).startOnboarding();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  /// Scroll to bottom of message list.
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

  /// Handle sending a user message.
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final onboardingState = ref.read(onboardingProvider);
    if (onboardingState.isStreaming || onboardingState.isLoading) return;

    // Add user message to local list.
    setState(() {
      _messages.add({
        'text': message,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
    });
    _messageController.clear();
    _scrollToBottom();

    // Send via provider (triggers SSE stream).
    ref.read(onboardingProvider.notifier).sendMessage(message);
  }

  /// Syncs finalized tutor messages from the provider into the local _messages list.
  void _syncTutorMessages(OnboardingScreenState onboardingState) {
    final tutorMessages = onboardingState.tutorMessages;
    if (tutorMessages.length > _prevTutorMessagesCount) {
      for (int i = _prevTutorMessagesCount; i < tutorMessages.length; i++) {
        _messages.add({
          'text': tutorMessages[i],
          'isUser': false,
          'timestamp': DateTime.now(),
        });
      }
      _prevTutorMessagesCount = tutorMessages.length;
      _scrollToBottom();
    }
  }

  /// Handle retry on error.
  void _retryConnection() {
    ref.read(onboardingProvider.notifier).startOnboarding();
    setState(() {
      _messages.clear();
      _prevTutorMessagesCount = 0;
    });
  }

  /// Handle completing the onboarding and navigating to registration.
  Future<void> _completeOnboarding() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();

    if (!mounted) return;

    final onboardingState = ref.read(onboardingProvider);
    if (onboardingState.isCompleted && onboardingState.utenteTempId != null) {
      context.go('/registration');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onboardingState = ref.watch(onboardingProvider);

    // Sync finalized tutor messages from provider state.
    _syncTutorMessages(onboardingState);

    final isStreaming = onboardingState.isStreaming;
    final isLoading = onboardingState.isLoading;
    final hasError = onboardingState.error != null;
    final currentStreamText = onboardingState.currentTutorText;
    final progress = onboardingState.progress;

    // Check if onboarding conversation seems complete (~10 turns).
    final showCompleteButton =
        !isStreaming && !isLoading && onboardingState.turnsCompleted >= 8;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            ProgressIndicatorWidget(progress: progress),

            // Error banner
            if (hasError)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
                color: theme.colorScheme.error,
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'error_outline',
                      color: theme.colorScheme.onError,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        onboardingState.error!,
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
                      child: (_messages.isEmpty &&
                              currentStreamText.isEmpty &&
                              !hasError)
                          ? Center(
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.only(bottom: 2.h),
                              itemCount: _messages.length +
                                  (currentStreamText.isNotEmpty ? 1 : 0),
                              itemBuilder: (context, index) {
                                // Streaming bubble at the end
                                if (index == _messages.length &&
                                    currentStreamText.isNotEmpty) {
                                  return _buildStreamingBubble(
                                    theme,
                                    currentStreamText,
                                  );
                                }

                                final message = _messages[index];
                                return MessageBubbleWidget(
                                  text: message['text'] as String,
                                  isUser: message['isUser'] as bool,
                                  timestamp:
                                      message['timestamp'] as DateTime,
                                );
                              },
                            ),
                    ),

                    // Typing indicator (when waiting for first text_delta)
                    if (isStreaming && currentStreamText.isEmpty)
                      _buildTypingIndicator(theme),

                    // Complete onboarding button
                    if (showCompleteButton)
                      Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                isLoading ? null : _completeOnboarding,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  )
                                : Text(
                                    'Inizia il tuo percorso!',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
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
                              enabled: !isStreaming && !isLoading,
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
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outline
                                        .withValues(alpha: 0.5),
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
                            color: (isStreaming || isLoading)
                                ? theme.colorScheme.primary
                                    .withValues(alpha: 0.5)
                                : theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: (isStreaming || isLoading)
                                  ? null
                                  : _sendMessage,
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

  /// Build a streaming tutor bubble with amber pulsating cursor.
  Widget _buildStreamingBubble(ThemeData theme, String text) {
    _scrollToBottom();
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'school',
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Flexible(
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        height: 1.55,
                      ),
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

  /// Build typing indicator (before any text arrives).
  Widget _buildTypingIndicator(ThemeData theme) {
    return Padding(
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
