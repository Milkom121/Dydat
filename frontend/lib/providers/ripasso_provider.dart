import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dydat/models/api_response.dart';
import 'package:dydat/models/ripasso.dart';
import 'package:dydat/services/path_service.dart';

class RipassoState {
  final List<NodoRipasso> nodi;
  final bool isLoading;
  final String? error;

  const RipassoState({
    this.nodi = const [],
    this.isLoading = false,
    this.error,
  });

  RipassoState copyWith({
    List<NodoRipasso>? nodi,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return RipassoState(
      nodi: nodi ?? this.nodi,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Mappa tema_id -> conteggio nodi da ripassare per quel tema.
  Map<String, int> get conteggioPerTema {
    final counts = <String, int>{};
    for (final nodo in nodi) {
      counts[nodo.temaId] = (counts[nodo.temaId] ?? 0) + 1;
    }
    return counts;
  }

  int get totale => nodi.length;
}

class RipassoNotifier extends StateNotifier<RipassoState> {
  final PathService _pathService;

  RipassoNotifier({required PathService pathService})
      : _pathService = pathService,
        super(const RipassoState());

  Future<void> carica() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final nodi = await _pathService.getNodiDaRipassare();
      state = state.copyWith(nodi: nodi, isLoading: false);
    } on DioException catch (e) {
      final apiError = e.error;
      final msg = apiError is ApiException
          ? apiError.message
          : 'Errore caricamento nodi ripasso';
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  void clear() {
    state = const RipassoState();
  }
}

final ripassoProvider =
    StateNotifierProvider<RipassoNotifier, RipassoState>((ref) {
  throw UnimplementedError(
    'ripassoProvider must be overridden with proper dependencies',
  );
});
