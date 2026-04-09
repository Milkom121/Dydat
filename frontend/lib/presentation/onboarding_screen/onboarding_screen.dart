import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/sizer_extensions.dart';

import '../../providers/onboarding_provider.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/markdown_text.dart';
import '../../widgets/voice_input_field.dart';
import './widgets/mascotte_widget.dart';
import './widgets/message_bubble_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/scelta_singola_widget.dart';
import './widgets/scala_widget.dart';

/// Schermata onboarding narrativa con VoiceInputField e bottone skip.
///
/// L'utente si racconta liberamente (anche a voce), il tutor adatta il flusso
/// tramite il decisore forma C. "Salta per ora" è visibile fin dall'inizio.
/// Se [resume] è true, riprende la sessione precedente dal backend.
class OnboardingScreen extends ConsumerStatefulWidget {
  final bool resume;

  const OnboardingScreen({super.key, this.resume = false});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final ScrollController _scrollController = ScrollController();

  // Chiave per accedere allo stato di VoiceInputField (controller testo)
  final GlobalKey<VoiceInputFieldState> _voiceInputKey =
      GlobalKey<VoiceInputFieldState>();

  // Lista locale messaggi: utente + tutor finalizzati
  final List<Map<String, dynamic>> _messages = [];

  // Quanti messaggi tutor abbiamo già sincronizzato dal provider
  int _prevTutorMessagesCount = 0;

