// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'percorso.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Percorso _$PercorsoFromJson(Map<String, dynamic> json) => Percorso(
  id: (json['id'] as num).toInt(),
  tipo: json['tipo'] as String,
  materia: json['materia'] as String,
  nome: json['nome'] as String?,
  stato: json['stato'] as String? ?? 'attivo',
  nodoInizialeOverride: json['nodo_iniziale_override'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$PercorsoToJson(Percorso instance) => <String, dynamic>{
  'id': instance.id,
  'tipo': instance.tipo,
  'materia': instance.materia,
  'nome': instance.nome,
  'stato': instance.stato,
  'nodo_iniziale_override': instance.nodoInizialeOverride,
  'created_at': instance.createdAt,
};

MappaPercorso _$MappaPercorsoFromJson(Map<String, dynamic> json) =>
    MappaPercorso(
      percorsoId: (json['percorso_id'] as num).toInt(),
      materia: json['materia'] as String,
      nodoInizialeOverride: json['nodo_iniziale_override'] as String?,
      nodi: (json['nodi'] as List<dynamic>)
          .map((e) => NodoMappa.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MappaPercorsoToJson(MappaPercorso instance) =>
    <String, dynamic>{
      'percorso_id': instance.percorsoId,
      'materia': instance.materia,
      'nodo_iniziale_override': instance.nodoInizialeOverride,
      'nodi': instance.nodi,
    };

NodoMappa _$NodoMappaFromJson(Map<String, dynamic> json) => NodoMappa(
  id: json['id'] as String,
  nome: json['nome'] as String,
  tipo: json['tipo'] as String,
  temaId: json['tema_id'] as String?,
  livello: json['livello'] as String,
  presunto: json['presunto'] as bool? ?? false,
  spiegazioneData: json['spiegazione_data'] as bool? ?? false,
  eserciziCompletati: (json['esercizi_completati'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$NodoMappaToJson(NodoMappa instance) => <String, dynamic>{
  'id': instance.id,
  'nome': instance.nome,
  'tipo': instance.tipo,
  'tema_id': instance.temaId,
  'livello': instance.livello,
  'presunto': instance.presunto,
  'spiegazione_data': instance.spiegazioneData,
  'esercizi_completati': instance.eserciziCompletati,
};
