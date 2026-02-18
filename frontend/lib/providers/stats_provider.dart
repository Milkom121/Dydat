import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dydat/models/api_response.dart';
import 'package:dydat/models/statistiche.dart';
import 'package:dydat/services/user_service.dart';

class StatsState {
  final StatisticheUtente? stats;
  final bool isLoading;
  final String? error;

  const StatsState({
    this.stats,
    this.isLoading = false,
    this.error,
  });

  StatsState copyWith({
    StatisticheUtente? stats,
    bool? isLoading,
    String? error,
    bool clearStats = false,
    bool clearError = false,
  }) {
    return StatsState(
      stats: clearStats ? null : (stats ?? this.stats),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class StatsNotifier extends StateNotifier<StatsState> {
  final UserService _userService;

  StatsNotifier({required UserService userService})
      : _userService = userService,
        super(const StatsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final stats = await _userService.getStats();
      state = state.copyWith(stats: stats, isLoading: false);
    } on DioException catch (e) {
      final apiError = e.error;
      final msg = apiError is ApiException
          ? apiError.message
          : 'Errore caricamento statistiche';
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  void clear() {
    state = const StatsState();
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, StatsState>((ref) {
  throw UnimplementedError(
    'statsProvider must be overridden with proper dependencies',
  );
});
