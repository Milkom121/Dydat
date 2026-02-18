// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiError _$ApiErrorFromJson(Map<String, dynamic> json) =>
    ApiError(detail: json['detail'] as String);

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) => <String, dynamic>{
  'detail': instance.detail,
};

SseErrorEvent _$SseErrorEventFromJson(Map<String, dynamic> json) =>
    SseErrorEvent(
      codice: json['codice'] as String,
      messaggio: json['messaggio'] as String,
    );

Map<String, dynamic> _$SseErrorEventToJson(SseErrorEvent instance) =>
    <String, dynamic>{
      'codice': instance.codice,
      'messaggio': instance.messaggio,
    };

AchievementEvent _$AchievementEventFromJson(Map<String, dynamic> json) =>
    AchievementEvent(
      id: json['id'] as String,
      nome: json['nome'] as String,
      tipo: json['tipo'] as String,
    );

Map<String, dynamic> _$AchievementEventToJson(AchievementEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'tipo': instance.tipo,
    };
