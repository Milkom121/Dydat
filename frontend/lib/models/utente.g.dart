// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utente.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Utente _$UtenteFromJson(Map<String, dynamic> json) => Utente(
  id: json['id'] as String,
  email: json['email'] as String?,
  nome: json['nome'] as String?,
  preferenzeTutor: json['preferenze_tutor'] as Map<String, dynamic>?,
  contestoPersonale: json['contesto_personale'] as Map<String, dynamic>?,
  materieAttive: (json['materie_attive'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  obiettvoGiornalieroMin:
      (json['obiettivo_giornaliero_min'] as num?)?.toInt() ?? 20,
);

Map<String, dynamic> _$UtenteToJson(Utente instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'nome': instance.nome,
  'preferenze_tutor': instance.preferenzeTutor,
  'contesto_personale': instance.contestoPersonale,
  'materie_attive': instance.materieAttive,
  'obiettivo_giornaliero_min': instance.obiettvoGiornalieroMin,
};

PreferenzeStudio _$PreferenzeStudioFromJson(Map<String, dynamic> json) =>
    PreferenzeStudio(
      input: json['input'] as String?,
      velocita: json['velocita'] as String?,
      incoraggiamento: json['incoraggiamento'] as String?,
    );

Map<String, dynamic> _$PreferenzeStudioToJson(PreferenzeStudio instance) =>
    <String, dynamic>{
      'input': instance.input,
      'velocita': instance.velocita,
      'incoraggiamento': instance.incoraggiamento,
    };

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
    };

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      nome: json['nome'] as String,
      utenteTempId: json['utente_temp_id'] as String?,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'nome': instance.nome,
      'utente_temp_id': instance.utenteTempId,
    };
