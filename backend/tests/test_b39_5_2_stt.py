"""Test endpoint POST /stt/transcribe (B39.5.2).

Tutti i test usano mock del client OpenAI — nessuna chiamata reale.
"""

from __future__ import annotations

from unittest.mock import MagicMock, patch

import pytest
from fastapi import FastAPI
from httpx import ASGITransport, AsyncClient

from app.api.deps import get_utente_corrente
from app.api.stt import router

# --- Helper ---


def _mock_utente():
    """Crea un utente mock per i test."""
    import uuid

    utente = MagicMock()
    utente.id = uuid.uuid4()
    utente.nome = "Test"
    return utente


def _make_app(utente=None):
    """Crea un'app FastAPI di test con override dell'autenticazione."""
    app = FastAPI()
    app.include_router(router)

    if utente is None:
        utente = _mock_utente()

    app.dependency_overrides[get_utente_corrente] = lambda: utente
    return app


def _mock_trascrizione(testo: str):
    """Crea un mock della response Whisper."""
    mock = MagicMock()
    mock.text = testo
    return mock


# --- Test trascrizione riuscita ---


@pytest.mark.asyncio
async def test_trascrizione_ok():
    """Trascrizione di un file WAV valido restituisce il testo."""
    app = _make_app()

    mock_client = MagicMock()
    mock_client.audio.transcriptions.create.return_value = _mock_trascrizione(
        "Ciao, questa è una prova"
    )

    with patch("app.api.stt._get_openai_client", return_value=mock_client):
        with patch("app.api.stt.settings") as mock_settings:
            mock_settings.OPENAI_API_KEY = "sk-test-key"

            async with AsyncClient(
                transport=ASGITransport(app=app), base_url="http://test"
            ) as client:
                response = await client.post(
                    "/stt/transcribe",
                    files={"file": ("audio.wav", b"\x00" * 100, "audio/wav")},
                )

    assert response.status_code == 200
    data = response.json()
    assert data["testo"] == "Ciao, questa è una prova"


@pytest.mark.asyncio
async def test_trascrizione_mp3():
    """Accetta file MP3."""
    app = _make_app()

    mock_client = MagicMock()
    mock_client.audio.transcriptions.create.return_value = _mock_trascrizione("Test mp3")

    with patch("app.api.stt._get_openai_client", return_value=mock_client):
        with patch("app.api.stt.settings") as mock_settings:
            mock_settings.OPENAI_API_KEY = "sk-test-key"

            async with AsyncClient(
                transport=ASGITransport(app=app), base_url="http://test"
            ) as client:
                response = await client.post(
                    "/stt/transcribe",
                    files={"file": ("registrazione.mp3", b"\xff\xfb" * 50, "audio/mpeg")},
                )

    assert response.status_code == 200
    assert response.json()["testo"] == "Test mp3"


# --- Test formato invalido ---


@pytest.mark.asyncio
async def test_formato_non_supportato():
    """Un file con estensione non ammessa restituisce 400."""
    app = _make_app()

    with patch("app.api.stt.settings") as mock_settings:
        mock_settings.OPENAI_API_KEY = "sk-test-key"

        async with AsyncClient(
            transport=ASGITransport(app=app), base_url="http://test"
        ) as client:
            response = await client.post(
                "/stt/transcribe",
                files={"file": ("documento.pdf", b"%PDF-1.4", "application/pdf")},
            )

    assert response.status_code == 400
    assert "non supportato" in response.json()["detail"].lower()


@pytest.mark.asyncio
async def test_file_vuoto():
    """Un file audio vuoto restituisce 400."""
    app = _make_app()

    with patch("app.api.stt.settings") as mock_settings:
        mock_settings.OPENAI_API_KEY = "sk-test-key"

        async with AsyncClient(
            transport=ASGITransport(app=app), base_url="http://test"
        ) as client:
            response = await client.post(
                "/stt/transcribe",
                files={"file": ("audio.wav", b"", "audio/wav")},
            )

    assert response.status_code == 400
    assert "vuoto" in response.json()["detail"].lower()


@pytest.mark.asyncio
async def test_file_troppo_grande():
    """Un file oltre 25 MB restituisce 400."""
    app = _make_app()

    # Creiamo un contenuto > 25 MB (usiamo un BytesIO per non allocare troppo in memoria)
    contenuto_grande = b"\x00" * (25 * 1024 * 1024 + 1)

    with patch("app.api.stt.settings") as mock_settings:
        mock_settings.OPENAI_API_KEY = "sk-test-key"

        async with AsyncClient(
            transport=ASGITransport(app=app), base_url="http://test"
        ) as client:
            response = await client.post(
                "/stt/transcribe",
                files={"file": ("audio.wav", contenuto_grande, "audio/wav")},
            )

    assert response.status_code == 400
    assert "grande" in response.json()["detail"].lower()


# --- Test API down ---


@pytest.mark.asyncio
async def test_api_openai_down():
    """Se l'API OpenAI fallisce con errore generico, restituisce 502."""
    app = _make_app()

    mock_client = MagicMock()
    mock_client.audio.transcriptions.create.side_effect = Exception("Connection refused")

    with patch("app.api.stt._get_openai_client", return_value=mock_client):
        with patch("app.api.stt.settings") as mock_settings:
            mock_settings.OPENAI_API_KEY = "sk-test-key"

            async with AsyncClient(
                transport=ASGITransport(app=app), base_url="http://test"
            ) as client:
                response = await client.post(
                    "/stt/transcribe",
                    files={"file": ("audio.wav", b"\x00" * 100, "audio/wav")},
                )

    assert response.status_code == 502
    assert "riprova" in response.json()["detail"].lower()


