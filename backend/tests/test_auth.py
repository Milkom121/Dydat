"""Test autenticazione: sicurezza JWT + API auth + protezione endpoint.

Include test per:
- Sicurezza (hash, JWT)
- API registrazione e login
- Conversione utente temporaneo → registrato (Bug #5)
- Schema RegistraRequest con utente_temp_id opzionale
"""

import uuid
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app.core.sicurezza import crea_token, hash_password, verifica_password, verifica_token


# ---------------------------------------------------------------------------
# Test modulo sicurezza (puro, no DB)
# ---------------------------------------------------------------------------

class TestHashPassword:
    def test_hash_diverso_da_plaintext(self):
        h = hash_password("password123")
        assert h != "password123"
        assert h.startswith("$2b$")  # bcrypt prefix

    def test_verifica_password_corretta(self):
        h = hash_password("mypass")
        assert verifica_password("mypass", h) is True

    def test_verifica_password_sbagliata(self):
        h = hash_password("mypass")
        assert verifica_password("wrongpass", h) is False

    def test_hash_diversi_per_stessa_password(self):
        h1 = hash_password("same")
        h2 = hash_password("same")
        assert h1 != h2  # salt diversi


class TestJWT:
    def test_crea_e_verifica_token(self):
        token = crea_token("test-user-id")
        assert isinstance(token, str)
        utente_id = verifica_token(token)
        assert utente_id == "test-user-id"

    def test_token_invalido_solleva_errore(self):
        with pytest.raises(ValueError, match="Token non valido"):
            verifica_token("token.completamente.invalido")

    def test_token_manomesso_solleva_errore(self):
        token = crea_token("user-1")
        # Modifica un carattere del payload
        parti = token.split(".")
        parti[1] = parti[1][:-1] + ("A" if parti[1][-1] != "A" else "B")
        token_manomesso = ".".join(parti)
        with pytest.raises(ValueError):
            verifica_token(token_manomesso)

    def test_token_con_uuid(self):
        import uuid
        uid = str(uuid.uuid4())
        token = crea_token(uid)
        assert verifica_token(token) == uid


# ---------------------------------------------------------------------------
# Test API auth (richiedono DB PostgreSQL)
# ---------------------------------------------------------------------------

