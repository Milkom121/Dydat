// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistiche.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PeriodoStats _$PeriodoStatsFromJson(Map<String, dynamic> json) => PeriodoStats(
  minutiStudio: (json['minuti_studio'] as num?)?.toInt() ?? 0,
  eserciziSvolti: (json['esercizi_svolti'] as num?)?.toInt() ?? 0,
  eserciziCorretti: (json['esercizi_corretti'] as num?)?.toInt() ?? 0,
  nodiCompletati: (json['nodi_completati'] as num?)?.toInt() ?? 0,
  giorniAttivi: (json['giorni_attivi'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PeriodoStatsToJson(PeriodoStats instance) =>
    <String, dynamic>{
      'minuti_studio': instance.minutiStudio,
      'esercizi_svolti': instance.eserciziSvolti,
      'esercizi_corretti': instance.eserciziCorretti,
      'nodi_completati': instance.nodiCompletati,
      'giorni_attivi': instance.giorniAttivi,
    };

StatisticheUtente _$StatisticheUtenteFromJson(Map<String, dynamic> json) =>
    StatisticheUtente(
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      nodiCompletati: (json['nodi_completati'] as num?)?.toInt() ?? 0,
      sessioniCompletate: (json['sessioni_completate'] as num?)?.toInt() ?? 0,
      settimana: PeriodoStats.fromJson(
        json['settimana'] as Map<String, dynamic>,
      ),
      mese: PeriodoStats.fromJson(json['mese'] as Map<String, dynamic>),
      sempre: PeriodoStats.fromJson(json['sempre'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StatisticheUtenteToJson(StatisticheUtente instance) =>
    <String, dynamic>{
      'streak': instance.streak,
      'nodi_completati': instance.nodiCompletati,
      'sessioni_completate': instance.sessioniCompletate,
      'settimana': instance.settimana,
      'mese': instance.mese,
      'sempre': instance.sempre,
    };
