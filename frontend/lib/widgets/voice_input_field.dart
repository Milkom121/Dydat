import 'dart:async';
import 'dart:math' as math;

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
class VoiceInputFieldState extends State<VoiceInputField>
    with TickerProviderStateMixin {
  late final TextEditingController _controller;
  bool _ownsController = false;

  late AudioRecorderService _recorder;
  bool _ownsRecorder = false;

  RecordingState _recordingState = RecordingState.idle;
  bool _permissionDenied = false;

  // Animazione pulsante stop (pulsazione)
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // Timer secondi registrazione
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;

  // Ampiezza corrente per wave (0.0 - 1.0)
  double _currentAmplitude = 0.0;
  StreamSubscription<double>? _amplitudeSubscription;

  // Animazione wave continua
  late final AnimationController _waveController;

  TextEditingController get controller => _controller;

  /// Stato corrente della registrazione — esposto per test e widget esterni
  RecordingState get recordingState => _recordingState;

  /// True se il permesso microfono è stato negato dall'utente
  bool get permissionDenied => _permissionDenied;

  /// Secondi trascorsi dall'inizio della registrazione — esposto per test
  int get elapsedSeconds => _elapsedSeconds;

  /// Ampiezza corrente normalizzata — esposta per test
  double get currentAmplitude => _currentAmplitude;

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

    // Pulsazione pulsante stop: scale 1.0 → 1.15 → 1.0
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animazione wave continua (ciclo sinusoidale)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _stopTimerAndAnimations();
    _amplitudeSubscription?.cancel();
    if (_recordingState == RecordingState.recording) {
      _recorder.stopRecording();
    }
    _pulseController.dispose();
    _waveController.dispose();
    if (_ownsController) _controller.dispose();
    if (_ownsRecorder) _recorder.dispose();
    super.dispose();
  }

  void _startTimerAndAnimations() {
    _elapsedSeconds = 0;
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
    _pulseController.repeat(reverse: true);
    _waveController.repeat();

    // Ascolta ampiezza dal recorder
    _amplitudeSubscription = _recorder.amplitudeStream.listen((amp) {
      if (mounted) setState(() => _currentAmplitude = amp);
    });
  }

  void _stopTimerAndAnimations() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    _elapsedSeconds = 0;
    _currentAmplitude = 0.0;
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    _pulseController.stop();
    _pulseController.reset();
    _waveController.stop();
    _waveController.reset();
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
        _startTimerAndAnimations();
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
      if (mounted) {
        _stopTimerAndAnimations();
        setState(() => _recordingState = RecordingState.idle);
      }
      if (path != null && widget.onAudioRecorded != null) {
        widget.onAudioRecorded!(path);
      }
    } catch (e) {
      if (mounted) {
        _stopTimerAndAnimations();
        setState(() => _recordingState = RecordingState.idle);
      }
      debugPrint('Errore stop registrazione: $e');
    }
  }

  /// Formatta i secondi in mm:ss
  String _formatElapsed(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRecording = _recordingState == RecordingState.recording;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Campo di testo / indicatore registrazione
        Expanded(
          child: isRecording
              ? _buildRecordingIndicator(theme)
              : _buildTextField(theme),
        ),
        SizedBox(width: 2.w),
        // Pulsante microfono (registra/ferma) — pulsante durante registrazione
        Semantics(
          label: isRecording
              ? 'Ferma registrazione'
              : (_permissionDenied
                  ? 'Microfono — permesso negato'
                  : 'Registra messaggio vocale'),
          child: isRecording
              ? _buildPulsingStopButton(theme)
              : _buildMicButton(theme),
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

  Widget _buildTextField(ThemeData theme) {
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      decoration: InputDecoration(
        hintText: widget.hintText,
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
    );
  }

  /// Indicatore visivo durante la registrazione: wave + timer
  Widget _buildRecordingIndicator(ThemeData theme) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.4),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Row(
        children: [
          // Pallino rosso lampeggiante
          _buildRecordingDot(theme),
          SizedBox(width: 2.w),
          // Timer
          Text(
            _formatElapsed(_elapsedSeconds),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(width: 3.w),
          // Wave animata
          Expanded(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _WavePainter(
                    amplitude: _currentAmplitude,
                    phase: _waveController.value * 2 * math.pi,
                    color: theme.colorScheme.error.withValues(alpha: 0.6),
                  ),
                  size: const Size(double.infinity, 24),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Pallino rosso che pulsa durante la registrazione
  Widget _buildRecordingDot(ThemeData theme) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.error
                .withValues(alpha: 0.4 + 0.6 * (_pulseAnimation.value - 1.0) / 0.15),
          ),
        );
      },
    );
  }

  Widget _buildMicButton(ThemeData theme) {
    return IconButton(
      onPressed: widget.enabled ? _handleMicTap : null,
      icon: Icon(
        Icons.mic,
        color: widget.enabled
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.3),
      ),
      tooltip: 'Registra voce',
    );
  }

  /// Pulsante stop con animazione di pulsazione
  Widget _buildPulsingStopButton(ThemeData theme) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: IconButton(
            onPressed: widget.enabled ? _handleMicTap : null,
            icon: Icon(
              Icons.stop_rounded,
              color: theme.colorScheme.error,
            ),
            tooltip: 'Ferma registrazione',
          ),
        );
      },
    );
  }
}

/// Painter per la wave animata che rappresenta il volume della voce.
/// Disegna una sinusoide con ampiezza proporzionale al volume rilevato.
class _WavePainter extends CustomPainter {
  final double amplitude;
  final double phase;
  final Color color;

  _WavePainter({
    required this.amplitude,
    required this.phase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final midY = size.height / 2;
    // Ampiezza minima per mostrare attività anche in silenzio
    final waveHeight = size.height * 0.3 * (0.15 + 0.85 * amplitude);

    path.moveTo(0, midY);
    for (double x = 0; x <= size.width; x += 1) {
      final normalized = x / size.width;
      // Envelope: più alta al centro, zero ai bordi
      final envelope =
          math.sin(normalized * math.pi);
      final y = midY +
          waveHeight *
              envelope *
              math.sin(normalized * 4 * math.pi + phase);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      amplitude != oldDelegate.amplitude || phase != oldDelegate.phase;
}
