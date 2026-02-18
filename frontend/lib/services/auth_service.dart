import 'package:dydat/config/api_config.dart';
import 'package:dydat/models/utente.dart';
import 'package:dydat/services/dio_client.dart';

class AuthService {
  final DioClient _client;

  AuthService({required DioClient client}) : _client = client;

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post(
      ApiConfig.login,
      data: LoginRequest(email: email, password: password).toJson(),
    );
    return LoginResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<LoginResponse> register({
    required String email,
    required String password,
    required String nome,
    String? utenteTempId,
  }) async {
    final response = await _client.dio.post(
      ApiConfig.register,
      data: RegisterRequest(
        email: email,
        password: password,
        nome: nome,
        utenteTempId: utenteTempId,
      ).toJson(),
    );
    return LoginResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
