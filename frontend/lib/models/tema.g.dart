// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tema _$TemaFromJson(Map<String, dynamic> json) => Tema(
  id: json['id'] as String,
  nome: json['nome'] as String,
  materia: json['materia'] as String,
  descrizione: json['descrizione'] as String?,
  nodiTotali: (json['nodi_totali'] as num?)?.toInt() ?? 0,
  nodiCompletati: (json['nodi_completati'] as num?)?.toInt() ?? 0,
  completato: json['completato'] as bool? ?? false,
);

Map<String, dynamic> _$TemaToJson(Tema instance) => <String, dynamic>{
  'id': instance.id,
  'nome': instance.nome,
  'materia': instance.materia,
  'descrizione': instance.descrizione,
  'nodi_totali': instance.nodiTotali,
  'nodi_completati': instance.nodiCompletati,
  'completato': instance.completato,
};

TemaDettaglio _$TemaDettaglioFromJson(Map<String, dynamic> json) =>
    TemaDettaglio(
      id: json['id'] as String,
      nome: json['nome'] as String,
      materia: json['materia'] as String,
      descrizione: json['descrizione'] as String?,
      nodiTotali: (json['nodi_totali'] as num?)?.toInt() ?? 0,
      nodiCompletati: (json['nodi_completati'] as num?)?.toInt() ?? 0,
      completato: json['completato'] as bool? ?? false,
      nodi: (json['nodi'] as List<dynamic>)
          .map((e) => NodoMappa.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TemaDettaglioToJson(TemaDettaglio instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'materia': instance.materia,
      'descrizione': instance.descrizione,
      'nodi_totali': instance.nodiTotali,
      'nodi_completati': instance.nodiCompletati,
      'completato': instance.completato,
      'nodi': instance.nodi,
    };
