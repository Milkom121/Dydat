import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dydat/models/achievement.dart';
import 'package:dydat/models/api_response.dart';
import 'package:dydat/services/achievement_service.dart';

class AchievementState {
  final List<Achievement> unlocked;
  final List<AchievementProssimo> next;
  final bool isLoading;
  final String? error;

  const AchievementState({
    this.unlocked = const [],
    this.next = const [],
    this.isLoading = false,
    this.error,
  });

  int get unreadCount => unlocked.length;

  AchievementState copyWith({
    List<Achievement>? unlocked,
    List<AchievementProssimo>? next,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AchievementState(
      unlocked: unlocked ?? this.unlocked,
      next: next ?? this.next,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AchievementNotifier extends StateNotifier<AchievementState> {
  final AchievementService _achievementService;

  AchievementNotifier({required AchievementService achievementService})
      : _achievementService = achievementService,
        super(const AchievementState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _achievementService.getAll();
      state = state.copyWith(
        unlocked: response.sbloccati,
        next: response.prossimi,
        isLoading: false,
      );
    } on DioException catch (e) {
      final apiError = e.error;
      final msg = apiError is ApiException
          ? apiError.message
          : 'Errore caricamento achievement';
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  void clear() {
    state = const AchievementState();
  }
}

final achievementProvider =
    StateNotifierProvider<AchievementNotifier, AchievementState>((ref) {
  throw UnimplementedError(
    'achievementProvider must be overridden with proper dependencies',
  );
});
