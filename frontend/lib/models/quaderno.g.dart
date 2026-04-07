// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quaderno.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatoNodoQuaderno _$StatoNodoQuadernoFromJson(Map<String, dynamic> json) =>
    StatoNodoQuaderno(
      livello: json['livello'] as String? ?? 'non_iniziato',
      presunto: json['presunto'] as bool? ?? false,
      spiegazioneData: json['spiegazione_data'] as bool? ?? false,
      eserciziCompletati: (json['esercizi_completati'] as num?)?.toInt() ?? 0,
      srProssimoRipasso: json['sr_prossimo_ripasso'] as String?,
      srRipetizioni: (json['sr_ripetizioni'] as num?)?.toInt() ?? 0,
      ultimaInterazione: json['ultima_interazione'] as String?,
    );

Map<String, dynamic> _$StatoNodoQuadernoToJson(StatoNodoQuaderno instance) =>
    <String, dynamic>{
      'livello': instance.livello,
      'presunto': instance.presunto,
      'spiegazione_data': instance.spiegazioneData,
      'esercizi_completati': instance.eserciziCompletati,
      'sr_prossimo_ripasso': instance.srProssimoRipasso,
      'sr_ripetizioni': instance.srRipetizioni,
      'ultima_interazione': instance.ultimaInterazione,
    };

EsercizioQuaderno _$EsercizioQuadernoFromJson(Map<String, dynamic> json) =>
    EsercizioQuaderno(
      id: (json['id'] as num).toInt(),
      esercizioId: json['esercizio_id'] as String?,
      esito: json['esito'] as String,
      testo: json['testo'] as String?,
      tipo: json['tipo'] as String?,
      difficolta: (json['difficolta'] as num?)?.toInt(),
      data: json['data'] as String?,
    );

Map<String, dynamic> _$EsercizioQuadernoToJson(EsercizioQuaderno instance) =>
    <String, dynamic>{
      'id': instance.id,
      'esercizio_id': instance.esercizioId,
      'esito': instance.esito,
      'testo': instance.testo,
      'tipo': instance.tipo,
      'difficolta': instance.difficolta,
      'data': instance.data,
    };

FormulaQuaderno _$FormulaQuadernoFromJson(Map<String, dynamic> json) =>
    FormulaQuaderno(
      titolo: json['titolo'] as String,
      formula: json['formula'] as String,
      spiegazione: json['spiegazione'] as String? ?? '',
      data: json['data'] as String?,
    );

Map<String, dynamic> _$FormulaQuadernoToJson(FormulaQuaderno instance) =>
    <String, dynamic>{
      'titolo': instance.titolo,
      'formula': instance.formula,
      'spiegazione': instance.spiegazione,
      'data': instance.data,
    };

SpiegazioneQuaderno _$SpiegazioneQuadernoFromJson(Map<String, dynamic> json) =>
    SpiegazioneQuaderno(
      contenuto: json['contenuto'] as String,
      sessioneId: json['sessione_id'] as String,
      data: json['data'] as String?,
    );

Map<String, dynamic> _$SpiegazioneQuadernoToJson(
  SpiegazioneQuaderno instance,
) => <String, dynamic>{
  'contenuto': instance.contenuto,
  'sessione_id': instance.sessioneId,
  'data': instance.data,
};

FormulaCurriculum _$FormulaCurriculumFromJson(Map<String, dynamic> json) =>
    FormulaCurriculum(
      latex: json['latex'] as String,
      descrizione: json['descrizione'] as String? ?? '',
    );

Map<String, dynamic> _$FormulaCurriculumToJson(FormulaCurriculum instance) =>
    <String, dynamic>{
      'latex': instance.latex,
      'descrizione': instance.descrizione,
    };

ErroreComune _$ErroreComuneFromJson(Map<String, dynamic> json) => ErroreComune(
  tipo: json['tipo'] as String,
  descrizione: json['descrizione'] as String,
  esempioSbagliato: json['esempio_sbagliato'] as String?,
  correzione: json['correzione'] as String?,
  suggerimento: json['suggerimento'] as String?,
);

Map<String, dynamic> _$ErroreComuneToJson(ErroreComune instance) =>
    <String, dynamic>{
      'tipo': instance.tipo,
      'descrizione': instance.descrizione,
      'esempio_sbagliato': instance.esempioSbagliato,
      'correzione': instance.correzione,
      'suggerimento': instance.suggerimento,
    };

SchedaNodo _$SchedaNodoFromJson(Map<String, dynamic> json) => SchedaNodo(
  definizioneTesto: json['definizione_testo'] as String?,
  formule:
      (json['formule'] as List<dynamic>?)
          ?.map((e) => FormulaCurriculum.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  esempi:
      (json['esempi'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  erroriComuni:
      (json['errori_comuni'] as List<dynamic>?)
          ?.map((e) => ErroreComune.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  paroleChiave:
      (json['parole_chiave'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$SchedaNodoToJson(SchedaNodo instance) =>
    <String, dynamic>{
      'definizione_testo': instance.definizioneTesto,
      'formule': instance.formule,
      'esempi': instance.esempi,
      'errori_comuni': instance.erroriComuni,
      'parole_chiave': instance.paroleChiave,
    };

NotaUtente _$NotaUtenteFromJson(Map<String, dynamic> json) => NotaUtente(
  testo: json['testo'] as String,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$NotaUtenteToJson(NotaUtente instance) =>
    <String, dynamic>{
      'testo': instance.testo,
      'updated_at': instance.updatedAt,
    };

QuadernoNodo _$QuadernoNodoFromJson(Map<String, dynamic> json) => QuadernoNodo(
  nodoId: json['nodo_id'] as String,
  nodoNome: json['nodo_nome'] as String,
  temaNome: json['tema_nome'] as String?,
  stato: StatoNodoQuaderno.fromJson(json['stato'] as Map<String, dynamic>),
  sessioniCount: (json['sessioni_count'] as num?)?.toInt() ?? 0,
  esercizi:
      (json['esercizi'] as List<dynamic>?)
          ?.map((e) => EsercizioQuaderno.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  formule:
      (json['formule'] as List<dynamic>?)
          ?.map((e) => FormulaQuaderno.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  spiegazioni:
      (json['spiegazioni'] as List<dynamic>?)
          ?.map((e) => SpiegazioneQuaderno.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  scheda: json['scheda'] == null
      ? null
      : SchedaNodo.fromJson(json['scheda'] as Map<String, dynamic>),
  notaUtente: json['nota_utente'] == null
      ? null
      : NotaUtente.fromJson(json['nota_utente'] as Map<String, dynamic>),
);

Map<String, dynamic> _$QuadernoNodoToJson(QuadernoNodo instance) =>
    <String, dynamic>{
      'nodo_id': instance.nodoId,
      'nodo_nome': instance.nodoNome,
      'tema_nome': instance.temaNome,
      'stato': instance.stato,
      'sessioni_count': instance.sessioniCount,
      'esercizi': instance.esercizi,
      'formule': instance.formule,
      'spiegazioni': instance.spiegazioni,
      'scheda': instance.scheda,
      'nota_utente': instance.notaUtente,
    };
