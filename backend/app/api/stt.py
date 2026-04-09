"""API Speech-to-Text — trascrizione audio via OpenAI Whisper (B39.5.2)."""

import logging

from fastapi import APIRouter, Depends, HTTPException, UploadFile
from pydantic import BaseModel

from app.api.deps import get_utente_corrente
from app.config import settings
from app.db.models.utenti import Utente

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/stt", tags=["stt"])

# Formati audio accettati da Whisper
FORMATI_AMMESSI = {"audio/mpeg", "audio/mp4", "audio/wav", "audio/webm", "audio/ogg", "audio/flac"}
ESTENSIONI_AMMESSE = {".mp3", ".mp4", ".m4a", ".wav", ".webm", ".ogg", ".flac"}

# Limite dimensione file: 25 MB (limite Whisper)
MAX_FILE_SIZE_BYTES = 25 * 1024 * 1024


class TrascrizioneResponse(BaseModel):
    testo: str


def _get_openai_client():
    """Crea il client OpenAI. Separato per facilitare il mock nei test."""
    from openai import OpenAI

    return OpenAI(api_key=settings.OPENAI_API_KEY)


@router.post("/transcribe", response_model=TrascrizioneResponse)
async def trascrivi_audio(
    file: UploadFile,
    utente: Utente = Depends(get_utente_corrente),
):
    """Riceve un file audio multipart e restituisce il testo trascritto via Whisper.

    Formati supportati: mp3, mp4, m4a, wav, webm, ogg, flac.
    Limite: 25 MB.
    """
    # Validazione chiave API
    if not settings.OPENAI_API_KEY:
        logger.error("OPENAI_API_KEY non configurata — trascrizione impossibile")
        raise HTTPException(
            status_code=503,
            detail="Servizio di trascrizione non disponibile",
        )

    # Validazione formato file
    filename = file.filename or ""
    estensione = ""
    if "." in filename:
        estensione = "." + filename.rsplit(".", 1)[1].lower()

    content_type = file.content_type or ""

    if estensione and estensione not in ESTENSIONI_AMMESSE:
        formati = ", ".join(sorted(ESTENSIONI_AMMESSE))
        raise HTTPException(
            status_code=400,
            detail=f"Formato audio non supportato. Ammessi: {formati}",
        )

    formato_sconosciuto = (
        content_type
        and content_type not in FORMATI_AMMESSI
        and estensione not in ESTENSIONI_AMMESSE
    )
    if formato_sconosciuto:
        formati = ", ".join(sorted(ESTENSIONI_AMMESSE))
        raise HTTPException(
            status_code=400,
            detail=f"Formato audio non supportato. Ammessi: {formati}",
        )

    # Leggi contenuto e valida dimensione
    contenuto = await file.read()

    if len(contenuto) == 0:
        raise HTTPException(status_code=400, detail="Il file audio è vuoto")

    if len(contenuto) > MAX_FILE_SIZE_BYTES:
        raise HTTPException(
            status_code=400,
            detail=f"File troppo grande. Limite: {MAX_FILE_SIZE_BYTES // (1024 * 1024)} MB",
        )

    # Chiama Whisper
    try:
        client = _get_openai_client()

        # Whisper accetta file-like con nome
        trascrizione = client.audio.transcriptions.create(
            model="whisper-1",
            file=(filename or "audio.wav", contenuto),
            language="it",
        )

        testo = trascrizione.text.strip()

        if not testo:
            raise HTTPException(
                status_code=422,
                detail="Nessun parlato riconosciuto nell'audio",
            )

        logger.info(
            "Trascrizione completata per utente %s: %d caratteri",
            utente.id,
            len(testo),
        )

        return TrascrizioneResponse(testo=testo)

    except HTTPException:
        raise
    except Exception as e:
        error_type = type(e).__name__
        error_msg = str(e)

        # Rate limit
        if "rate_limit" in error_msg.lower() or "429" in error_msg:
            logger.warning("Rate limit Whisper per utente %s: %s", utente.id, error_msg)
            raise HTTPException(
                status_code=429,
                detail="Troppe richieste di trascrizione. Riprova tra qualche secondo.",
            )

        # Errore autenticazione OpenAI
        if "401" in error_msg or "authentication" in error_msg.lower():
            logger.error("Errore autenticazione OpenAI: %s", error_msg)
            raise HTTPException(
                status_code=503,
                detail="Servizio di trascrizione non disponibile",
            )

        # Errore generico
        logger.error(
            "Errore trascrizione Whisper per utente %s: [%s] %s",
            utente.id,
            error_type,
            error_msg,
        )
        raise HTTPException(
            status_code=502,
            detail="Errore durante la trascrizione. Riprova.",
        )
