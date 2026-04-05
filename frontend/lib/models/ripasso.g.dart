// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ripasso.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodoRipasso _$NodoRipassoFromJson(Map<String, dynamic> json) => NodoRipasso(
  nodoId: json['nodo_id'] as String,
  nodoNome: json['nodo_nome'] as String,
  temaId: json['tema_id'] as String,
  temaNome: json['tema_nome'] as String,
  srProssimoRipasso: json['sr_prossimo_ripasso'] as String?,
  srRipetizioni: (json['sr_ripetizioni'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$NodoRipassoToJson(NodoRipasso instance) =>
    <String, dynamic>{
      'nodo_id': instance.nodoId,
      'nodo_nome': instance.nodoNome,
      'tema_id': instance.temaId,
      'tema_nome': instance.temaNome,
      'sr_prossimo_ripasso': instance.srProssimoRipasso,
      'sr_ripetizioni': instance.srRipetizioni,
    };
