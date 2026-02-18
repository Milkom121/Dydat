import 'package:dydat/config/api_config.dart';
import 'package:dydat/models/percorso.dart';
import 'package:dydat/models/tema.dart';
import 'package:dydat/services/dio_client.dart';

class PathService {
  final DioClient _client;

  PathService({required DioClient client}) : _client = client;

  /// Gets all paths for the authenticated user.
  Future<List<Percorso>> getPaths() async {
    final response = await _client.dio.get(ApiConfig.paths);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Percorso.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Gets the node map for a specific path.
  Future<MappaPercorso> getMap(int percorsoId) async {
    final response = await _client.dio.get(ApiConfig.pathMap(percorsoId));
    return MappaPercorso.fromJson(response.data as Map<String, dynamic>);
  }

  /// Gets all topics with user progress.
  Future<List<Tema>> getTopics() async {
    final response = await _client.dio.get(ApiConfig.topics);
    final list = response.data as List<dynamic>;
    return list.map((e) => Tema.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Gets detail of a specific topic with nodes.
  Future<TemaDettaglio> getTopicDetail(String temaId) async {
    final response = await _client.dio.get(ApiConfig.topicDetail(temaId));
    return TemaDettaglio.fromJson(response.data as Map<String, dynamic>);
  }
}
