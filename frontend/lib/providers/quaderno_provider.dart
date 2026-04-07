import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dydat/models/api_response.dart';
import 'package:dydat/models/quaderno.dart';
import 'package:dydat/services/path_service.dart';

class QuadernoState {
  final QuadernoNodo? quaderno;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const QuadernoState({
    this.quaderno,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  QuadernoState copyWith({
    QuadernoNodo? quaderno,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
    bool clearQuaderno = false,
  }) {
    return QuadernoState(
      quaderno: clearQuaderno ? null : (quaderno ?? this.quaderno),
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
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

  /// Salva la nota personale dell'utente. Aggiorna lo stato locale con la nota salvata.
  Future<void> saveNota(String nodoId, String testo) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final nota = await _pathService.saveNotaUtente(nodoId, testo);
      // Aggiorna il quaderno locale con la nota appena salvata
      if (state.quaderno != null) {
        final updated = state.quaderno!.copyWith(notaUtente: nota);
        state = state.copyWith(quaderno: updated, isSaving: false);
      } else {
        state = state.copyWith(isSaving: false);
      }
    } on DioException catch (e) {
      final apiError = e.error;
      final msg = apiError is ApiException
          ? apiError.message
          : 'Errore salvataggio nota';
      state = state.copyWith(isSaving: false, error: msg);
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
