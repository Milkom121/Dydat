import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dydat/models/api_response.dart';
import 'package:dydat/models/percorso.dart';
import 'package:dydat/models/tema.dart';
import 'package:dydat/services/path_service.dart';

class PathState {
  final List<Percorso> paths;
  final MappaPercorso? currentMap;
  final List<Tema> topics;
  final TemaDettaglio? currentTopicDetail;
  final bool isLoading;
  final String? error;

  const PathState({
    this.paths = const [],
    this.currentMap,
    this.topics = const [],
    this.currentTopicDetail,
    this.isLoading = false,
    this.error,
  });

  PathState copyWith({
    List<Percorso>? paths,
    MappaPercorso? currentMap,
    List<Tema>? topics,
    TemaDettaglio? currentTopicDetail,
    bool? isLoading,
    String? error,
    bool clearMap = false,
    bool clearTopicDetail = false,
    bool clearError = false,
  }) {
    return PathState(
      paths: paths ?? this.paths,
      currentMap: clearMap ? null : (currentMap ?? this.currentMap),
      topics: topics ?? this.topics,
      currentTopicDetail: clearTopicDetail
          ? null
          : (currentTopicDetail ?? this.currentTopicDetail),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PathNotifier extends StateNotifier<PathState> {
  final PathService _pathService;

  PathNotifier({required PathService pathService})
      : _pathService = pathService,
        super(const PathState());

  Future<void> loadPaths() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final paths = await _pathService.getPaths();
      state = state.copyWith(paths: paths, isLoading: false);
    } on DioException catch (e) {
      final apiError = e.error;
      final msg = apiError is ApiException
          ? apiError.message
          : 'Errore caricamento percorsi';
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  Future<void> loadMap(int percorsoId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final map = await _pathService.getMap(percorsoId);
      state = state.copyWith(currentMap: map, isLoading: false);
    } on DioException catch (e) {
      final apiError = e.error;
      final msg = apiError is ApiException
          ? apiError.message
          : 'Errore caricamento mappa';
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  Future<void> loadTopics() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final topics = await _pathService.getTopics();
      state = state.copyWith(topics: topics, isLoading: false);
    } on DioException catch (e) {
      final apiError = e.error;
      final msg = apiError is ApiException
          ? apiError.message
          : 'Errore caricamento temi';
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  Future<void> loadTopicDetail(String temaId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final detail = await _pathService.getTopicDetail(temaId);
      state = state.copyWith(currentTopicDetail: detail, isLoading: false);
    } on DioException catch (e) {
      final apiError = e.error;
      final msg = apiError is ApiException
          ? apiError.message
          : 'Errore caricamento dettaglio tema';
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  /// Refreshes both paths and topics.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final paths = await _pathService.getPaths();
      final topics = await _pathService.getTopics();
      state = state.copyWith(
        paths: paths,
        topics: topics,
        isLoading: false,
      );
    } on DioException catch (e) {
      final apiError = e.error;
      final msg = apiError is ApiException
          ? apiError.message
          : 'Errore refresh percorsi';
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  void clear() {
    state = const PathState();
  }
}

final pathProvider = StateNotifierProvider<PathNotifier, PathState>((ref) {
  throw UnimplementedError(
    'pathProvider must be overridden with proper dependencies',
  );
});
