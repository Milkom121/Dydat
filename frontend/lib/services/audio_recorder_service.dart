import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

/// Stato della registrazione audio
enum RecordingState { idle, recording }

/// Servizio astratto per la registrazione audio.
/// Consente di iniettare un mock nei test senza dipendere dal package reale.
abstract class AudioRecorderService {
  /// Verifica (e richiede se necessario) il permesso microfono
  Future<bool> hasPermission();

  /// Avvia la registrazione. Salva in un file temporaneo .m4a.
  Future<void> startRecording();

  /// Ferma la registrazione e ritorna il path del file audio (null se errore).
  Future<String?> stopRecording();

  /// Stream di ampiezza normalizzata [0.0 - 1.0] durante la registrazione.
  /// Emesso circa ogni 100ms. 0.0 = silenzio, 1.0 = volume massimo.
  Stream<double> get amplitudeStream;

  /// Stato corrente
  RecordingState get state;

  /// Rilascia le risorse
  void dispose();
}

/// Implementazione reale basata sul package `record`.
class RealAudioRecorderService implements AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  RecordingState _state = RecordingState.idle;

  final StreamController<double> _amplitudeController =
      StreamController<double>.broadcast();

  StreamSubscription<Amplitude>? _amplitudeSubscription;

  @override
  RecordingState get state => _state;

  @override
  Stream<double> get amplitudeStream => _amplitudeController.stream;

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<void> startRecording() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${Directory.systemTemp.path}/dydat_voice_$timestamp.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: path,
    );
    _state = RecordingState.recording;

    // Stream ampiezza: converte dBFS (-160..0) in valore normalizzato (0..1)
    _amplitudeSubscription = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen((amp) {
      // amp.current è in dBFS: -160 (silenzio) a 0 (massimo)
      final normalized = ((amp.current + 60) / 60).clamp(0.0, 1.0);
      _amplitudeController.add(normalized);
    });
  }

  @override
  Future<String?> stopRecording() async {
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    final path = await _recorder.stop();
    _state = RecordingState.idle;
    return path;
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _amplitudeController.close();
    _recorder.dispose();
    _state = RecordingState.idle;
    debugPrint('[AudioRecorder] disposed');
  }
}
