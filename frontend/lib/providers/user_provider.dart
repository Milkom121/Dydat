import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dydat/models/utente.dart';
import 'package:dydat/models/api_response.dart';
import 'package:dydat/services/user_service.dart';

class UserState {
  final Utente? profile;
  final bool isLoading;
  final String? error;

  const UserState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    Utente? profile,
    bool? isLoading,
    String? error,
    bool clearProfile = false,
    bool clearError = false,
  }) {
    return UserState(
      profile: clearProfile ? null : (profile ?? this.profile),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final UserService _userService;

  UserNotifier({required UserService userService})
      : _userService = userService,
        super(const UserState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await _userService.getMe();
      state = state.copyWith(profile: profile, isLoading: false);
    } on DioException catch (e) {
      final apiError = e.error;
      final message = apiError is ApiException
          ? apiError.message
          : 'Errore nel caricamento profilo';
      state = state.copyWith(isLoading: false, error: message);
    }
  }

  Future<void> updatePreferences(PreferenzeStudio preferences) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updated = await _userService.updatePreferences(preferences);
      state = state.copyWith(profile: updated, isLoading: false);
    } on DioException catch (e) {
      final apiError = e.error;
      final message = apiError is ApiException
          ? apiError.message
          : 'Errore nell\'aggiornamento preferenze';
      state = state.copyWith(isLoading: false, error: message);
    }
  }

  void clear() {
    state = const UserState();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  throw UnimplementedError(
    'userProvider must be overridden with proper dependencies',
  );
});
