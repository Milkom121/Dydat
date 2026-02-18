import 'package:json_annotation/json_annotation.dart';

part 'achievement.g.dart';

@JsonSerializable()
class Achievement {
  final String id;
  final String nome;
  final String tipo;
  final String? descrizione;
  @JsonKey(name: 'sbloccato_at')
  final String? sbloccatoAt;

  const Achievement({
    required this.id,
    required this.nome,
    required this.tipo,
    this.descrizione,
    this.sbloccatoAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementToJson(this);
}

@JsonSerializable()
class AchievementProssimo {
  final String id;
  final String nome;
  final String tipo;
  final String? descrizione;
  final AchievementCondizione condizione;
  final AchievementProgresso progresso;

  const AchievementProssimo({
    required this.id,
    required this.nome,
    required this.tipo,
    this.descrizione,
    required this.condizione,
    required this.progresso,
  });

  factory AchievementProssimo.fromJson(Map<String, dynamic> json) =>
      _$AchievementProssimoFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementProssimoToJson(this);
}

@JsonSerializable()
class AchievementCondizione {
  final String tipo;
  final int valore;

  const AchievementCondizione({required this.tipo, required this.valore});

  factory AchievementCondizione.fromJson(Map<String, dynamic> json) =>
      _$AchievementCondizioneFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementCondizioneToJson(this);
}

@JsonSerializable()
class AchievementProgresso {
  final int corrente;
  final int richiesto;

  const AchievementProgresso({required this.corrente, required this.richiesto});

  factory AchievementProgresso.fromJson(Map<String, dynamic> json) =>
      _$AchievementProgressoFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementProgressoToJson(this);
}

@JsonSerializable()
class AchievementResponse {
  final List<Achievement> sbloccati;
  final List<AchievementProssimo> prossimi;

  const AchievementResponse({
    required this.sbloccati,
    required this.prossimi,
  });

  factory AchievementResponse.fromJson(Map<String, dynamic> json) =>
      _$AchievementResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementResponseToJson(this);
}
