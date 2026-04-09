import 'package:flutter/material.dart';

import '../../../core/sizer_extensions.dart';
import '../../../services/audio_recorder_service.dart';
import '../../../services/stt_service.dart';
import '../../../widgets/voice_input_field.dart';

/// Barra di input per inviare messaggi al tutor durante la sessione.
/// Usa VoiceInputField per supportare testo e dettatura vocale.
class SessionInputBarWidget extends StatelessWidget {
  final bool isActive;
  final bool isStreaming;
  final TextEditingController messageController;
  final ValueChanged<String> onSend;

  /// Servizio recorder iniettabile (per test). Se null, usa quello di default.
  final AudioRecorderService? recorderService;

  /// Servizio STT iniettabile (per test). Se null, trascrizione non disponibile.
  final SttService? sttService;

  /// Callback per errori di trascrizione (es. mostrare snackbar).
  final ValueChanged<String>? onTranscriptionError;

  const SessionInputBarWidget({
    super.key,
    required this.isActive,
    required this.isStreaming,
    required this.messageController,
    required this.onSend,
    this.recorderService,
    this.sttService,
    this.onTranscriptionError,
  });

  String get _hintText {
    if (isStreaming) return 'Il tutor sta rispondendo...';
    if (isActive) return 'Scrivi o detta un messaggio...';
    return 'Inizia la sessione per chattare';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canInteract = isActive && !isStreaming;

    return Container(
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
      child: VoiceInputField(
        controller: messageController,
        hintText: _hintText,
        enabled: canInteract,
        onSubmit: onSend,
        recorderService: recorderService,
        sttService: sttService,
        onTranscriptionError: onTranscriptionError,
      ),
    );
  }
}
