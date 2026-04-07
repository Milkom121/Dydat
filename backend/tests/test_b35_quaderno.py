"""Test B35 — Endpoint quaderno: GET e PUT nota utente.

Testa GET /quaderno/{nodo_id}:
- Nodo inesistente ritorna 404
- Quaderno vuoto per nodo senza interazioni
- Quaderno con esercizi, formule, spiegazioni aggregati
- Formule deduplicate per titolo
- Spiegazioni filtrate per lunghezza (> 50 char)

Testa PUT /quaderno/{nodo_id}/nota (B35.5.2):
- Creazione nuova nota
- Aggiornamento nota esistente
- Nodo inesistente ritorna 404
- Validazione payload (testo vuoto, testo troppo lungo)
"""

from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from unittest.mock import AsyncMock, MagicMock

import pytest
from fastapi import HTTPException


def _mock_nodo(
    nodo_id="nodo_1",
    nome="Equazioni lineari",
    definizioni_formali=None,
    formule_proprieta=None,
    errori_comuni=None,
    esempi_applicazione=None,
    parole_chiave=None,
):
    """Helper: crea un mock Nodo."""
    nodo = MagicMock()
    nodo.id = nodo_id
    nodo.nome = nome
    nodo.definizioni_formali = definizioni_formali
    nodo.formule_proprieta = formule_proprieta
    nodo.errori_comuni = errori_comuni
    nodo.esempi_applicazione = esempi_applicazione
    nodo.parole_chiave = parole_chiave
    return nodo


def _mock_stato(
    livello="operativo",
    presunto=False,
    spiegazione_data=True,
    esercizi_completati=5,
    sr_prossimo_ripasso=None,
    sr_ripetizioni=2,
    ultima_interazione=None,
):
    """Helper: crea un mock StatoNodoUtente."""
    stato = MagicMock()
    stato.livello = livello
    stato.presunto = presunto
    stato.spiegazione_data = spiegazione_data
    stato.esercizi_completati = esercizi_completati
    stato.sr_prossimo_ripasso = sr_prossimo_ripasso
    stato.sr_ripetizioni = sr_ripetizioni
    stato.ultima_interazione = ultima_interazione
    return stato


def _mock_esercizio_row(
    row_id=1,
    esercizio_id="es_1",
    esito="corretto",
    created_at=None,
    esercizio_testo="Risolvi 2x + 3 = 7",
    esercizio_tipo="algebrico",
    esercizio_difficolta=2,
):
    """Helper: crea una riga mock dello storico esercizi."""
    row = MagicMock()
    row.id = row_id
    row.esercizio_id = esercizio_id
    row.esito = esito
    row.created_at = created_at or datetime.now(timezone.utc)
    row.esercizio_testo = esercizio_testo
    row.esercizio_tipo = esercizio_tipo
    row.esercizio_difficolta = esercizio_difficolta
    return row


def _mock_formula_row(azioni, created_at=None):
    """Helper: crea una riga mock dei turni con azioni formula."""
    row = MagicMock()
    row.azioni = azioni
    row.created_at = created_at or datetime.now(timezone.utc)
    return row


def _mock_nota_utente(contenuto="La mia nota", updated_at=None):
    """Helper: crea un mock NotaUtente."""
    nota = MagicMock()
    nota.contenuto = contenuto
    nota.updated_at = updated_at or datetime.now(timezone.utc)
    return nota


def _mock_spiegazione_row(contenuto, sessione_id=None, created_at=None):
    """Helper: crea una riga mock delle spiegazioni."""
    row = MagicMock()
    row.contenuto = contenuto
    row.sessione_id = sessione_id or uuid.uuid4()
    row.created_at = created_at or datetime.now(timezone.utc)
    return row