# --- Test rate limit ---


@pytest.mark.asyncio
async def test_rate_limit():
    """Se Whisper restituisce rate limit, restituisce 429."""
    app = _make_app()

    mock_client = MagicMock()
    mock_client.audio.transcriptions.create.side_effect = Exception(
        "Error code: 429 - Rate limit exceeded"
    )

    with patch("app.api.stt._get_openai_client", return_value=mock_client):
        with patch("app.api.stt.settings") as mock_settings:
            mock_settings.OPENAI_API_KEY = "sk-test-key"

            async with AsyncClient(
                transport=ASGITransport(app=app), base_url="http://test"
            ) as client:
                response = await client.post(
                    "/stt/transcribe",
                    files={"file": ("audio.wav", b"\x00" * 100, "audio/wav")},
                )

    assert response.status_code == 429
    assert "richieste" in response.json()["detail"].lower()


# --- Test chiave mancante ---


@pytest.mark.asyncio
async def test_chiave_openai_mancante():
    """Se OPENAI_API_KEY non è configurata, restituisce 503."""
    app = _make_app()

    with patch("app.api.stt.settings") as mock_settings:
        mock_settings.OPENAI_API_KEY = ""

        async with AsyncClient(
            transport=ASGITransport(app=app), base_url="http://test"
        ) as client:
            response = await client.post(
                "/stt/transcribe",
                files={"file": ("audio.wav", b"\x00" * 100, "audio/wav")},
            )

    assert response.status_code == 503
    assert "non disponibile" in response.json()["detail"].lower()


# --- Test autenticazione OpenAI invalida ---


@pytest.mark.asyncio
async def test_autenticazione_openai_invalida():
    """Se la chiave OpenAI è invalida (401), restituisce 503."""
    app = _make_app()

    mock_client = MagicMock()
    mock_client.audio.transcriptions.create.side_effect = Exception(
        "Error code: 401 - Invalid authentication"
    )

    with patch("app.api.stt._get_openai_client", return_value=mock_client):
        with patch("app.api.stt.settings") as mock_settings:
            mock_settings.OPENAI_API_KEY = "sk-invalid"

            async with AsyncClient(
                transport=ASGITransport(app=app), base_url="http://test"
            ) as client:
                response = await client.post(
                    "/stt/transcribe",
                    files={"file": ("audio.wav", b"\x00" * 100, "audio/wav")},
                )

    assert response.status_code == 503
    assert "non disponibile" in response.json()["detail"].lower()


# --- Test nessun parlato ---


@pytest.mark.asyncio
async def test_nessun_parlato():
    """Se Whisper restituisce testo vuoto, restituisce 422."""
    app = _make_app()

    mock_client = MagicMock()
    mock_client.audio.transcriptions.create.return_value = _mock_trascrizione("   ")

    with patch("app.api.stt._get_openai_client", return_value=mock_client):
        with patch("app.api.stt.settings") as mock_settings:
            mock_settings.OPENAI_API_KEY = "sk-test-key"

            async with AsyncClient(
                transport=ASGITransport(app=app), base_url="http://test"
            ) as client:
                response = await client.post(
                    "/stt/transcribe",
                    files={"file": ("audio.wav", b"\x00" * 100, "audio/wav")},
                )

    assert response.status_code == 422
    assert "parlato" in response.json()["detail"].lower()


# --- Test content type senza estensione ---


@pytest.mark.asyncio
async def test_content_type_invalido_senza_estensione():
    """File senza estensione e con content type non audio restituisce 400."""
    app = _make_app()

    with patch("app.api.stt.settings") as mock_settings:
        mock_settings.OPENAI_API_KEY = "sk-test-key"

        async with AsyncClient(
            transport=ASGITransport(app=app), base_url="http://test"
        ) as client:
            response = await client.post(
                "/stt/transcribe",
                files={"file": ("documento", b"\x00" * 100, "text/plain")},
            )

    assert response.status_code == 400


# --- Test formati accettati ---


@pytest.mark.asyncio
async def test_tutti_i_formati_ammessi():
    """Verifica che tutti i formati nella whitelist siano accettati."""
    from app.api.stt import ESTENSIONI_AMMESSE

    assert ".wav" in ESTENSIONI_AMMESSE
    assert ".mp3" in ESTENSIONI_AMMESSE
    assert ".ogg" in ESTENSIONI_AMMESSE
    assert ".flac" in ESTENSIONI_AMMESSE
    assert ".webm" in ESTENSIONI_AMMESSE
    assert ".m4a" in ESTENSIONI_AMMESSE
    assert ".mp4" in ESTENSIONI_AMMESSE


# --- Test parametro language ---


@pytest.mark.asyncio
async def test_lingua_italiana_passata_a_whisper():
    """Verifica che la lingua 'it' venga passata alla chiamata Whisper."""
    app = _make_app()

    mock_client = MagicMock()
    mock_client.audio.transcriptions.create.return_value = _mock_trascrizione("Ciao")

    with patch("app.api.stt._get_openai_client", return_value=mock_client):
        with patch("app.api.stt.settings") as mock_settings:
            mock_settings.OPENAI_API_KEY = "sk-test-key"

            async with AsyncClient(
                transport=ASGITransport(app=app), base_url="http://test"
            ) as client:
                await client.post(
                    "/stt/transcribe",
                    files={"file": ("audio.wav", b"\x00" * 100, "audio/wav")},
                )

    # Verifica che la chiamata a Whisper includa language="it"
    call_kwargs = mock_client.audio.transcriptions.create.call_args
    assert call_kwargs.kwargs.get("language") == "it" or (
        len(call_kwargs.args) == 0 and call_kwargs[1].get("language") == "it"
    )
