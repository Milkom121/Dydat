"""Configurazione pytest globale.

- --run-integration: abilita i test marcati @pytest.mark.integration
  (richiedono ANTHROPIC_API_KEY e costano soldi)
"""

import pytest


def pytest_addoption(parser):
    parser.addoption(
        "--run-integration",
        action="store_true",
        default=False,
        help="Esegui test di integrazione con LLM reale",
    )


def pytest_collection_modifyitems(config, items):
    if config.getoption("--run-integration"):
        return
    skip_integration = pytest.mark.skip(
        reason="Usa --run-integration per eseguire"
    )
    for item in items:
        if "integration" in item.keywords:
            item.add_marker(skip_integration)
