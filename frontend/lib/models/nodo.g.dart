// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nodo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Nodo _$NodoFromJson(Map<String, dynamic> json) => Nodo(
  id: json['id'] as String,
  nome: json['nome'] as String,
  materia: json['materia'] as String,
  tipo: json['tipo'] as String? ?? 'standard',
  tipoNodo: json['tipo_nodo'] as String? ?? 'operativo',
);

Map<String, dynamic> _$NodoToJson(Nodo instance) => <String, dynamic>{
  'id': instance.id,
  'nome': instance.nome,
  'materia': instance.materia,
  'tipo': instance.tipo,
  'tipo_nodo': instance.tipoNodo,
};

StatoNodoUtente _$StatoNodoUtenteFromJson(Map<String, dynamic> json) =>
    StatoNodoUtente(
      utenteId: json['utente_id'] as String,
      nodoId: json['nodo_id'] as String,
      livello: json['livello'] as String? ?? 'non_iniziato',
      presunto: json['presunto'] as bool? ?? false,
      spiegazioneData: json['spiegazione_data'] as bool? ?? false,
      eserciziCompletati: (json['esercizi_completati'] as num?)?.toInt() ?? 0,
      erroriInCorso: (json['errori_in_corso'] as num?)?.toInt() ?? 0,
      eserciziConsecutiviOk: (json['esercizi_consecutivi_ok'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StatoNodoUtenteToJson(StatoNodoUtente instance) =>
    <String, dynamic>{
      'utente_id': instance.utenteId,
      'nodo_id': instance.nodoId,
      'livello': instance.livello,
      'presunto': instance.presunto,
      'spiegazione_data': instance.spiegazioneData,
      'esercizi_completati': instance.eserciziCompletati,
      'errori_in_corso': instance.erroriInCorso,
      'esercizi_consecutivi_ok': instance.eserciziConsecutiviOk,
    };