  @override
  void initState() {
    super.initState();
    // Avvia o riprendi onboarding dopo il primo frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.resume) {
        ref.read(onboardingProvider.notifier).resumeOnboarding();
      } else {
        ref.read(onboardingProvider.notifier).startOnboarding();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scrolla in fondo alla lista messaggi
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

  /// Invia messaggio utente (da VoiceInputField)
  Future<void> _sendMessage(String message) async {
    final onboardingState = ref.read(onboardingProvider);
    if (onboardingState.isStreaming || onboardingState.isLoading) return;

    // Aggiungi alla lista locale
    setState(() {
      _messages.add({
        'text': message,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
    });
    _scrollToBottom();

    // Invia via provider (trigger SSE)
    ref.read(onboardingProvider.notifier).sendMessage(message);
  }

  /// Risposta a domanda strutturata (scelta singola, scala)
  void _answerQuestion(String answer) {
    final onboardingState = ref.read(onboardingProvider);
    if (onboardingState.isStreaming || onboardingState.isLoading) return;

    // Cattura la domanda prima di pulirla
    final question = onboardingState.currentQuestion;

    // Pulisce la domanda nel provider — la card sparisce subito
    ref.read(onboardingProvider.notifier).answerQuestion(answer);

    // Aggiunge domanda + risposta alla cronologia locale
    setState(() {
      if (question != null) {
        _messages.add({
          'text': question.domanda,
          'isUser': false,
          'timestamp': DateTime.now(),
        });
      }
      _messages.add({
        'text': answer,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  // Flag per evitare di caricare la conversazione ripristinata più volte
  bool _resumeLoaded = false;

  /// Sincronizza messaggi tutor finalizzati dal provider nella lista locale.
  /// Se c'è una conversazione ripristinata (resume), la carica una sola volta.
  void _syncTutorMessages(OnboardingScreenState onboardingState) {
    // Carica conversazione ripristinata (una sola volta)
    if (!_resumeLoaded && onboardingState.resumedConversation != null) {
      _resumeLoaded = true;
      for (final turno in onboardingState.resumedConversation!) {
        if (turno.contenuto != null && turno.contenuto!.isNotEmpty) {
          _messages.add({
            'text': turno.contenuto!,
            'isUser': turno.ruolo == 'user',
            'timestamp': DateTime.now(),
          });
        }
      }
      // Allinea il contatore con i messaggi tutor già presenti
      _prevTutorMessagesCount = onboardingState.tutorMessages.length;
      _scrollToBottom();
      return;
    }

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

  /// Riprova in caso di errore
  void _retryConnection() {
    ref.read(onboardingProvider.notifier).startOnboarding();
    setState(() {
      _messages.clear();
      _prevTutorMessagesCount = 0;
    });
  }

  /// Completa l'onboarding e naviga a registrazione
  Future<void> _completeOnboarding() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();

    if (!mounted) return;

    final onboardingState = ref.read(onboardingProvider);
    if (onboardingState.isCompleted && onboardingState.utenteTempId != null) {
      context.go('/registration');
    }
  }

  /// L'utente salta l'onboarding
  void _skipOnboarding() {
    ref.read(onboardingProvider.notifier).skipOnboarding();

    if (!mounted) return;

    final onboardingState = ref.read(onboardingProvider);
    // Se ha già un utenteTempId, va a registrazione. Altrimenti login.
    if (onboardingState.utenteTempId != null) {
      context.go('/registration');
    } else {
      context.go('/login');
    }
  }

  /// Etichetta fase per l'indicatore di progresso
  String _faseLabel(OnboardingFase fase) {
    return switch (fase) {
      OnboardingFase.accoglienza => 'Benvenuto',
      OnboardingFase.conoscenza => 'Conosciamoci',
      OnboardingFase.placement => 'Valutazione',
      OnboardingFase.piano => 'Il tuo percorso',
      OnboardingFase.conclusione => 'Pronti a partire',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onboardingState = ref.watch(onboardingProvider);

    // Sincronizza messaggi tutor
    _syncTutorMessages(onboardingState);

    final isStreaming = onboardingState.isStreaming;
    final isLoading = onboardingState.isLoading;
    final hasError = onboardingState.error != null;
    final currentStreamText = onboardingState.currentTutorText;
    final progress = onboardingState.progress;

    // Il bottone completa appare nella fase conclusione (non più basato su turni)
    final showCompleteButton = !isStreaming &&
        !isLoading &&
        onboardingState.faseCorrente == OnboardingFase.conclusione;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Barra progresso + fase + skip
            _buildTopBar(theme, onboardingState, progress),

            // Banner errore
            if (hasError) _buildErrorBanner(theme, onboardingState),

            // Contenuto principale
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  children: [
                    SizedBox(height: 2.h),

                    // Mascotte
                    const MascotteWidget(),

                    SizedBox(height: 3.h),

                    // Area messaggi
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
                                // Bolla streaming in fondo
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

                    // Indicatore digitazione (in attesa del primo text_delta)
                    if (isStreaming && currentStreamText.isEmpty)
                      _buildTypingIndicator(theme),

                    // Area inferiore: completa / domanda strutturata / VoiceInputField
                    if (showCompleteButton)
                      _buildCompleteButton(theme, isLoading)
                    else
                      _buildBottomArea(theme, onboardingState),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Barra superiore: progresso, etichetta fase, bottone salta
  Widget _buildTopBar(
    ThemeData theme,
    OnboardingScreenState onboardingState,
    double progress,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Barra progresso
        ProgressIndicatorWidget(progress: progress),

        // Riga fase + salta
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
          child: Row(
            children: [
              // Etichetta fase
              Text(
                _faseLabel(onboardingState.faseCorrente),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Bottone salta — sempre visibile (tranne se completato)
              if (!onboardingState.isCompleted)
                TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Salta per ora',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Banner errore
  Widget _buildErrorBanner(
    ThemeData theme,
    OnboardingScreenState onboardingState,
  ) {
    return Container(
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
    );
  }

  /// Area inferiore dinamica: nulla (streaming), domanda strutturata, o VoiceInputField
  Widget _buildBottomArea(
    ThemeData theme,
    OnboardingScreenState onboardingState,
  ) {
    final isStreaming = onboardingState.isStreaming;
    final isLoading = onboardingState.isLoading;
    final question = onboardingState.currentQuestion;

    // Durante streaming/loading non mostrare nulla
    if (isStreaming || isLoading) {
      return const SizedBox.shrink();
    }

    // Se c'è una domanda strutturata, mostra il widget appropriato
    if (question != null) {
      return Padding(
        padding: EdgeInsets.only(bottom: 1.h),
        child: switch (question.tipoInput) {
          'scelta_singola' => SceltaSingolaWidget(
              question: question,
              onAnswer: _answerQuestion,
            ),
          'scala' => ScalaWidget(
              question: question,
              onAnswer: _answerQuestion,
            ),
          // testo_libero e qualsiasi altro tipo → VoiceInputField
          _ => _buildVoiceInput(theme),
        },
      );
    }

    // Default: VoiceInputField
    return _buildVoiceInput(theme);
  }

  /// Campo input con VoiceInputField (testo + voce)
  Widget _buildVoiceInput(ThemeData theme) {
    final onboardingState = ref.read(onboardingProvider);
    final isEnabled = !onboardingState.isStreaming && !onboardingState.isLoading;

    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: VoiceInputField(
        key: _voiceInputKey,
        hintText: 'Scrivi o parla...',
        onSubmit: _sendMessage,
        enabled: isEnabled,
        maxLines: null,
        onTranscriptionError: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  /// Bottone "Inizia il tuo percorso!" (fase conclusione)
  Widget _buildCompleteButton(ThemeData theme, bool isLoading) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : _completeOnboarding,
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  /// Bolla streaming tutor con cursore ambra pulsante
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

  /// Indicatore digitazione (prima che arrivi qualsiasi testo)
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

/// Cursore ambra pulsante mostrato alla fine del testo in streaming.
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