def _make_db_with_sequence(results):
    """Crea un AsyncMock DB che ritorna risultati diversi ad ogni execute().

    results: lista di callable(result_mock) che configurano ogni result_mock
    """
    db = AsyncMock()
    mocks = []
    for configure_fn in results:
        result_mock = MagicMock()
        configure_fn(result_mock)
        mocks.append(result_mock)
    db.execute = AsyncMock(side_effect=mocks)
    return db


class TestGetQuadernoNodo:
    """Test per GET /quaderno/{nodo_id}."""

    @pytest.mark.asyncio
    async def test_nodo_non_trovato_ritorna_404(self):
        """Se il nodo non esiste, ritorna 404."""
        from app.api.quaderno import get_quaderno_nodo

        utente = MagicMock()
        utente.id = uuid.uuid4()

        # Prima query (nodo): scalar_one_or_none = None
        db = _make_db_with_sequence([
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
        ])

        with pytest.raises(HTTPException) as exc_info:
            await get_quaderno_nodo(nodo_id="nodo_inesistente", utente=utente, db=db)
        assert exc_info.value.status_code == 404

    @pytest.mark.asyncio
    async def test_quaderno_vuoto_nodo_senza_interazioni(self):
        """Per un nodo esistente ma senza interazioni, ritorna struttura vuota."""
        from app.api.quaderno import get_quaderno_nodo

        utente = MagicMock()
        utente.id = uuid.uuid4()
        nodo = _mock_nodo()

        db = _make_db_with_sequence([
            # 1. Nodo esiste
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=nodo)),
            # 2. Tema
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value="Algebra")),
            # 3. Stato nodo utente: nessuno
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
            # 4. Esercizi: vuoti
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            # 5. Formule (turni con azioni): vuoti
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            # 6. Spiegazioni: vuote
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            # 7. Conteggio sessioni: 0
            lambda r: setattr(r, 'scalar_one', MagicMock(return_value=0)),
            # 8. Nota utente: nessuna
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
        ])

        risposta = await get_quaderno_nodo(nodo_id="nodo_1", utente=utente, db=db)

        assert risposta["nodo_id"] == "nodo_1"
        assert risposta["nodo_nome"] == "Equazioni lineari"
        assert risposta["tema_nome"] == "Algebra"
        assert risposta["stato"]["livello"] == "non_iniziato"
        assert risposta["stato"]["esercizi_completati"] == 0
        assert risposta["esercizi"] == []
        assert risposta["formule"] == []
        assert risposta["spiegazioni"] == []
        assert risposta["sessioni_count"] == 0
        # B35.5.1: scheda e nota presenti nel payload
        assert "scheda" in risposta
        assert "nota_utente" in risposta
        assert risposta["nota_utente"] is None

    @pytest.mark.asyncio
    async def test_quaderno_con_dati_completi(self):
        """Quaderno con esercizi, formule e spiegazioni aggregati."""
        from app.api.quaderno import get_quaderno_nodo

        utente = MagicMock()
        utente.id = uuid.uuid4()
        nodo = _mock_nodo()
        now = datetime.now(timezone.utc)

        stato = _mock_stato(
            livello="operativo",
            esercizi_completati=5,
            sr_ripetizioni=2,
            ultima_interazione=now - timedelta(hours=2),
        )

        esercizi = [
            _mock_esercizio_row(row_id=1, esito="corretto", created_at=now),
            _mock_esercizio_row(row_id=2, esito="errato", created_at=now - timedelta(hours=1)),
        ]

        formula_azioni = [
            {
                "tipo": "mostra_formula",
                "dati": {
                    "titolo": "Formula risolutiva",
                    "formula": "x = -b/2a",
                    "spiegazione": "Si applica quando...",
                },
            }
        ]
        formule_rows = [_mock_formula_row(azioni=formula_azioni, created_at=now)]

        spiegazioni = [
            _mock_spiegazione_row(
                "Questa e una spiegazione lunga che supera i 50 caratteri per il filtro impostato nel backend.",
                created_at=now,
            ),
        ]

        db = _make_db_with_sequence([
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=nodo)),
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value="Algebra")),
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=stato)),
            lambda r: setattr(r, 'all', MagicMock(return_value=esercizi)),
            lambda r: setattr(r, 'all', MagicMock(return_value=formule_rows)),
            lambda r: setattr(r, 'all', MagicMock(return_value=spiegazioni)),
            lambda r: setattr(r, 'scalar_one', MagicMock(return_value=3)),
            # 8. Nota utente: nessuna
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
        ])

        risposta = await get_quaderno_nodo(nodo_id="nodo_1", utente=utente, db=db)

        # Stato
        assert risposta["stato"]["livello"] == "operativo"
        assert risposta["stato"]["esercizi_completati"] == 5
        assert risposta["stato"]["sr_ripetizioni"] == 2
        assert risposta["sessioni_count"] == 3

        # Esercizi
        assert len(risposta["esercizi"]) == 2
        assert risposta["esercizi"][0]["esito"] == "corretto"
        assert risposta["esercizi"][1]["esito"] == "errato"

        # Formule
        assert len(risposta["formule"]) == 1
        assert risposta["formule"][0]["titolo"] == "Formula risolutiva"
        assert risposta["formule"][0]["formula"] == "x = -b/2a"

        # Spiegazioni
        assert len(risposta["spiegazioni"]) == 1
        assert "spiegazione lunga" in risposta["spiegazioni"][0]["contenuto"]

    @pytest.mark.asyncio
    async def test_formule_deduplicate_per_titolo(self):
        """Formule con lo stesso titolo appaiono solo una volta."""
        from app.api.quaderno import get_quaderno_nodo

        utente = MagicMock()
        utente.id = uuid.uuid4()
        nodo = _mock_nodo()
        now = datetime.now(timezone.utc)

        # Due turni con la stessa formula
        formula_azione = {
            "tipo": "mostra_formula",
            "dati": {"titolo": "Formula quadratica", "formula": "x=(-b±√Δ)/2a", "spiegazione": ""},
        }
        formule_rows = [
            _mock_formula_row(azioni=[formula_azione], created_at=now),
            _mock_formula_row(azioni=[formula_azione], created_at=now - timedelta(hours=1)),
        ]

        db = _make_db_with_sequence([
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=nodo)),
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value="Algebra")),
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            lambda r: setattr(r, 'all', MagicMock(return_value=formule_rows)),
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            lambda r: setattr(r, 'scalar_one', MagicMock(return_value=0)),
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
        ])

        risposta = await get_quaderno_nodo(nodo_id="nodo_1", utente=utente, db=db)

        # Solo una formula nonostante due turni con la stessa
        assert len(risposta["formule"]) == 1
        assert risposta["formule"][0]["titolo"] == "Formula quadratica"

    @pytest.mark.asyncio
    async def test_azioni_non_formula_ignorate(self):
        """Azioni nei turni che non sono mostra_formula vengono ignorate."""
        from app.api.quaderno import get_quaderno_nodo

        utente = MagicMock()
        utente.id = uuid.uuid4()
        nodo = _mock_nodo()
        now = datetime.now(timezone.utc)

        # Turno con azione proponi_esercizio (non formula)
        azioni_miste = [
            {"tipo": "proponi_esercizio", "dati": {"testo": "Risolvi..."}},
            {"tipo": "mostra_formula", "dati": {"titolo": "F=ma", "formula": "F=ma", "spiegazione": ""}},
        ]
        formule_rows = [_mock_formula_row(azioni=azioni_miste, created_at=now)]

        db = _make_db_with_sequence([
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=nodo)),
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            lambda r: setattr(r, 'all', MagicMock(return_value=formule_rows)),
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            lambda r: setattr(r, 'scalar_one', MagicMock(return_value=0)),
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
        ])

        risposta = await get_quaderno_nodo(nodo_id="nodo_1", utente=utente, db=db)

        # Solo la formula, non l'esercizio
        assert len(risposta["formule"]) == 1
        assert risposta["formule"][0]["titolo"] == "F=ma"

    @pytest.mark.asyncio
    async def test_stato_senza_sr(self):
        """Stato nodo senza SR ritorna valori nulli correttamente."""
        from app.api.quaderno import get_quaderno_nodo

        utente = MagicMock()
        utente.id = uuid.uuid4()
        nodo = _mock_nodo()

        stato = _mock_stato(
            livello="contesto",
            sr_prossimo_ripasso=None,
            sr_ripetizioni=None,
            ultima_interazione=None,
        )

        db = _make_db_with_sequence([
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=nodo)),
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value="Aritmetica")),
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=stato)),
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            lambda r: setattr(r, 'scalar_one', MagicMock(return_value=1)),
            # 8. Nota utente: nessuna
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
        ])

        risposta = await get_quaderno_nodo(nodo_id="nodo_1", utente=utente, db=db)

        assert risposta["stato"]["livello"] == "contesto"
        assert risposta["stato"]["sr_prossimo_ripasso"] is None
        assert risposta["stato"]["ultima_interazione"] is None
        assert risposta["sessioni_count"] == 1

    @pytest.mark.asyncio
    async def test_azioni_none_gestite(self):
        """Turni con azioni=None non causano errori."""
        from app.api.quaderno import get_quaderno_nodo

        utente = MagicMock()
        utente.id = uuid.uuid4()
        nodo = _mock_nodo()

        # Turno con azioni=None
        formule_rows = [_mock_formula_row(azioni=None)]

        db = _make_db_with_sequence([
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=nodo)),
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            lambda r: setattr(r, 'all', MagicMock(return_value=formule_rows)),
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            lambda r: setattr(r, 'scalar_one', MagicMock(return_value=0)),
            # 8. Nota utente: nessuna
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
        ])

        risposta = await get_quaderno_nodo(nodo_id="nodo_1", utente=utente, db=db)
        assert risposta["formule"] == []


