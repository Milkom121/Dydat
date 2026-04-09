"""Schemas Pydantic v2 per onboarding."""

import uuid
from enum import Enum
from typing import Literal

from pydantic import BaseModel, model_validator

# --- Schemi estrattore profilo (B39.2.2) ---

class CampoConConfidenza(BaseModel):
    """Singolo campo del profilo con valore e livello di confidenza.

    L'estrattore LLM produce un valore + confidenza per ogni campo.
    Confidenza bassa = campo trattato come mancante dal decisore forma C.
    """

    valore: str | None = None
    confidenza: Literal["alta", "media", "bassa"]

    @model_validator(mode="after")
    def _valore_nullo_implica_bassa(self) -> "CampoConConfidenza":
        """Se valore è None, la confidenza deve essere 'bassa'."""
        if self.valore is None and self.confidenza != "bassa":
            raise ValueError(
                "Se il valore è None, la confidenza deve essere 'bassa'"
            )
        return self


class ProfiloEstratto(BaseModel):
    """Output dell'estrattore profilo onboarding.

    Contiene i 5 campi del profilo (vedi Decisione 2 in
    docs/discussions/b39-onboarding-narrativo.md) ciascuno con valore e confidenza.
    Tutti i campi sono sempre presenti nell'output, anche se il valore è None.
    """

    chi_e: CampoConConfidenza
    motivo: CampoConConfidenza
    stile_cognitivo: CampoConConfidenza
    tempo_disponibile: CampoConConfidenza
    vissuto_scolastico: CampoConConfidenza

    def campi_completi(self) -> list[str]:
        """Restituisce i nomi dei campi con confidenza alta o media."""
        return [
            nome
            for nome in ("chi_e", "motivo", "stile_cognitivo",
                         "tempo_disponibile", "vissuto_scolastico")
            if getattr(self, nome).confidenza in ("alta", "media")
        ]

    def campi_mancanti(self) -> list[str]:
        """Restituisce i nomi dei campi con confidenza bassa (= mancanti)."""
        return [
            nome
            for nome in ("chi_e", "motivo", "stile_cognitivo",
                         "tempo_disponibile", "vissuto_scolastico")
            if getattr(self, nome).confidenza == "bassa"
        ]

    def is_completo(self) -> bool:
        """True se tutti i 5 campi hanno confidenza alta o media."""
        return len(self.campi_mancanti()) == 0


# --- Schema decisore forma C (B39.3.1) ---

class AzioneDecisore(str, Enum):
    """Azioni possibili del decisore onboarding forma C."""

    chiedi_campo_mancante = "chiedi_campo_mancante"
    chiudi_narrativa = "chiudi_narrativa"
    forza_chiusura_tetto_turni = "forza_chiusura_tetto_turni"


class Decisione(BaseModel):
    """Output del decisore forma C: prossima mossa del tutor onboarding.

    Prodotta da `decidi_prossima_mossa()`, funzione pura senza LLM.
    """

    azione: AzioneDecisore
    campo_da_chiedere: str | None = None
    motivo: str


# --- Schemi endpoint onboarding ---

class OnboardingIniziaResponse(BaseModel):
    utente_temp_id: uuid.UUID
    sessione_id: uuid.UUID


class OnboardingTurnoRequest(BaseModel):
    sessione_id: uuid.UUID
    messaggio: str


class OnboardingCompletaRequest(BaseModel):
    sessione_id: uuid.UUID
    contesto_personale: dict | None = None
    preferenze_tutor: dict | None = None


class OpzioneEsercizio(BaseModel):
    """Singola opzione di un esercizio a scelta multipla."""

    lettera: str
    testo: str


class EsercizioCompound(BaseModel):
    """Esercizio compound generato per il placement onboarding.

    Copre 1-2 concetti. Generato da Opus con il prompt di B39.6.3.
    """

    testo: str
    concetti: list[str]
    opzioni: list[OpzioneEsercizio]
    risposta_corretta: str
    spiegazione_breve: str = ""

    @model_validator(mode="after")
    def _valida_risposta(self) -> "EsercizioCompound":
        """Verifica che risposta_corretta sia tra le lettere delle opzioni."""
        lettere = {o.lettera for o in self.opzioni}
        if self.risposta_corretta not in lettere:
            raise ValueError(
                f"risposta_corretta '{self.risposta_corretta}' "
                f"non presente tra le opzioni: {lettere}"
            )
        return self


class OnboardingCompletaResponse(BaseModel):
    percorso_id: int
    nodo_iniziale: str | None = None
    nodi_inizializzati: int
