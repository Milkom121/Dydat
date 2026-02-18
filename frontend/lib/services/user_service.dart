import 'package:dydat/config/api_config.dart';
import 'package:dydat/models/utente.dart';
import 'package:dydat/models/statistiche.dart';
import 'package:dydat/services/dio_client.dart';

class UserService {
  final DioClient _client;

  UserService({required DioClient client}) : _client = client;

  Future<Utente> getMe() async {
    final response = await _client.dio.get(ApiConfig.me);
    return Utente.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Utente> updatePreferences(PreferenzeStudio preferences) async {
    final response = await _client.dio.put(
      ApiConfig.preferences,
      data: preferences.toJson(),
    );
    return Utente.fromJson(response.data as Map<String, dynamic>);
  }

  Future<StatisticheUtente> getStats() async {
    final response = await _client.dio.get(ApiConfig.stats);
    return StatisticheUtente.fromJson(response.data as Map<String, dynamic>);
  }
}
