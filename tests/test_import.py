"""Test import script with real KB data."""

import json
from pathlib import Path

from scripts.import_extraction import (
    find_json,
    humanize_tema_id,
    map_esercizio,
    map_nodo,
    map_relazione,
)

DATA_DIR = Path(__file__).parent.parent / "data"


def test_find_json():
    """find_json locates files by prefix."""
    p = find_json(DATA_DIR / "Algebra1", "nodi")
    assert p is not None
    assert p.name == "nodi.json"


def test_humanize_tema_id():
    assert humanize_tema_id("numeri_relativi") == "Numeri relativi"
    assert humanize_tema_id("equazioni") == "Equazioni"


def test_map_nodo_full():
    """Map a real node with all fields."""
    raw = {
        "id": "mat_test_nodo",
        "nome": "Test Nodo",
        "tema_id": "test_tema",
        "materia": "matematica",
        "tipo": "standard",
        "tipo_nodo": "operativo",
        "definizione": "Una definizione di test",
        "formule": [{"latex": "x^2", "descrizione": "quadrato"}],
        "errori_comuni": [{"tipo": "t", "descrizione": "d", "esempio_sbagliato": "e"}],
        "esempi": ["esempio 1"],
        "parole_chiave": ["test"],
        "embedding": [0.1] * 1024,
        "fonte": {"pdf": "test.pdf", "pagina_inizio": 1, "pagina_fine": 2},
        "confidence": 0.95,
    }
    mapped = map_nodo(raw)
    assert mapped["id"] == "mat_test_nodo"
    assert mapped["nome"] == "Test Nodo"
    assert mapped["definizioni_formali"] == {"testo": "Una definizione di test"}
    assert mapped["formule_proprieta"] == [{"latex": "x^2", "descrizione": "quadrato"}]
    assert mapped["metadata"]["fonte"]["pdf"] == "test.pdf"
    assert mapped["metadata"]["confidence"] == 0.95
    assert len(mapped["embedding"]) == 1024


def test_map_nodo_defaults():
    """tipo and tipo_nodo default to standard/operativo."""
    raw = {"id": "x", "nome": "X", "materia": "matematica"}
    mapped = map_nodo(raw)
    assert mapped["tipo"] == "standard"
    assert mapped["tipo_nodo"] == "operativo"
    assert mapped["definizioni_formali"] is None


def test_map_esercizio_full():
    raw = {
        "id": "ex_test_001",
        "testo": "Risolvi x+1=0",
        "tipo": "calcolo",
        "difficolta": 2,
        "nodo_focale": "mat_test_nodo",
        "nodi_coinvolti": [{"nodo_id": "mat_test_nodo", "ruolo": "principale"}],
        "soluzione": {"passaggi": [], "risposta_finale": "x=-1", "verificata": True},
        "competenze_chiave": ["algebra"],
        "tipo_ragionamento": "procedurale",
        "risposta_libro": "x=-1",
        "metodo_estrazione": "ocr",
        "fonte": {"pdf": "test.pdf", "pagina": 10},
        "confidence": 0.9,
        "embedding": [0.2] * 1024,
    }
    mapped = map_esercizio(raw)
    assert mapped["nodo_id"] == "mat_test_nodo"
    assert mapped["soluzione"]["risposta_finale"] == "x=-1"
    assert mapped["metadata"]["competenze_chiave"] == ["algebra"]
    assert mapped["metadata"]["embedding"] is not None
    assert "nodo_focale" not in mapped  # mapped to nodo_id


def test_map_esercizio_fix():
    """_fix_ exercises have reduced schema — missing fields become absent from metadata."""
    raw = {
        "id": "ex_test_fix_001",
        "testo": "Risolvi y=2",
        "tipo": "calcolo",
        "difficolta": 1,
        "nodo_focale": "mat_test_nodo",
        "nodi_coinvolti": [],
        "soluzione": {"passaggi": [], "risposta_finale": "y=2", "verificata": True},
        "fonte": {"pdf": "test.pdf", "pagina": 20},
        "embedding": [0.3] * 1024,
    }
    mapped = map_esercizio(raw)
    assert mapped["nodo_id"] == "mat_test_nodo"
    # No competenze_chiave, tipo_ragionamento etc.
    assert "competenze_chiave" not in mapped["metadata"]
    assert "confidence" not in mapped["metadata"]
    assert mapped["metadata"]["fonte"]["pagina"] == 20


def test_map_relazione():
    raw = {
        "nodo_da": "mat_a",
        "nodo_a": "mat_b",
        "dipendenza": "bloccante",
        "descrizione": "A è prerequisito di B",
        "confidence": 0.9,
        "passaggio": "7a",
    }
    mapped = map_relazione(raw)
    assert mapped["dipendenza"] == "bloccante"
    assert "confidence" not in mapped
    assert "passaggio" not in mapped


def test_real_data_loadable():
    """Verify real KB files are parseable and have expected counts."""
    for book, expected_nodi, expected_ex in [("Algebra1", 114, 756), ("Algebra2", 69, 714)]:
        nodi_path = DATA_DIR / book / "nodi.json"
        if not nodi_path.exists():
            continue
        nodi = json.loads(nodi_path.read_text(encoding="utf-8"))
        assert len(nodi) == expected_nodi, f"{book} nodi count mismatch"

        ex_path = DATA_DIR / book / "esercizi.json"
        esercizi = json.loads(ex_path.read_text(encoding="utf-8"))
        assert len(esercizi) == expected_ex, f"{book} esercizi count mismatch"

        rel_path = DATA_DIR / book / "relazioni.json"
        relazioni = json.loads(rel_path.read_text(encoding="utf-8"))
        assert isinstance(relazioni, list), f"{book} relazioni should be flat array"
