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

  /// Stato corrente
  RecordingState get state;

  /// Rilascia le risorse
  void dispose();
}

/// Implementazione reale basata sul package `record`.
class RealAudioRecorderService implements AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  RecordingState _state = RecordingState.idle;

  @override
  RecordingState get state => _state;

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
  }

  @override
  Future<String?> stopRecording() async {
    final path = await _recorder.stop();
    _state = RecordingState.idle;
    return path;
  }

  @override
  void dispose() {
    _recorder.dispose();
    _state = RecordingState.idle;
    debugPrint('[AudioRecorder] disposed');
  }
}
