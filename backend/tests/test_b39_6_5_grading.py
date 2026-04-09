"""Test B39.6.5 — Logica grading deterministico.

Verifica valuta_risposta:
- Risposta corretta → corretto=True, nessun concetto retrocesso
- Risposta sbagliata → corretto=False, tutti i concetti retrocessi
- Case insensitive (maiuscole/minuscole)
- Spazi extra nella risposta
- Esercizio singolo (1 concetto) → 1 concetto retrocesso
- Esercizio compound (2 concetti) → 2 concetti retrocessi
- Spiegazione breve riportata nell'esito
- Schema EsitoVerifica
"""

from app.core.onboarding import valuta_risposta
from app.schemas.onboarding import (
    EsercizioCompound,
    EsitoVerifica,
    OpzioneEsercizio,
)

# --- Fixture helper ---

def _esercizio_compound(
    risposta_corretta: str = "B",
    concetti: list[str] | None = None,
    spiegazione: str = "Perché 2+2=4",
) -> EsercizioCompound:
    """Helper per creare un esercizio compound di test."""
    return EsercizioCompound(
        testo="Quanto fa 2+2?",
        concetti=concetti or ["algebra_base", "aritmetica"],
        opzioni=[
            OpzioneEsercizio(lettera="A", testo="3"),
            OpzioneEsercizio(lettera="B", testo="4"),
            OpzioneEsercizio(lettera="C", testo="5"),
        ],
        risposta_corretta=risposta_corretta,
        spiegazione_breve=spiegazione,
    )


def _esercizio_singolo() -> EsercizioCompound:
    """Esercizio con 1 solo concetto."""
    return EsercizioCompound(
        testo="Risolvi x+1=3",
        concetti=["equazioni_primo_grado"],
        opzioni=[
            OpzioneEsercizio(lettera="A", testo="x=1"),
            OpzioneEsercizio(lettera="B", testo="x=2"),
            OpzioneEsercizio(lettera="C", testo="x=3"),
        ],
        risposta_corretta="B",
        spiegazione_breve="x=3-1=2",
    )


# --- Test schema EsitoVerifica ---

class TestEsitoVerificaSchema:
    """Test del modello Pydantic EsitoVerifica."""

    def test_esito_corretto_default(self):
        esito = EsitoVerifica(corretto=True)
        assert esito.corretto is True
        assert esito.concetti_retrocessi == []
        assert esito.spiegazione_breve == ""

    def test_esito_sbagliato_con_concetti(self):
        esito = EsitoVerifica(
            corretto=False,
            concetti_retrocessi=["algebra", "aritmetica"],
            spiegazione_breve="Rivedi le basi",
        )
        assert esito.corretto is False
        assert len(esito.concetti_retrocessi) == 2
        assert esito.spiegazione_breve == "Rivedi le basi"

    def test_serializzazione_json(self):
        esito = EsitoVerifica(
            corretto=False,
            concetti_retrocessi=["x"],
        )
        data = esito.model_dump()
        assert data["corretto"] is False
        assert data["concetti_retrocessi"] == ["x"]

    def test_deserializzazione(self):
        data = {
            "corretto": True,
            "concetti_retrocessi": [],
            "spiegazione_breve": "ok",
        }
        esito = EsitoVerifica.model_validate(data)
        assert esito.corretto is True


# --- Test valuta_risposta: risposte corrette ---

class TestValutaRispostaCorretta:
    """Verifica che risposte corrette producano esito positivo."""

    def test_risposta_corretta_esatta(self):
        ex = _esercizio_compound(risposta_corretta="B")
        esito = valuta_risposta(ex, "B")
        assert esito.corretto is True
        assert esito.concetti_retrocessi == []

    def test_risposta_corretta_minuscola(self):
        """Case insensitive: 'b' deve matchare 'B'."""
        ex = _esercizio_compound(risposta_corretta="B")
        esito = valuta_risposta(ex, "b")
        assert esito.corretto is True

    def test_risposta_corretta_con_spazi(self):
        """Spazi extra vengono trimmed."""
        ex = _esercizio_compound(risposta_corretta="A")
        esito = valuta_risposta(ex, "  A  ")
        assert esito.corretto is True

    def test_risposta_corretta_spiegazione(self):
        """La spiegazione_breve dell'esercizio viene riportata."""
        spiegazione = "La risposta è ovvia"
        ex = _esercizio_compound(spiegazione=spiegazione)
        esito = valuta_risposta(ex, "B")
        assert esito.spiegazione_breve == spiegazione

    def test_risposta_corretta_nessun_concetto_retrocesso(self):
        """Nessun concetto viene retrocesso se la risposta è corretta."""
        ex = _esercizio_compound(concetti=["a", "b", "c"])
        # Nota: il validatore limita concetti a quelli dell'esercizio,
        # ma il grading non li tocca se corretto
        esito = valuta_risposta(ex, "B")
        assert len(esito.concetti_retrocessi) == 0


