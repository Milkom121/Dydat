// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Achievement _$AchievementFromJson(Map<String, dynamic> json) => Achievement(
  id: json['id'] as String,
  nome: json['nome'] as String,
  tipo: json['tipo'] as String,
  descrizione: json['descrizione'] as String?,
  sbloccatoAt: json['sbloccato_at'] as String?,
);

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'tipo': instance.tipo,
      'descrizione': instance.descrizione,
      'sbloccato_at': instance.sbloccatoAt,
    };

AchievementProssimo _$AchievementProssimoFromJson(Map<String, dynamic> json) =>
    AchievementProssimo(
      id: json['id'] as String,
      nome: json['nome'] as String,
      tipo: json['tipo'] as String,
      descrizione: json['descrizione'] as String?,
      condizione: AchievementCondizione.fromJson(
        json['condizione'] as Map<String, dynamic>,
      ),
      progresso: AchievementProgresso.fromJson(
        json['progresso'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$AchievementProssimoToJson(
  AchievementProssimo instance,
) => <String, dynamic>{
  'id': instance.id,
  'nome': instance.nome,
  'tipo': instance.tipo,
  'descrizione': instance.descrizione,
  'condizione': instance.condizione,
  'progresso': instance.progresso,
};

AchievementCondizione _$AchievementCondizioneFromJson(
  Map<String, dynamic> json,
) => AchievementCondizione(
  tipo: json['tipo'] as String,
  valore: (json['valore'] as num).toInt(),
);

Map<String, dynamic> _$AchievementCondizioneToJson(
  AchievementCondizione instance,
) => <String, dynamic>{'tipo': instance.tipo, 'valore': instance.valore};

AchievementProgresso _$AchievementProgressoFromJson(
  Map<String, dynamic> json,
) => AchievementProgresso(
  corrente: (json['corrente'] as num).toInt(),
  richiesto: (json['richiesto'] as num).toInt(),
);

Map<String, dynamic> _$AchievementProgressoToJson(
  AchievementProgresso instance,
) => <String, dynamic>{
  'corrente': instance.corrente,
  'richiesto': instance.richiesto,
};

AchievementResponse _$AchievementResponseFromJson(Map<String, dynamic> json) =>
    AchievementResponse(
      sbloccati: (json['sbloccati'] as List<dynamic>)
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
      prossimi: (json['prossimi'] as List<dynamic>)
          .map((e) => AchievementProssimo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AchievementResponseToJson(
  AchievementResponse instance,
) => <String, dynamic>{
  'sbloccati': instance.sbloccati,
  'prossimi': instance.prossimi,
};
