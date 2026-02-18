import 'package:dydat/config/api_config.dart';
import 'package:dydat/models/achievement.dart';
import 'package:dydat/services/dio_client.dart';

class AchievementService {
  final DioClient _client;

  AchievementService({required DioClient client}) : _client = client;

  /// Gets all achievements (unlocked + next with progress).
  Future<AchievementResponse> getAll() async {
    final response = await _client.dio.get(ApiConfig.achievements);
    return AchievementResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
