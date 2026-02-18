import 'package:dio/dio.dart';
import 'package:dydat/config/api_config.dart';
import 'package:dydat/models/api_response.dart';
import 'package:dydat/services/storage_service.dart';

class DioClient {
  final Dio dio;
  final StorageService _storageService;

  DioClient({
    required StorageService storageService,
    Dio? dio,
  })  : _storageService = storageService,
        dio = dio ?? Dio() {
    this.dio.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    );

    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  void _onError(DioException error, ErrorInterceptorHandler handler) {
    if (error.response != null) {
      final data = error.response!.data;
      String message;
      if (data is Map<String, dynamic> && data.containsKey('detail')) {
        final detail = data['detail'];
        message = detail is String ? detail : detail.toString();
      } else {
        message = error.message ?? 'Errore sconosciuto';
      }
      handler.reject(
        DioException(
          requestOptions: error.requestOptions,
          response: error.response,
          error: ApiException(
            statusCode: error.response!.statusCode ?? 500,
            message: message,
          ),
        ),
      );
    } else {
      handler.next(error);
    }
  }
}
