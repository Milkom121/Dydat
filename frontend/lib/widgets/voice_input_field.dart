import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/sizer_extensions.dart';
import '../services/audio_recorder_service.dart';

/// Campo di input testuale riutilizzabile con pulsante microfono.
///
/// Il pulsante microfono avvia/ferma la registrazione audio.
/// Al termine, il file audio viene passato via [onAudioRecorded].
/// Usato in: onboarding, sessione studio, ricerca "I miei studi".
class VoiceInputField extends StatefulWidget {
  /// Testo placeholder nel campo input
  final String hintText;

  /// Callback quando l'utente invia il testo
  final ValueChanged<String> onSubmit;

  /// Se true, il campo è disabilitato (es. durante streaming tutor)
  final bool enabled;

  /// Numero massimo di righe (null = illimitato)
  final int? maxLines;

  /// Controller esterno opzionale (se null, ne crea uno interno)
  final TextEditingController? controller;

  /// Callback quando una registrazione audio è completata (path del file)
  final ValueChanged<String>? onAudioRecorded;

  /// Servizio recorder iniettabile (per test). Se null, usa RealAudioRecorderService.
  final AudioRecorderService? recorderService;

  const VoiceInputField({
    super.key,
    this.hintText = 'Scrivi qui...',
    required this.onSubmit,
    this.enabled = true,
    this.maxLines,
    this.controller,
    this.onAudioRecorded,
    this.recorderService,
  });

  @override
  State<VoiceInputField> createState() => VoiceInputFieldState();
}

/// Stato pubblico per consentire accesso al controller dall'esterno
/// (es. per popolare il testo trascritto in B39.7.5).
class VoiceInputFieldState extends State<VoiceInputField> {
  late final TextEditingController _controller;
  bool _ownsController = false;

  late AudioRecorderService _recorder;
  bool _ownsRecorder = false;

  RecordingState _recordingState = RecordingState.idle;
  bool _permissionDenied = false;

  TextEditingController get controller => _controller;

  /// Stato corrente della registrazione — esposto per test e widget esterni
  RecordingState get recordingState => _recordingState;

  /// True se il permesso microfono è stato negato dall'utente
  bool get permissionDenied => _permissionDenied;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    if (widget.recorderService != null) {
      _recorder = widget.recorderService!;
    } else {
      _recorder = RealAudioRecorderService();
      _ownsRecorder = true;
    }
  }

  @override
  void dispose() {
    // Se stiamo registrando, ferma prima di disporre
    if (_recordingState == RecordingState.recording) {
      _recorder.stopRecording();
    }
    if (_ownsController) _controller.dispose();
    if (_ownsRecorder) _recorder.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    widget.onSubmit(text);
    _controller.clear();
  }

  Future<void> _handleMicTap() async {
    if (_recordingState == RecordingState.idle) {
      await _startRecording();
    } else {
      await _stopRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        if (mounted) setState(() => _permissionDenied = true);
        return;
      }
      await _recorder.startRecording();
      HapticFeedback.mediumImpact();
      if (mounted) {
        setState(() {
          _recordingState = RecordingState.recording;
          _permissionDenied = false;
        });
      }
    } catch (e) {
      // Fallback silenzioso — l'utente può continuare a scrivere
      debugPrint('Errore avvio registrazione: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stopRecording();
      HapticFeedback.lightImpact();
      if (mounted) setState(() => _recordingState = RecordingState.idle);
      if (path != null && widget.onAudioRecorded != null) {
        widget.onAudioRecorded!(path);
      }
    } catch (e) {
      if (mounted) setState(() => _recordingState = RecordingState.idle);
      debugPrint('Errore stop registrazione: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRecording = _recordingState == RecordingState.recording;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Campo di testo
        Expanded(
          child: TextField(
            controller: _controller,
            enabled: widget.enabled && !isRecording,
            decoration: InputDecoration(
              hintText:
                  isRecording ? 'Registrazione in corso...' : widget.hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 1.5.h,
              ),
            ),
            maxLines: widget.maxLines,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _handleSubmit(),
          ),
        ),
        SizedBox(width: 2.w),
        // Pulsante microfono (registra/ferma)
        Semantics(
          label: isRecording
              ? 'Ferma registrazione'
              : (_permissionDenied
                  ? 'Microfono — permesso negato'
                  : 'Registra messaggio vocale'),
          child: IconButton(
            onPressed: widget.enabled ? _handleMicTap : null,
            icon: Icon(
              isRecording ? Icons.stop_rounded : Icons.mic,
              color: isRecording
                  ? theme.colorScheme.error
                  : (widget.enabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            ),
            tooltip: isRecording ? 'Ferma registrazione' : 'Registra voce',
          ),
        ),
        // Pulsante invio (disabilitato durante registrazione)
        IconButton(
          onPressed: widget.enabled && !isRecording ? _handleSubmit : null,
          icon: Icon(
            Icons.send_rounded,
            color: widget.enabled && !isRecording
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          tooltip: 'Invia',
        ),
      ],
    );
  }
}
