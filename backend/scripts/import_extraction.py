"""Import Knowledge Base JSON files into the database.

Usage:
    docker compose exec backend python -m scripts.import_extraction data/Algebra1 data/Algebra2

Features:
- Auto-detects files by prefix (nodi*.json, relazioni*.json, esercizi*.json)
- UPSERT idempotent (safe to re-run)
- Extracts themes from nodes' tema_id field
- Handles multiple folders (Algebra1 + Algebra2)
- Handles _fix_ exercises with reduced schema
"""

import asyncio
import json
import logging
import sys
from pathlib import Path

from sqlalchemy import text
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker

from app.config import settings
from app.db.models.grafo import Esercizio, Nodo, NodoTema, Relazione, Tema

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
log = logging.getLogger(__name__)


def find_json(folder: Path, prefix: str) -> Path | None:
    """Find a JSON file in folder matching prefix (e.g. 'nodi' matches 'nodi.json' or 'nodi_Algebra1.json')."""
    for p in sorted(folder.glob(f"{prefix}*.json")):
        if p.stem.startswith(prefix):
            return p
    return None


def humanize_tema_id(tema_id: str) -> str:
    """Convert tema_id slug to human-readable name. e.g. 'numeri_relativi' -> 'Numeri relativi'."""
    return tema_id.replace("_", " ").capitalize()


def map_nodo(raw: dict) -> dict:
    """Map a raw JSON node to DB column values."""
    metadata = {}
    if "fonte" in raw:
        metadata["fonte"] = raw["fonte"]
    if "confidence" in raw:
        metadata["confidence"] = raw["confidence"]

    # definizione is a string in JSON → wrap in JSONB for definizioni_formali
    definizione = raw.get("definizione")
    definizioni_formali = {"testo": definizione} if definizione else None

    return {
        "id": raw["id"],
        "nome": raw["nome"],
        "materia": raw.get("materia", "matematica"),
        "tipo": raw.get("tipo", "standard"),
        "tipo_nodo": raw.get("tipo_nodo", "operativo"),
        "definizioni_formali": definizioni_formali,
        "formule_proprieta": raw.get("formule"),
        "errori_comuni": raw.get("errori_comuni"),
        "esempi_applicazione": raw.get("esempi"),
        "parole_chiave": raw.get("parole_chiave"),
        "embedding": raw.get("embedding"),
        "metadata": metadata or None,
    }


def map_esercizio(raw: dict) -> dict:
    """Map a raw JSON exercise to DB column values."""
    metadata = {}
    for key in ("competenze_chiave", "tipo_ragionamento", "risposta_libro",
                "metodo_estrazione", "fonte", "confidence", "embedding"):
        if key in raw:
            metadata[key] = raw[key]

    return {
        "id": raw["id"],
        "nodo_id": raw["nodo_focale"],
        "testo": raw["testo"],
        "tipo": raw.get("tipo"),
        "difficolta": raw.get("difficolta"),
        "soluzione": raw.get("soluzione"),
        "nodi_coinvolti": raw.get("nodi_coinvolti"),
        "metadata": metadata or None,
    }


def map_relazione(raw: dict) -> dict:
    """Map a raw JSON relation to DB column values. Drops confidence and passaggio."""
    return {
        "nodo_da": raw["nodo_da"],
        "nodo_a": raw["nodo_a"],
        "dipendenza": raw["dipendenza"],
        "descrizione": raw["descrizione"],
    }


async def upsert_nodi(session: AsyncSession, nodi_data: list[dict]) -> int:
    """UPSERT nodes into the database. Returns count."""
    if not nodi_data:
        return 0
    mapped = [map_nodo(n) for n in nodi_data]
    stmt = insert(Nodo.__table__).values(mapped)
    stmt = stmt.on_conflict_do_update(
        index_elements=["id"],
        set_={
            "nome": stmt.excluded.nome,
            "materia": stmt.excluded.materia,
            "tipo": stmt.excluded.tipo,
            "tipo_nodo": stmt.excluded.tipo_nodo,
            "definizioni_formali": stmt.excluded.definizioni_formali,
            "formule_proprieta": stmt.excluded.formule_proprieta,
            "errori_comuni": stmt.excluded.errori_comuni,
            "esempi_applicazione": stmt.excluded.esempi_applicazione,
            "parole_chiave": stmt.excluded.parole_chiave,
            "embedding": stmt.excluded.embedding,
            "metadata": stmt.excluded.metadata,
        },
    )
    await session.execute(stmt)
    return len(mapped)


