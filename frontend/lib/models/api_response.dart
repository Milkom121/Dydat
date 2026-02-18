import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable()
class ApiError {
  final String detail;

  const ApiError({required this.detail});

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);
  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

@JsonSerializable()
class SseErrorEvent {
  final String codice;
  final String messaggio;

  const SseErrorEvent({required this.codice, required this.messaggio});

  factory SseErrorEvent.fromJson(Map<String, dynamic> json) =>
      _$SseErrorEventFromJson(json);
  Map<String, dynamic> toJson() => _$SseErrorEventToJson(this);
}

@JsonSerializable()
class AchievementEvent {
  final String id;
  final String nome;
  final String tipo;

  const AchievementEvent({
    required this.id,
    required this.nome,
    required this.tipo,
  });

  factory AchievementEvent.fromJson(Map<String, dynamic> json) =>
      _$AchievementEventFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementEventToJson(this);
}