# --- Test valuta_risposta: risposte sbagliate ---

class TestValutaRispostaSbagliata:
    """Verifica che risposte sbagliate retrocedano tutti i concetti."""

    def test_risposta_sbagliata_compound(self):
        """Compound sbagliato → entrambi i concetti retrocessi (Decisione 8)."""
        ex = _esercizio_compound(
            risposta_corretta="B",
            concetti=["algebra_base", "aritmetica"],
        )
        esito = valuta_risposta(ex, "A")
        assert esito.corretto is False
        assert set(esito.concetti_retrocessi) == {"algebra_base", "aritmetica"}

    def test_risposta_sbagliata_singolo(self):
        """Esercizio singolo sbagliato → 1 concetto retrocesso."""
        ex = _esercizio_singolo()
        esito = valuta_risposta(ex, "C")
        assert esito.corretto is False
        assert esito.concetti_retrocessi == ["equazioni_primo_grado"]

    def test_risposta_sbagliata_spiegazione(self):
        """La spiegazione viene comunque riportata anche se sbagliato."""
        ex = _esercizio_compound(spiegazione="Ecco perché")
        esito = valuta_risposta(ex, "C")
        assert esito.spiegazione_breve == "Ecco perché"

    def test_risposta_sbagliata_case_insensitive(self):
        """Anche sbagliata minuscola → retrocesso."""
        ex = _esercizio_compound(risposta_corretta="B")
        esito = valuta_risposta(ex, "c")
        assert esito.corretto is False
        assert len(esito.concetti_retrocessi) == 2

    def test_risposta_lettera_non_esistente(self):
        """Lettera non tra le opzioni → sbagliato (non crash)."""
        ex = _esercizio_compound(risposta_corretta="B")
        esito = valuta_risposta(ex, "Z")
        assert esito.corretto is False
        assert len(esito.concetti_retrocessi) == 2

    def test_risposta_vuota(self):
        """Stringa vuota → sbagliato."""
        ex = _esercizio_compound(risposta_corretta="B")
        esito = valuta_risposta(ex, "")
        assert esito.corretto is False

    def test_risposta_spazi_solo(self):
        """Solo spazi → sbagliato (trim produce stringa vuota)."""
        ex = _esercizio_compound(risposta_corretta="B")
        esito = valuta_risposta(ex, "   ")
        assert esito.corretto is False


# --- Test edge case ---

class TestValutaRispostaEdge:
    """Edge case per robustezza."""

    def test_risposta_corretta_minuscola_esercizio(self):
        """Se la risposta corretta dell'esercizio è minuscola."""
        ex = EsercizioCompound(
            testo="Test",
            concetti=["c1"],
            opzioni=[
                OpzioneEsercizio(lettera="a", testo="opt1"),
                OpzioneEsercizio(lettera="b", testo="opt2"),
            ],
            risposta_corretta="a",
            spiegazione_breve="",
        )
        # Utente risponde maiuscola
        esito = valuta_risposta(ex, "A")
        assert esito.corretto is True

    def test_concetti_preservati_nell_ordine(self):
        """I concetti retrocessi mantengono l'ordine dell'esercizio."""
        ex = _esercizio_compound(concetti=["z_ultimo", "a_primo"])
        esito = valuta_risposta(ex, "A")  # sbagliato (corretta=B)
        assert esito.concetti_retrocessi == ["z_ultimo", "a_primo"]

    def test_esercizio_senza_spiegazione(self):
        """Spiegazione vuota → esito con stringa vuota."""
        ex = _esercizio_compound(spiegazione="")
        esito = valuta_risposta(ex, "B")
        assert esito.spiegazione_breve == ""

    def test_tipo_ritorno_esito_verifica(self):
        """Il tipo di ritorno è EsitoVerifica."""
        ex = _esercizio_compound()
        esito = valuta_risposta(ex, "B")
        assert isinstance(esito, EsitoVerifica)
