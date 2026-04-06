import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dydat/models/api_response.dart';
import 'package:dydat/models/quaderno.dart';
import 'package:dydat/services/path_service.dart';

class QuadernoState {
  final QuadernoNodo? quaderno;
  final bool isLoading;
  final String? error;

  const QuadernoState({
    this.quaderno,
    this.isLoading = false,
    this.error,
  });

  QuadernoState copyWith({
    QuadernoNodo? quaderno,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearQuaderno = false,
  }) {
    return QuadernoState(
      quaderno: clearQuaderno ? null : (quaderno ?? this.quaderno),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class QuadernoNotifier extends StateNotifier<QuadernoState> {
  final PathService _pathService;

  QuadernoNotifier({required PathService pathService})
      : _pathService = pathService,
        super(const QuadernoState());

  Future<void> carica(String nodoId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final quaderno = await _pathService.getQuadernoNodo(nodoId);
      state = state.copyWith(quaderno: quaderno, isLoading: false);
    } on DioException catch (e) {
      final apiError = e.error;
      final msg = apiError is ApiException
          ? apiError.message
          : 'Errore caricamento quaderno';
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  void clear() {
    state = const QuadernoState();
  }
}

final quadernoProvider =
    StateNotifierProvider<QuadernoNotifier, QuadernoState>((ref) {
  throw UnimplementedError(
    'quadernoProvider must be overridden with proper dependencies',
  );
});
