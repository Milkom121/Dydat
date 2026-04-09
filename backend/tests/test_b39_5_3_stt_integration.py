"""Test di integrazione endpoint POST /stt/transcribe con audio reale (B39.5.3).

Richiede OPENAI_API_KEY valida in .env. Gira solo con `pytest --run-integration`.
Verifica che l'endpoint comunichi correttamente con OpenAI Whisper.
"""

from __future__ import annotations

import io
import math
import struct
import wave
from unittest.mock import MagicMock

import pytest
from fastapi import FastAPI
from httpx import ASGITransport, AsyncClient

from app.api.deps import get_utente_corrente
from app.api.stt import router
from app.config import settings

# --- Helper ---


def _mock_utente():
    """Crea un utente mock per i test."""
    import uuid

    utente = MagicMock()
    utente.id = uuid.uuid4()
    utente.nome = "TestIntegration"
    return utente


def _make_app():
    """Crea un'app FastAPI di test con override dell'autenticazione."""
    app = FastAPI()
    app.include_router(router)
    app.dependency_overrides[get_utente_corrente] = lambda: _mock_utente()
    return app


def _genera_wav_tono(
    durata_sec: float = 1.0, frequenza_hz: int = 440, sample_rate: int = 16000
) -> bytes:
    """Genera un file WAV valido con un tono sinusoidale.

    Utile come audio di smoke test: Whisper potrebbe restituire
    testo vuoto (nessun parlato) o interpretare il tono come qualcosa.
    Entrambi i casi sono validi per verificare la comunicazione con l'API.
    """
    buf = io.BytesIO()
    n_campioni = int(sample_rate * durata_sec)
    ampiezza = 16000  # ~50% del range int16

    with wave.open(buf, "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)  # 16-bit
        wf.setframerate(sample_rate)

        frames = b""
        for i in range(n_campioni):
            valore = int(ampiezza * math.sin(2 * math.pi * frequenza_hz * i / sample_rate))
            frames += struct.pack("<h", valore)

        wf.writeframes(frames)

    return buf.getvalue()


def _genera_wav_silenzio(durata_sec: float = 0.5, sample_rate: int = 16000) -> bytes:
    """Genera un file WAV valido con silenzio (tutti zeri)."""
    buf = io.BytesIO()
    n_campioni = int(sample_rate * durata_sec)

    with wave.open(buf, "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        wf.writeframes(b"\x00\x00" * n_campioni)

    return buf.getvalue()


# --- Prerequisito ---


def _chiave_openai_disponibile() -> bool:
    """Verifica che OPENAI_API_KEY sia configurata (non vuota)."""
    return bool(settings.OPENAI_API_KEY)


# --- Test di integrazione ---


@pytest.mark.integration
@pytest.mark.asyncio
async def test_stt_smoke_tono_wav():
    """Smoke test: invia un WAV con tono a 440Hz a Whisper reale.

    Verifica che l'endpoint comunichi con OpenAI e restituisca una
    risposta valida. Whisper potrebbe restituire:
    - 200 con testo (interpreta il tono come qualcosa)
    - 422 nessun parlato riconosciuto (tono senza voce)
    Entrambi dimostrano che l'integrazione funziona.
    """
    if not _chiave_openai_disponibile():
        pytest.skip("OPENAI_API_KEY non configurata — impossibile testare con Whisper reale")

    app = _make_app()
    audio_wav = _genera_wav_tono(durata_sec=1.5, frequenza_hz=440)

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        response = await client.post(
            "/stt/transcribe",
            files={"file": ("test_tono.wav", audio_wav, "audio/wav")},
        )

    # Risposte accettabili: 200 (testo riconosciuto) o 422 (nessun parlato)
    assert response.status_code in (200, 422), (
        f"Risposta inattesa: {response.status_code} — {response.json()}"
    )

    if response.status_code == 200:
        data = response.json()
        assert "testo" in data
        assert len(data["testo"]) > 0


@pytest.mark.integration
@pytest.mark.asyncio
async def test_stt_smoke_silenzio_wav():
    """Smoke test: invia un WAV di silenzio a Whisper reale.

    Ci si aspetta 422 (nessun parlato) ma anche 200 con testo
    sarebbe accettabile (Whisper a volte interpreta il rumore di fondo).
    L'importante e' che l'API risponda senza errori 5xx.
    """
    if not _chiave_openai_disponibile():
        pytest.skip("OPENAI_API_KEY non configurata — impossibile testare con Whisper reale")

    app = _make_app()
    audio_wav = _genera_wav_silenzio(durata_sec=1.0)

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        response = await client.post(
            "/stt/transcribe",
            files={"file": ("silenzio.wav", audio_wav, "audio/wav")},
        )

    # Silenzio: quasi certamente 422, ma 200 e' accettabile
    assert response.status_code in (200, 422), (
        f"Risposta inattesa: {response.status_code} — {response.json()}"
    )


@pytest.mark.integration
@pytest.mark.asyncio
async def test_stt_smoke_formato_mp3_header():
    """Smoke test: verifica che un file con estensione .mp3 venga accettato.

    Invia un WAV rinominato come .mp3 (Whisper e' tollerante sul formato
    reale vs estensione). Verifica che non ci siano errori di comunicazione.
    """
    if not _chiave_openai_disponibile():
        pytest.skip("OPENAI_API_KEY non configurata — impossibile testare con Whisper reale")

    app = _make_app()
    # Usiamo un tono WAV valido ma con nome .mp3
    # Whisper accetta il contenuto reale indipendentemente dall'estensione
    audio_wav = _genera_wav_tono(durata_sec=1.0, frequenza_hz=880)

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        response = await client.post(
            "/stt/transcribe",
            files={"file": ("test_audio.mp3", audio_wav, "audio/mpeg")},
        )

    # Qualsiasi risposta non-5xx dimostra che il flusso funziona
    assert response.status_code in (200, 422), (
        f"Risposta inattesa: {response.status_code} — {response.json()}"
    )


def test_helper_chiave_openai():
    """Verifica che l'helper _chiave_openai_disponibile funzioni.

    Questo test gira sempre (non e' un test di integrazione).
    """
    risultato = _chiave_openai_disponibile()
    assert isinstance(risultato, bool)