async def upsert_temi(session: AsyncSession, nodi_data: list[dict]) -> int:
    """Extract unique themes from nodes and UPSERT them. Returns count."""
    temi_seen: dict[str, str] = {}  # tema_id -> materia
    for nodo in nodi_data:
        tema_id = nodo.get("tema_id")
        if tema_id and tema_id not in temi_seen:
            temi_seen[tema_id] = nodo.get("materia", "matematica")

    if not temi_seen:
        return 0

    temi_rows = [
        {"id": tid, "nome": humanize_tema_id(tid), "materia": mat}
        for tid, mat in temi_seen.items()
    ]
    stmt = insert(Tema.__table__).values(temi_rows)
    stmt = stmt.on_conflict_do_update(
        index_elements=["id"],
        set_={"nome": stmt.excluded.nome, "materia": stmt.excluded.materia},
    )
    await session.execute(stmt)
    return len(temi_rows)


async def upsert_nodi_temi(session: AsyncSession, nodi_data: list[dict]) -> int:
    """Create nodo-tema associations. Returns count."""
    rows = []
    for nodo in nodi_data:
        tema_id = nodo.get("tema_id")
        if tema_id:
            rows.append({"nodo_id": nodo["id"], "tema_id": tema_id})

    if not rows:
        return 0

    stmt = insert(NodoTema.__table__).values(rows)
    stmt = stmt.on_conflict_do_nothing(index_elements=["nodo_id", "tema_id"])
    await session.execute(stmt)
    return len(rows)


async def upsert_relazioni(session: AsyncSession, relazioni_data: list[dict]) -> int:
    """UPSERT relations. Returns count."""
    if not relazioni_data:
        return 0
    mapped = [map_relazione(r) for r in relazioni_data]
    stmt = insert(Relazione.__table__).values(mapped)
    stmt = stmt.on_conflict_do_update(
        index_elements=["nodo_da", "nodo_a"],
        set_={
            "dipendenza": stmt.excluded.dipendenza,
            "descrizione": stmt.excluded.descrizione,
        },
    )
    await session.execute(stmt)
    return len(mapped)


async def upsert_esercizi(session: AsyncSession, esercizi_data: list[dict]) -> int:
    """UPSERT exercises. Returns count."""
    if not esercizi_data:
        return 0
    mapped = [map_esercizio(e) for e in esercizi_data]
    stmt = insert(Esercizio.__table__).values(mapped)
    stmt = stmt.on_conflict_do_update(
        index_elements=["id"],
        set_={
            "nodo_id": stmt.excluded.nodo_id,
            "testo": stmt.excluded.testo,
            "tipo": stmt.excluded.tipo,
            "difficolta": stmt.excluded.difficolta,
            "soluzione": stmt.excluded.soluzione,
            "nodi_coinvolti": stmt.excluded.nodi_coinvolti,
            "metadata": stmt.excluded.metadata,
        },
    )
    await session.execute(stmt)
    return len(mapped)