class TestAPIRegistrazione:
    """Test POST /auth/registrazione.

    Questi test richiedono un database PostgreSQL attivo.
    Vengono skippati se il DB non e' disponibile.
    """

    @pytest.fixture
    def client(self):
        """Crea un test client asincrono per FastAPI."""
        try:
            from httpx import ASGITransport, AsyncClient
            from app.main import app
            transport = ASGITransport(app=app)
            return AsyncClient(transport=transport, base_url="http://test")
        except Exception:
            pytest.skip("Impossibile creare test client")

    @pytest.mark.skip(reason="Richiede DB PostgreSQL attivo")
    async def test_registrazione_successo(self, client):
        resp = await client.post("/auth/registrazione", json={
            "email": "test@example.com",
            "password": "password123",
            "nome": "Test User",
        })
        assert resp.status_code == 201
        data = resp.json()
        assert "access_token" in data
        assert data["token_type"] == "bearer"

    @pytest.mark.skip(reason="Richiede DB PostgreSQL attivo")
    async def test_registrazione_email_duplicata(self, client):
        payload = {
            "email": "dupe@example.com",
            "password": "password123",
            "nome": "Test User",
        }
        await client.post("/auth/registrazione", json=payload)
        resp = await client.post("/auth/registrazione", json=payload)
        assert resp.status_code == 409

    @pytest.mark.skip(reason="Richiede DB PostgreSQL attivo")
    async def test_login_credenziali_corrette(self, client):
        # Prima registra
        await client.post("/auth/registrazione", json={
            "email": "login@example.com",
            "password": "mypassword",
            "nome": "Login User",
        })
        # Poi login
        resp = await client.post("/auth/login", json={
            "email": "login@example.com",
            "password": "mypassword",
        })
        assert resp.status_code == 200
        assert "access_token" in resp.json()

    @pytest.mark.skip(reason="Richiede DB PostgreSQL attivo")
    async def test_login_password_sbagliata(self, client):
        await client.post("/auth/registrazione", json={
            "email": "badpass@example.com",
            "password": "correct",
            "nome": "User",
        })
        resp = await client.post("/auth/login", json={
            "email": "badpass@example.com",
            "password": "wrong",
        })
        assert resp.status_code == 401

    @pytest.mark.skip(reason="Richiede DB PostgreSQL attivo")
    async def test_endpoint_protetto_senza_token(self, client):
        resp = await client.get("/utente/me")
        assert resp.status_code in (401, 422)

    @pytest.mark.skip(reason="Richiede DB PostgreSQL attivo")
    async def test_endpoint_protetto_token_invalido(self, client):
        resp = await client.get(
            "/utente/me",
            headers={"Authorization": "Bearer token.fake.invalido"},
        )
        assert resp.status_code == 401

    @pytest.mark.skip(reason="Richiede DB PostgreSQL attivo")
    async def test_get_me_con_token_valido(self, client):
        # Registra
        resp = await client.post("/auth/registrazione", json={
            "email": "me@example.com",
            "password": "pass123",
            "nome": "Me User",
        })
        token = resp.json()["access_token"]
        # GET /me
        resp = await client.get(
            "/utente/me",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["email"] == "me@example.com"
        assert data["nome"] == "Me User"


# ---------------------------------------------------------------------------
# Test schema RegistraRequest con utente_temp_id
# ---------------------------------------------------------------------------

class TestRegistraRequestSchema:
    """Test che RegistraRequest accetti utente_temp_id opzionale."""

    def test_schema_senza_utente_temp_id(self):
        from app.schemas.auth import RegistraRequest

        req = RegistraRequest(
            email="test@example.com",
            password="pass123",
            nome="Test",
        )
        assert req.utente_temp_id is None

    def test_schema_con_utente_temp_id(self):
        from app.schemas.auth import RegistraRequest

        uid = uuid.uuid4()
        req = RegistraRequest(
            email="test@example.com",
            password="pass123",
            nome="Test",
            utente_temp_id=uid,
        )
        assert req.utente_temp_id == uid

    def test_schema_con_utente_temp_id_null(self):
        from app.schemas.auth import RegistraRequest

        req = RegistraRequest(
            email="test@example.com",
            password="pass123",
            nome="Test",
            utente_temp_id=None,
        )
        assert req.utente_temp_id is None

    def test_schema_utente_temp_id_stringa_uuid(self):
        from app.schemas.auth import RegistraRequest

        uid = uuid.uuid4()
        req = RegistraRequest(
            email="test@example.com",
            password="pass123",
            nome="Test",
            utente_temp_id=str(uid),
        )
        assert req.utente_temp_id == uid


# ---------------------------------------------------------------------------
# Test conversione utente temporaneo (unit test con mock)
# ---------------------------------------------------------------------------

class TestConvertiUtenteTemporaneo:
    """Test della logica _converti_utente_temporaneo (mock DB)."""

    @pytest.mark.asyncio
    async def test_converti_successo(self):
        """Conversione riuscita: utente temp esiste, email libera."""
        from app.api.auth import _converti_utente_temporaneo
        from app.schemas.auth import RegistraRequest

        uid = uuid.uuid4()
        utente_temp = MagicMock()
        utente_temp.id = uid
        utente_temp.email = None  # temporaneo
        utente_temp.password_hash = None
        utente_temp.nome = None

        payload = RegistraRequest(
            email="nuovo@example.com",
            password="secret123",
            nome="Mario",
            utente_temp_id=uid,
        )

        db = AsyncMock()
        db.commit = AsyncMock()
        db.refresh = AsyncMock()

        with (
            patch("app.api.auth.get_utente_by_id", return_value=utente_temp),
            patch("app.api.auth.get_utente_by_email", return_value=None),
        ):
            result = await _converti_utente_temporaneo(payload, db)

        assert result.access_token is not None
        assert result.token_type == "bearer"
        assert utente_temp.email == "nuovo@example.com"
        assert utente_temp.nome == "Mario"
        assert utente_temp.password_hash is not None  # hash impostato
        db.commit.assert_called_once()

    @pytest.mark.asyncio
    async def test_converti_utente_temp_non_trovato(self):
        """utente_temp_id non esiste → 404."""
        from fastapi import HTTPException

        from app.api.auth import _converti_utente_temporaneo
        from app.schemas.auth import RegistraRequest

        payload = RegistraRequest(
            email="test@example.com",
            password="pass",
            nome="Test",
            utente_temp_id=uuid.uuid4(),
        )

        db = AsyncMock()

        with patch("app.api.auth.get_utente_by_id", return_value=None):
            with pytest.raises(HTTPException) as exc_info:
                await _converti_utente_temporaneo(payload, db)
            assert exc_info.value.status_code == 404
            assert "non trovato" in exc_info.value.detail

    @pytest.mark.asyncio
    async def test_converti_utente_gia_registrato(self):
        """utente_temp_id esiste ma ha già email → 400."""
        from fastapi import HTTPException

        from app.api.auth import _converti_utente_temporaneo
        from app.schemas.auth import RegistraRequest

        utente_registrato = MagicMock()
        utente_registrato.email = "gia@registrato.com"  # non temporaneo

        payload = RegistraRequest(
            email="test@example.com",
            password="pass",
            nome="Test",
            utente_temp_id=uuid.uuid4(),
        )

        db = AsyncMock()

        with patch("app.api.auth.get_utente_by_id", return_value=utente_registrato):
            with pytest.raises(HTTPException) as exc_info:
                await _converti_utente_temporaneo(payload, db)
            assert exc_info.value.status_code == 400
            assert "registrato" in exc_info.value.detail

    @pytest.mark.asyncio
    async def test_converti_email_gia_usata(self):
        """Email già usata da altro utente → 409."""
        from fastapi import HTTPException

        from app.api.auth import _converti_utente_temporaneo
        from app.schemas.auth import RegistraRequest

        utente_temp = MagicMock()
        utente_temp.email = None  # temporaneo

        utente_esistente = MagicMock()
        utente_esistente.email = "occupata@example.com"

        payload = RegistraRequest(
            email="occupata@example.com",
            password="pass",
            nome="Test",
            utente_temp_id=uuid.uuid4(),
        )

        db = AsyncMock()

        with (
            patch("app.api.auth.get_utente_by_id", return_value=utente_temp),
            patch("app.api.auth.get_utente_by_email", return_value=utente_esistente),
        ):
            with pytest.raises(HTTPException) as exc_info:
                await _converti_utente_temporaneo(payload, db)
            assert exc_info.value.status_code == 409
            assert "registrata" in exc_info.value.detail

    @pytest.mark.asyncio
    async def test_converti_jwt_contiene_stesso_uuid(self):
        """Il JWT generato contiene lo stesso UUID dell'utente temporaneo."""
        from app.api.auth import _converti_utente_temporaneo
        from app.schemas.auth import RegistraRequest

        uid = uuid.uuid4()
        utente_temp = MagicMock()
        utente_temp.id = uid
        utente_temp.email = None
        utente_temp.password_hash = None
        utente_temp.nome = None

        payload = RegistraRequest(
            email="jwt@example.com",
            password="pass",
            nome="Test",
            utente_temp_id=uid,
        )

        db = AsyncMock()
        db.commit = AsyncMock()
        db.refresh = AsyncMock()

        with (
            patch("app.api.auth.get_utente_by_id", return_value=utente_temp),
            patch("app.api.auth.get_utente_by_email", return_value=None),
        ):
            result = await _converti_utente_temporaneo(payload, db)

        # Verifica che il token contenga lo UUID dell'utente temporaneo
        decoded_id = verifica_token(result.access_token)
        assert decoded_id == str(uid)
