FROM python:3.12-slim

WORKDIR /src

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Python dependencies (install from pyproject.toml)
COPY pyproject.toml .
COPY app/__init__.py app/__init__.py
RUN pip install --no-cache-dir -e .

# Application code
COPY . .

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