async def import_folder(session: AsyncSession, folder: Path) -> dict:
    """Import all KB data from a single folder. Returns stats dict."""
    log.info(f"Importing from {folder}")
    stats = {"nodi": 0, "temi": 0, "nodi_temi": 0, "relazioni": 0, "esercizi": 0}

    # Load JSON files
    nodi_path = find_json(folder, "nodi")
    relazioni_path = find_json(folder, "relazioni")
    esercizi_path = find_json(folder, "esercizi")

    if not nodi_path:
        log.warning(f"No nodi*.json found in {folder}")
        return stats

    nodi_data = json.loads(nodi_path.read_text(encoding="utf-8"))
    log.info(f"  Loaded {len(nodi_data)} nodi from {nodi_path.name}")

    # 1. Temi first (extracted from nodes)
    stats["temi"] = await upsert_temi(session, nodi_data)
    log.info(f"  Upserted {stats['temi']} temi")

    # 2. Nodi
    stats["nodi"] = await upsert_nodi(session, nodi_data)
    log.info(f"  Upserted {stats['nodi']} nodi")

    # 3. Nodi-Temi associations
    stats["nodi_temi"] = await upsert_nodi_temi(session, nodi_data)
    log.info(f"  Upserted {stats['nodi_temi']} nodi_temi")

    # 4. Relazioni
    if relazioni_path:
        relazioni_data = json.loads(relazioni_path.read_text(encoding="utf-8"))
        # Handle both flat array and dict-with-relazioni format
        if isinstance(relazioni_data, dict):
            relazioni_data = relazioni_data.get("relazioni", [])
        stats["relazioni"] = await upsert_relazioni(session, relazioni_data)
        log.info(f"  Upserted {stats['relazioni']} relazioni from {relazioni_path.name}")

    # 5. Esercizi
    if esercizi_path:
        esercizi_data = json.loads(esercizi_path.read_text(encoding="utf-8"))
        stats["esercizi"] = await upsert_esercizi(session, esercizi_data)
        log.info(f"  Upserted {stats['esercizi']} esercizi from {esercizi_path.name}")

    return stats


async def verify_integrity(session: AsyncSession) -> None:
    """Run integrity checks after import."""
    log.info("Running integrity checks...")

    # Count all entities
    counts = {}
    for table in ("nodi", "temi", "nodi_temi", "relazioni", "esercizi"):
        result = await session.execute(text(f"SELECT count(*) FROM {table}"))
        counts[table] = result.scalar()
    log.info(f"  Totals: {counts}")

    # Check for orphan exercises (nodo_id not in nodi)
    result = await session.execute(text("""
        SELECT count(*) FROM esercizi e
        LEFT JOIN nodi n ON e.nodo_id = n.id
        WHERE n.id IS NULL
    """))
    orphan_ex = result.scalar()
    if orphan_ex > 0:
        log.warning(f"  {orphan_ex} exercises reference non-existent nodi!")
    else:
        log.info("  No orphan exercises")

    # Check for orphan relations
    result = await session.execute(text("""
        SELECT count(*) FROM relazioni r
        LEFT JOIN nodi n1 ON r.nodo_da = n1.id
        LEFT JOIN nodi n2 ON r.nodo_a = n2.id
        WHERE n1.id IS NULL OR n2.id IS NULL
    """))
    orphan_rel = result.scalar()
    if orphan_rel > 0:
        log.warning(f"  {orphan_rel} relations reference non-existent nodi!")
    else:
        log.info("  No orphan relations")

    # Node type distribution
    result = await session.execute(text(
        "SELECT tipo_nodo, count(*) FROM nodi GROUP BY tipo_nodo ORDER BY tipo_nodo"
    ))
    for row in result:
        log.info(f"  tipo_nodo={row[0]}: {row[1]}")

    # Exercise coverage
    result = await session.execute(text("""
        SELECT count(DISTINCT n.id) as nodi_con_esercizi
        FROM nodi n
        JOIN esercizi e ON e.nodo_id = n.id
        WHERE n.tipo_nodo = 'operativo'
    """))
    nodi_with_ex = result.scalar()
    result = await session.execute(text(
        "SELECT count(*) FROM nodi WHERE tipo_nodo = 'operativo'"
    ))
    total_op = result.scalar()
    log.info(f"  Exercise coverage: {nodi_with_ex}/{total_op} operative nodes")


async def main(folders: list[str]) -> None:
    engine = create_async_engine(settings.DATABASE_URL)
    session_factory = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with session_factory() as session:
        total_stats: dict[str, int] = {}
        for folder_str in folders:
            folder = Path(folder_str)
            if not folder.is_dir():
                log.error(f"Not a directory: {folder}")
                continue
            stats = await import_folder(session, folder)
            for k, v in stats.items():
                total_stats[k] = total_stats.get(k, 0) + v

        await session.commit()
        log.info(f"Import complete. Totals: {total_stats}")

        await verify_integrity(session)

    await engine.dispose()


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python -m scripts.import_extraction <folder1> [folder2] ...")
        print("Example: python -m scripts.import_extraction data/Algebra1 data/Algebra2")
        sys.exit(1)

    asyncio.run(main(sys.argv[1:]))