class TestGetQuadernoScheda:
    """Test B35.5.1 — Scheda intrinseca e nota utente nel quaderno."""

    @pytest.mark.asyncio
    async def test_scheda_completa_tutti_i_campi(self):
        """GET con nodo che ha tutti i JSONB popolati: scheda completa nel payload."""
        from app.api.quaderno import get_quaderno_nodo

        utente = MagicMock()
        utente.id = uuid.uuid4()

        nodo = _mock_nodo(
            definizioni_formali={"testo": "Un'equazione lineare e un'uguaglianza di primo grado."},
            formule_proprieta=[
                {"latex": "ax + b = 0", "descrizione": "Forma standard"},
                {"latex": "x = -b/a", "descrizione": "Soluzione"},
            ],
            esempi_applicazione=["2x + 3 = 7 → x = 2", "5x = 15 → x = 3"],
            errori_comuni=[
                {
                    "tipo": "procedurale",
                    "descrizione": "Dimenticare di cambiare segno",
                    "esempio_sbagliato": "2x = -4 → x = 4",
                    "correzione": "x = -2",
                    "suggerimento": "Ricorda: dividendo per positivo il segno resta.",
                }
            ],
            parole_chiave=["equazione", "primo grado", "incognita"],
        )

        db = _make_db_with_sequence([
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=nodo)),
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value="Algebra")),
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            lambda r: setattr(r, 'scalar_one', MagicMock(return_value=0)),
            # 8. Nota utente: nessuna
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
        ])

        risposta = await get_quaderno_nodo(nodo_id="nodo_1", utente=utente, db=db)

        scheda = risposta["scheda"]
        assert scheda["definizione_testo"] == "Un'equazione lineare e un'uguaglianza di primo grado."
        assert len(scheda["formule"]) == 2
        assert scheda["formule"][0]["latex"] == "ax + b = 0"
        assert scheda["formule"][1]["descrizione"] == "Soluzione"
        assert len(scheda["esempi"]) == 2
        assert "2x + 3 = 7" in scheda["esempi"][0]
        assert len(scheda["errori_comuni"]) == 1
        assert scheda["errori_comuni"][0]["tipo"] == "procedurale"
        assert scheda["errori_comuni"][0]["esempio_sbagliato"] == "2x = -4 → x = 4"
        assert len(scheda["parole_chiave"]) == 3
        assert "incognita" in scheda["parole_chiave"]
        # Nota utente assente
        assert risposta["nota_utente"] is None

    @pytest.mark.asyncio
    async def test_scheda_parziale_jsonb_nulli(self):
        """GET con nodo che ha alcuni JSONB null/vuoti: fallback a [] o null."""
        from app.api.quaderno import get_quaderno_nodo

        utente = MagicMock()
        utente.id = uuid.uuid4()

        # Nodo con solo definizione e parole_chiave, resto None
        nodo = _mock_nodo(
            definizioni_formali={"testo": "Definizione parziale."},
            formule_proprieta=None,
            esempi_applicazione=None,
            errori_comuni=None,
            parole_chiave=["algebra"],
        )

        db = _make_db_with_sequence([
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=nodo)),
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value="Algebra")),
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            lambda r: setattr(r, 'scalar_one', MagicMock(return_value=0)),
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
        ])

        risposta = await get_quaderno_nodo(nodo_id="nodo_1", utente=utente, db=db)

        scheda = risposta["scheda"]
        assert scheda["definizione_testo"] == "Definizione parziale."
        assert scheda["formule"] == []
        assert scheda["esempi"] == []
        assert scheda["errori_comuni"] == []
        assert scheda["parole_chiave"] == ["algebra"]

    @pytest.mark.asyncio
    async def test_nota_utente_assente(self):
        """GET con nota utente assente: nota_utente == None."""
        from app.api.quaderno import get_quaderno_nodo

        utente = MagicMock()
        utente.id = uuid.uuid4()
        nodo = _mock_nodo()

        db = _make_db_with_sequence([
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=nodo)),
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            lambda r: setattr(r, 'all', MagicMock(return_value=[])),
            lambda r: setattr(r, 'scalar_one', MagicMock(return_value=0)),
            # Nota utente: nessuna
            lambda r: setattr(r, 'scalar_one_or_none', MagicMock(return_value=None)),
        ])

        risposta = await get_quaderno_nodo(nodo_id="nodo_1", utente=utente, db=db)

        assert risposta["nota_utente"] is None
        # Scheda con tutti i JSONB None → fallback
        assert risposta["scheda"]["definizione_testo"] is None
        assert risposta["scheda"]["formule"] == []
        assert risposta["scheda"]["esempi"] == []
        assert risposta["scheda"]["errori_comuni"] == []
        assert risposta["scheda"]["parole_chiave"] == []


