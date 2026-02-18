import 'package:json_annotation/json_annotation.dart';

part 'utente.g.dart';

@JsonSerializable()
class Utente {
  final String id;
  final String? email;
  final String? nome;
  @JsonKey(name: 'preferenze_tutor')
  final Map<String, dynamic>? preferenzeTutor;
  @JsonKey(name: 'contesto_personale')
  final Map<String, dynamic>? contestoPersonale;
  @JsonKey(name: 'materie_attive')
  final List<String>? materieAttive;
  @JsonKey(name: 'obiettivo_giornaliero_min')
  final int obiettvoGiornalieroMin;

  const Utente({
    required this.id,
    this.email,
    this.nome,
    this.preferenzeTutor,
    this.contestoPersonale,
    this.materieAttive,
    this.obiettvoGiornalieroMin = 20,
  });

  factory Utente.fromJson(Map<String, dynamic> json) => _$UtenteFromJson(json);
  Map<String, dynamic> toJson() => _$UtenteToJson(this);
}

@JsonSerializable()
class PreferenzeStudio {
  final String? input;
  final String? velocita;
  final String? incoraggiamento;

  const PreferenzeStudio({
    this.input,
    this.velocita,
    this.incoraggiamento,
  });

  factory PreferenzeStudio.fromJson(Map<String, dynamic> json) =>
      _$PreferenzeStudioFromJson(json);
  Map<String, dynamic> toJson() => _$PreferenzeStudioToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String tokenType;

  const LoginResponse({required this.accessToken, required this.tokenType});

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String password;
  final String nome;
  @JsonKey(name: 'utente_temp_id')
  final String? utenteTempId;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.nome,
    this.utenteTempId,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}
