import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dydat/config/api_config.dart';
import 'package:dydat/services/dio_client.dart';

/// Risultato della trascrizione audio.
class SttResult {
  final String testo;
  SttResult({required this.testo});
}

/// Servizio astratto per la trascrizione audio (Speech-to-Text).
/// Consente di iniettare un mock nei test.
abstract class SttService {
  /// Invia il file audio al backend e ritorna il testo trascritto.
  /// Lancia [SttException] in caso di errore.
  Future<SttResult> transcribe(String filePath);
}

/// Eccezione specifica per errori STT con messaggio user-friendly.
class SttException implements Exception {
  final String message;
  final int? statusCode;
  SttException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Implementazione reale che chiama POST /stt/transcribe.
class RealSttService implements SttService {
  final DioClient _client;

  RealSttService({required DioClient client}) : _client = client;

  @override
  Future<SttResult> transcribe(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw SttException('File audio non trovato');
    }

    final fileName = filePath.split('/').last.split('\\').last;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    try {
      final response = await _client.dio.post(
        ApiConfig.sttTranscribe,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          // Trascrizione può impiegare tempo
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final testo = data['testo'] as String? ?? '';

      if (testo.isEmpty) {
        throw SttException('Nessun parlato riconosciuto');
      }

      return SttResult(testo: testo);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Mappa errori Dio in messaggi user-friendly italiani.
  SttException _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;

    // Estrae il detail dal backend se presente
    if (e.response?.data is Map<String, dynamic>) {
      final detail = (e.response!.data as Map<String, dynamic>)['detail'];
      if (detail is String && detail.isNotEmpty) {
        return SttException(detail, statusCode: statusCode);
      }
    }

    // Fallback per codici HTTP noti
    switch (statusCode) {
      case 400:
        return SttException('Formato audio non valido', statusCode: 400);
      case 422:
        return SttException('Nessun parlato riconosciuto', statusCode: 422);
      case 429:
        return SttException(
          'Troppe richieste. Riprova tra qualche secondo.',
          statusCode: 429,
        );
      case 502:
      case 503:
        return SttException(
          'Servizio di trascrizione non disponibile',
          statusCode: statusCode,
        );
      default:
        // Timeout / rete
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return SttException('La trascrizione sta impiegando troppo tempo');
        }
        if (e.type == DioExceptionType.connectionError) {
          return SttException(
            'Impossibile raggiungere il server. Controlla la connessione.',
          );
        }
        return SttException('Errore durante la trascrizione. Riprova.');
    }
  }
}
