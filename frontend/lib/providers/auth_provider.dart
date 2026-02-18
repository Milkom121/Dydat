import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dydat/models/utente.dart';
import 'package:dydat/models/api_response.dart';
import 'package:dydat/services/auth_service.dart';
import 'package:dydat/services/storage_service.dart';
import 'package:dydat/services/user_service.dart';

class AuthState {
  final String? token;
  final Utente? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.token,
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => token != null;

  AuthState copyWith({
    String? token,
    Utente? user,
    bool? isLoading,
    String? error,
    bool clearToken = false,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      token: clearToken ? null : (token ?? this.token),
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final UserService _userService;
  final StorageService _storageService;

  AuthNotifier({
    required AuthService authService,
    required UserService userService,
    required StorageService storageService,
  })  : _authService = authService,
        _userService = userService,
        _storageService = storageService,
        super(const AuthState());

  /// Check for stored token on app start.
  Future<void> checkAuth() async {
    final token = await _storageService.getAccessToken();
    if (token == null) return;

    state = state.copyWith(token: token, isLoading: true, clearError: true);
    try {
      final user = await _userService.getMe();
      state = state.copyWith(user: user, isLoading: false);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException && apiError.statusCode == 401) {
        await _storageService.deleteAccessToken();
        state = const AuthState();
      } else {
        state = state.copyWith(isLoading: false, clearToken: true);
      }
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );
      await _storageService.saveAccessToken(response.accessToken);
      state = state.copyWith(token: response.accessToken, isLoading: false);

      final user = await _userService.getMe();
      state = state.copyWith(user: user);
    } on DioException catch (e) {
      final apiError = e.error;
      final message = apiError is ApiException
          ? apiError.message
          : 'Errore di connessione';
      state = state.copyWith(isLoading: false, error: message);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String nome,
    String? utenteTempId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _authService.register(
        email: email,
        password: password,
        nome: nome,
        utenteTempId: utenteTempId,
      );
      await _storageService.saveAccessToken(response.accessToken);
      state = state.copyWith(token: response.accessToken, isLoading: false);

      final user = await _userService.getMe();
      state = state.copyWith(user: user);
    } on DioException catch (e) {
      final apiError = e.error;
      final message = apiError is ApiException
          ? apiError.message
          : 'Errore di connessione';
      state = state.copyWith(isLoading: false, error: message);
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
    state = const AuthState();
  }

  /// Mock login for demo/development without backend.
  void mockLogin() {
    state = state.copyWith(token: 'mock-jwt-token', isLoading: false, clearError: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  throw UnimplementedError(
    'authProvider must be overridden with proper dependencies',
  );
});