class TestPutNotaUtente:
    """Test B35.5.2 — PUT /quaderno/{nodo_id}/nota (upsert nota personale)."""

    @pytest.mark.asyncio
    async def test_crea_nuova_nota(self):
        """PUT su nodo senza nota esistente: crea la nota e ritorna dati."""
        from app.api.quaderno import NotaUtenteRequest, put_nota_utente

        utente = MagicMock()
        utente.id = uuid.uuid4()
        nodo = _mock_nodo()
        now = datetime.now(timezone.utc)

        # Dopo commit+refresh, la nota avra contenuto e updated_at
        nota_creata = _mock_nota_utente(contenuto="La mia prima nota", updated_at=now)

        db = AsyncMock()
        # 1. Nodo esiste
        result_nodo = MagicMock()
        result_nodo.scalar_one_or_none = MagicMock(return_value=nodo)
        # 2. Nota non esiste
        result_nota = MagicMock()
        result_nota.scalar_one_or_none = MagicMock(return_value=None)

        db.execute = AsyncMock(side_effect=[result_nodo, result_nota])
        db.add = MagicMock()
        db.commit = AsyncMock()

        # refresh aggiorna i campi della nota
        async def mock_refresh(obj):
            obj.contenuto = "La mia prima nota"
            obj.updated_at = now

        db.refresh = AsyncMock(side_effect=mock_refresh)

        payload = NotaUtenteRequest(testo="La mia prima nota")
        risposta = await put_nota_utente(nodo_id="nodo_1", payload=payload, utente=utente, db=db)

        assert risposta["nodo_id"] == "nodo_1"
        assert risposta["testo"] == "La mia prima nota"
        assert risposta["updated_at"] is not None
        # Verifica che db.add sia stato chiamato (creazione)
        db.add.assert_called_once()
        db.commit.assert_awaited_once()

    @pytest.mark.asyncio
    async def test_aggiorna_nota_esistente(self):
        """PUT su nodo con nota esistente: aggiorna contenuto."""
        from app.api.quaderno import NotaUtenteRequest, put_nota_utente

        utente = MagicMock()
        utente.id = uuid.uuid4()
        nodo = _mock_nodo()
        now = datetime.now(timezone.utc)

        nota_esistente = _mock_nota_utente(contenuto="Vecchio testo", updated_at=now - timedelta(days=1))

        db = AsyncMock()
        result_nodo = MagicMock()
        result_nodo.scalar_one_or_none = MagicMock(return_value=nodo)
        result_nota = MagicMock()
        result_nota.scalar_one_or_none = MagicMock(return_value=nota_esistente)

        db.execute = AsyncMock(side_effect=[result_nodo, result_nota])
        db.commit = AsyncMock()

        async def mock_refresh(obj):
            obj.updated_at = now

        db.refresh = AsyncMock(side_effect=mock_refresh)

        payload = NotaUtenteRequest(testo="Testo aggiornato")
        risposta = await put_nota_utente(nodo_id="nodo_1", payload=payload, utente=utente, db=db)

        assert risposta["testo"] == "Testo aggiornato"
        assert risposta["updated_at"] == now.isoformat()
        # Verifica che il contenuto della nota mock sia stato aggiornato
        assert nota_esistente.contenuto == "Testo aggiornato"
        # db.add NON chiamato (aggiornamento, non creazione)
        db.add.assert_not_called()

    @pytest.mark.asyncio
    async def test_nodo_inesistente_ritorna_404(self):
        """PUT su nodo inesistente: ritorna 404."""
        from app.api.quaderno import NotaUtenteRequest, put_nota_utente

        utente = MagicMock()
        utente.id = uuid.uuid4()

        db = AsyncMock()
        result_nodo = MagicMock()
        result_nodo.scalar_one_or_none = MagicMock(return_value=None)
        db.execute = AsyncMock(return_value=result_nodo)

        payload = NotaUtenteRequest(testo="Nota su nodo che non esiste")
        with pytest.raises(HTTPException) as exc_info:
            await put_nota_utente(nodo_id="nodo_fantasma", payload=payload, utente=utente, db=db)

        assert exc_info.value.status_code == 404

    def test_validazione_testo_vuoto(self):
        """Payload con testo vuoto non passa la validazione Pydantic."""
        from pydantic import ValidationError

        from app.api.quaderno import NotaUtenteRequest

        with pytest.raises(ValidationError):
            NotaUtenteRequest(testo="")

    def test_validazione_testo_troppo_lungo(self):
        """Payload con testo oltre 10000 char non passa la validazione."""
        from pydantic import ValidationError

        from app.api.quaderno import NotaUtenteRequest

        with pytest.raises(ValidationError):
            NotaUtenteRequest(testo="x" * 10001)
