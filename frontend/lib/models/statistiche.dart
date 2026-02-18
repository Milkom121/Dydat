import 'package:json_annotation/json_annotation.dart';

part 'statistiche.g.dart';

@JsonSerializable()
class PeriodoStats {
  @JsonKey(name: 'minuti_studio')
  final int minutiStudio;
  @JsonKey(name: 'esercizi_svolti')
  final int eserciziSvolti;
  @JsonKey(name: 'esercizi_corretti')
  final int eserciziCorretti;
  @JsonKey(name: 'nodi_completati')
  final int nodiCompletati;
  @JsonKey(name: 'giorni_attivi')
  final int giorniAttivi;

  const PeriodoStats({
    this.minutiStudio = 0,
    this.eserciziSvolti = 0,
    this.eserciziCorretti = 0,
    this.nodiCompletati = 0,
    this.giorniAttivi = 0,
  });

  factory PeriodoStats.fromJson(Map<String, dynamic> json) =>
      _$PeriodoStatsFromJson(json);
  Map<String, dynamic> toJson() => _$PeriodoStatsToJson(this);
}

@JsonSerializable()
class StatisticheUtente {
  final int streak;
  @JsonKey(name: 'nodi_completati')
  final int nodiCompletati;
  @JsonKey(name: 'sessioni_completate')
  final int sessioniCompletate;
  final PeriodoStats settimana;
  final PeriodoStats mese;
  final PeriodoStats sempre;

  const StatisticheUtente({
    this.streak = 0,
    this.nodiCompletati = 0,
    this.sessioniCompletate = 0,
    required this.settimana,
    required this.mese,
    required this.sempre,
  });

  factory StatisticheUtente.fromJson(Map<String, dynamic> json) =>
      _$StatisticheUtenteFromJson(json);
  Map<String, dynamic> toJson() => _$StatisticheUtenteToJson(this);
}
